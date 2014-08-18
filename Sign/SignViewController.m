//
//  SignViewController.m
//  Sign
//
//  Created by iBankstory on 8/18/2557 BE.
//  Copyright (c) 2557 BE 365Zocial.com. All rights reserved.
//

static int numberOfSigner = 11;
static float drawView_width = 500;
static float drawView_height = 500;

#import "SignViewController.h"
#import "DrawView.h"
#import <AssetsLibrary/AssetsLibrary.h>
@interface SignViewController ()<UIScrollViewDelegate>
{
    IBOutlet UIScrollView *signatureScrollView;
    IBOutlet UISegmentedControl *segmentedControl;
    IBOutlet UIButton *clearButton, *saveButton;
}
- (IBAction)segmentedValueChanged:(id)sender;
- (IBAction)clearButtonPressed:(id)sender;
- (IBAction)saveButtonPressed:(id)sender;
@end

@implementation SignViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self setUpDrawViews];
   
}
- (void)viewDidAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
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
    
}
- (IBAction)segmentedValueChanged:(id)sender {
    
    NSInteger selectedIndex = segmentedControl.selectedSegmentIndex;
    float offet_x = selectedIndex * drawView_width;
    [signatureScrollView setContentOffset:CGPointMake(offet_x, 0) animated:YES];
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
}

- (DrawView *)getSelectedDrawView:(NSInteger)selectedIndex
{
    NSArray *signatureScrollViewSubview = [signatureScrollView subviews];
    NSLog(@"signatureScrollViewSubview count %ld",(long)signatureScrollViewSubview.count);
    
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
@end
