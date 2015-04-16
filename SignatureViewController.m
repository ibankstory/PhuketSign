//
//  SignatureViewController.m
//  Sign
//
//  Created by iBankstory on 4/16/2558 BE.
//  Copyright (c) 2558 365Zocial.com. All rights reserved.
//

#import "SignatureViewController.h"
#import "TheSignFlatButton.h"
@interface SignatureViewController ()
{
    IBOutlet TheSignFlatButton *button1, *button2, *button3, *button4;
    
    NSArray *arrayOfButtons;
}

@end

@implementation SignatureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    arrayOfButtons = [NSArray arrayWithObjects:button1,button2,button3,button4, nil];
    
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
            NSLog(@"YES");
        }else{
            [button setBackgroundColor:button.defaultBackgroundColor];
            NSLog(@"NO");
        }
        
    }
}
@end
