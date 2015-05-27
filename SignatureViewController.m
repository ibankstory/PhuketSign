//
//  SignatureViewController.m
//  Sign
//
//  Created by iBankstory on 4/16/2558 BE.
//  Copyright (c) 2558 365Zocial.com. All rights reserved.
//

#import "SignatureViewController.h"
#import "TheSignFlatButton.h"
#import "PPSSignatureView.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AFNetworking/AFNetworking.h>
#import "SignSettingViewController.h"
@interface SignatureViewController ()<UIAlertViewDelegate>
{
    IBOutlet TheSignFlatButton *button1, *button2, *button3, *button4;
    
    NSArray *arrayOfPersonIDs;
    NSArray *arrayOfButtons;
    
    NSArray *arrayOfSignatureViews;
    
    IBOutlet UIScrollView *scrollView;
    IBOutlet UILabel *selectedServerLabel;
    
    NSInteger activeIndex;
    
    PPSSignatureView *currentSignatureView;
}

@property (nonatomic) NSMutableDictionary *settingDict;

@end

@implementation SignatureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    arrayOfPersonIDs = [NSArray arrayWithObjects:@"person_1",@"person_2",@"person_3",@"person_4", nil];
    button1.tag = 0;
    button2.tag = 1;
    button3.tag = 2;
    button4.tag = 3;
    arrayOfButtons = [NSArray arrayWithObjects:button1,button2,button3,button4, nil];
    
    
    [self buttonPressed:button1];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didreceiveSettingSaveNotification) name:setting_save_notification object:nil];
    
    self.settingDict = [self getSetting];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    scrollView.scrollEnabled = NO;
    
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqualToString:openSettingViewV2]) {
        SignSettingViewController *settingView = [segue destinationViewController];
        settingView.settingDict = self.settingDict;
    }
    
}


- (IBAction)buttonPressed:(id)sender
{
    for (TheSignFlatButton *button in arrayOfButtons) {
        
        if (sender == button) {
            [button setBackgroundColor:button.activeBackgroundColor];
        }else{
            [button setBackgroundColor:button.defaultBackgroundColor];
        }
        
    }
    
    UIButton *senderButton = (UIButton *)sender;
    NSInteger tag = senderButton.tag;
    activeIndex = tag;
    [scrollView setContentOffset:CGPointMake(scrollView.frame.size.width*tag, 0) animated:NO];
    
    for (id view in scrollView.subviews) {
        
        if ([view isKindOfClass:[PPSSignatureView class]]) {
            PPSSignatureView *signatureV = (PPSSignatureView *)view;
            if (signatureV.tag == activeIndex) {
                currentSignatureView = signatureV;
            }
        }
    }
}

- (IBAction)clearButtonPressed:(id)sender
{
    if (currentSignatureView) {
        [currentSignatureView erase];
    }
}

- (IBAction)saveButtonPressed:(id)sender
{
    if (currentSignatureView) {
        UIImage *signatureImage = currentSignatureView.signatureImage;
        NSLog(@"image %@ for name %@",signatureImage,[arrayOfPersonIDs objectAtIndex:activeIndex]);
        
        if (signatureImage) {
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
            [library writeImageToSavedPhotosAlbum:signatureImage.CGImage orientation:ALAssetOrientationUp completionBlock:^(NSURL *assetURL, NSError *error) {
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
                if (signatureImage) {
                    imageData = UIImageJPEGRepresentation(signatureImage, 0.8);
                }
                
                NSMutableDictionary *parameters = [NSMutableDictionary new];
                NSInteger imageNumber = activeIndex + 1;
                NSString *imageID = [NSString stringWithFormat:@"person_%ld",(long)imageNumber];
                [parameters setValue:imageID forKey:@"id"];
                
                NSLog(@"parameters %@",parameters);
                [manager POST:post_image_api parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                    if (imageData) {
                        NSString *imageName = [self getImageFileName];
                        [formData appendPartWithFileData:imageData name:@"img" fileName:imageName mimeType:@"image/jpeg"];
                    }
                } success:^(AFHTTPRequestOperation *operation, id responseObject){
                    
  
                    
                    NSLog(@"responseObject %@",responseObject);
                    
                    if ([[responseObject valueForKey:@"uploaded"] integerValue] == 1) {
                        UIAlertView *successAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Thank you!", nil) message:@"Image has sent" delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
                        [successAlert show];
                    }
                    
                    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                    
                    
                    
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    
                    
                    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:error.localizedDescription delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
                    [alert show];
                    
                }];
                
                
                @try {
                    [self saveLastImage:signatureImage forfilename:[NSString stringWithFormat:@"%@.jpg",imageID]];
                }
                @catch (NSException *exception) {
                    
                }
                @finally {
                    
                }
                
                
            }else{
                [self performSegueWithIdentifier:openSettingView sender:nil];
            }
        }
    }
}

