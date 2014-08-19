//
//  SignViewController.m
//  Sign
//
//  Created by iBankstory on 8/18/2557 BE.
//  Copyright (c) 2557 BE 365Zocial.com. All rights reserved.
//



static int numberOfSigner = 11;
static float drawView_width = 650;
static float drawView_height = 650;

#import "SignViewController.h"
#import "DrawView.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "SignSettingViewController.h"
#import <AFNetworking/AFNetworking.h>
@interface SignViewController ()<UIScrollViewDelegate>
{
    IBOutlet UIScrollView *signatureScrollView;
    IBOutlet UISegmentedControl *segmentedControl;
    IBOutlet UIButton *clearButton, *saveButton, *undoButton;
}

@property (nonatomic) NSMutableDictionary *settingDict;

- (IBAction)segmentedValueChanged:(id)sender;
- (IBAction)clearButtonPressed:(id)sender;
- (IBAction)saveButtonPressed:(id)sender;
- (void)didreceiveSettingSaveNotification;
@end

@implementation SignViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self setUpDrawViews];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didreceiveSettingSaveNotification) name:setting_save_notification object:nil];
   
    self.settingDict = [self getSetting];
}
- (void)viewDidAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    if (self.settingDict == nil) {
        [self performSegueWithIdentifier:openSettingView sender:nil];
    }
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUpDrawViews
{

    for (int i = 0; i < numberOfSigner; i++) {
        DrawView *drawView = [[DrawView alloc] initWithFrame:CGRectMake(i * drawView_width, 0, drawView_width, drawView_height)];
        drawView.tag = i;
        drawView.strokeColor = [UIColor blackColor];
        drawView.strokeWidth = 3.0f;
        
        [signatureScrollView addSubview:drawView];
    }
    
    [undoButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    DrawView *drawView = [self getSelectedDrawView:segmentedControl.selectedSegmentIndex];
    [undoButton addTarget:drawView action:@selector(undoDrawing:) forControlEvents:UIControlEventTouchUpInside];
    
}
- (IBAction)segmentedValueChanged:(id)sender {
    
    NSInteger selectedIndex = segmentedControl.selectedSegmentIndex;
    float offet_x = selectedIndex * drawView_width;
    [signatureScrollView setContentOffset:CGPointMake(offet_x, 0) animated:NO];
    
    [undoButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    DrawView *drawView = [self getSelectedDrawView:selectedIndex];
    [undoButton addTarget:drawView action:@selector(undoDrawing:) forControlEvents:UIControlEventTouchUpInside];
}

- (IBAction)clearButtonPressed:(id)sender
{
    NSInteger selectedIndex = segmentedControl.selectedSegmentIndex;
    DrawView *drawView = [self getSelectedDrawView:selectedIndex];
    [drawView clearDrawing];
    
}
- (IBAction)saveButtonPressed:(id)sender
{
    NSInteger selectedIndex = segmentedControl.selectedSegmentIndex;
    DrawView *drawView = [self getSelectedDrawView:selectedIndex];
    
    UIImage *drawingImage = [drawView imageRepresentation];
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeImageToSavedPhotosAlbum:drawingImage.CGImage orientation:ALAssetOrientationUp completionBlock:^(NSURL *assetURL, NSError *error) {
        NSLog(@"%@",assetURL);
        NSLog(@"%@",error);
    }];
    
    
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSString *api_url;
    
    if ([self.settingDict valueForKey:setting_route_url]) {
        api_url = [self.settingDict valueForKey:setting_route_url];
    }else{
        api_url = [self.settingDict valueForKey:setting_localURL];
    }
    
    NSString *post_image_api = api_url;
    NSLog(@"post_image_api %@",post_image_api);
    
    if ([post_image_api length] > 0) {
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        NSData *imageData;
        if (drawingImage) {
            imageData = UIImageJPEGRepresentation(drawingImage, 0.8);
        }
        
        NSMutableDictionary *parameters = [NSMutableDictionary new];
        NSInteger imageNumber = segmentedControl.selectedSegmentIndex + 1;
        [parameters setValue:[NSNumber numberWithInteger:imageNumber] forKey:@"image_id"];
        
        NSLog(@"parameters %@",parameters);
        [manager POST:post_image_api parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            if (imageData) {
                [formData appendPartWithFileData:imageData name:@"image" fileName:@"photo.jpeg" mimeType:@"image/jpeg"];
            }
        } success:^(AFHTTPRequestOperation *operation, id responseObject){
            
            NSLog(@"responseObject");
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:error.localizedDescription delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
            [alert show];
            
        }];

    }else{
        [self performSegueWithIdentifier:openSettingView sender:nil];
    }
}

- (DrawView *)getSelectedDrawView:(NSInteger)selectedIndex
{
    for (id subview in [signatureScrollView subviews]) {
        
        if ([subview isKindOfClass:[DrawView class]]) {
            DrawView *drawView = (DrawView *)subview;
            NSLog(@"drawView tag %ld --- selectedIndex %ld",(long)drawView.tag,(long)selectedIndex);
            
            if (drawView.tag == selectedIndex) {
                return drawView;
            }
        }
    }
    
    return nil;
}

- (NSMutableDictionary *)getSetting
{
    return [[[NSUserDefaults standardUserDefaults] dictionaryForKey:settingKey] mutableCopy];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:openSettingView]) {
        SignSettingViewController *settingView = [segue destinationViewController];
        settingView.settingDict = self.settingDict;
    }
}

- (void)didreceiveSettingSaveNotification
{
    self.settingDict = [self getSetting];
}
@end
