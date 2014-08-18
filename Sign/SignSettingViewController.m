//
//  SignSettingViewController.m
//  Sign
//
//  Created by iBankstory on 8/19/2557 BE.
//  Copyright (c) 2557 BE 365Zocial.com. All rights reserved.
//

#import "SignSettingViewController.h"

@interface SignSettingViewController ()
{
    IBOutlet UIButton *doneButton;
}

- (IBAction)doneButtonPressed:(id)sender;
- (void)closeThisView;
@end

@implementation SignSettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)doneButtonPressed:(id)sender
{
    [self closeThisView];
}
- (void)closeThisView
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}
@end