- (void)didreceiveSettingSaveNotification
{
    self.settingDict = [self getSetting];
    
    if (self.settingDict == nil) {
        [self performSegueWithIdentifier:openSettingViewV2 sender:nil];
    }
    
    @try {
        NSInteger selectedIndex = [[self.settingDict valueForKey:setting_route_index_api] integerValue];
        if (selectedIndex == 0) {
            selectedServerLabel.text = @"Local";
        }else{
            selectedServerLabel.text = @"Remote";
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
}
- (NSMutableDictionary *)getSetting
{
    return [[[NSUserDefaults standardUserDefaults] dictionaryForKey:settingKey] mutableCopy];
}

- (NSString *)getImageFileName
{
    
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc]init];
    [dateFormater setDateFormat:@"yyyy_MM_ddHH_mm_ssSSS"];
    NSString *dateString = [dateFormater stringFromDate:[NSDate date]];
    
    NSString *key = [NSString stringWithFormat:@"person_%ld-%@",(long)(activeIndex+1),dateString];
    NSString *filename = [NSString stringWithFormat:@"%@.jpg",key];
    
    
    return filename;
}

- (void)saveLastImage:(UIImage *)image forfilename:(NSString *)filename
{
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *imagePath = [documentsPath stringByAppendingPathComponent:filename];
    NSLog(@"imagePath %@",imagePath);
    
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    [imageData writeToFile:imagePath atomically:YES];
}

- (IBAction)getLastImageButtonPressed:(id)sender
{
    
    UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"The Signature" message:@"Resend last image if have?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
    alerView.tag = 111;
    alerView.alertViewStyle = UIAlertViewStyleSecureTextInput;
    [alerView show];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 111) {
        
        
        if (buttonIndex == 1) {
            if ([[[alertView textFieldAtIndex:0] text] isEqualToString:@"4400"]) {
                [self resendLastImage];
            }
        }
        
    }
}

- (void)resendLastImage
{
    NSInteger imageNumber = activeIndex + 1;
    NSString *imageID = [NSString stringWithFormat:@"person_%ld",(long)imageNumber];
    NSString *filename = [NSString stringWithFormat:@"%@.jpg",imageID];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *imagePath = [documentsPath stringByAppendingPathComponent:filename];
    NSLog(@"imagePath %@",imagePath);
    
    UIImage *lastImage = [[UIImage alloc] initWithContentsOfFile:imagePath];
    if (lastImage) {
        NSLog(@"lastImage %@",lastImage);
        
        
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
            if (lastImage) {
                imageData = UIImageJPEGRepresentation(lastImage, 0.8);
            }
            
            NSMutableDictionary *parameters = [NSMutableDictionary new];
            NSInteger imageNumber = activeIndex + 1;
            NSString *imageID = [NSString stringWithFormat:@"person_%ld",(long)imageNumber];
            [parameters setValue:imageID forKey:@"id"];
            
            NSLog(@"parameters %@",parameters);
            [manager POST:post_image_api parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                if (imageData) {
                    NSString *imageName = [self getImageFileName];
                    [formData appendPartWithFileData:imageData name:@"img" fileName:imageName mimeType:@"image/jpeg"];
                }
            } success:^(AFHTTPRequestOperation *operation, id responseObject){
                
                
                
                NSLog(@"responseObject %@",responseObject);
                
                if ([[responseObject valueForKey:@"uploaded"] integerValue] == 1) {
                    UIAlertView *successAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Thank you!", nil) message:@"Image has sent" delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
                    [successAlert show];
                }
                
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                
                
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
                
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:error.localizedDescription delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
                [alert show];
                
            }];
            
            
        }
        
    }else{
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"No last image" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil, nil] show];
    }
}
@end
