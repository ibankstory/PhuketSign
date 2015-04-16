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
@interface SignatureViewController ()
{
    IBOutlet TheSignFlatButton *button1, *button2, *button3, *button4;
    
    NSArray *arrayOfPersonIDs;
    NSArray *arrayOfButtons;
    
    NSArray *arrayOfSignatureViews;
    
    IBOutlet UIScrollView *scrollView;
    
    NSInteger activeIndex;
    
    PPSSignatureView *currentSignatureView;
}

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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
        }
    }
}
@end
