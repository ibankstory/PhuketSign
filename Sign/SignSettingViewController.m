//
//  SignSettingViewController.m
//  Sign
//
//  Created by iBankstory on 8/19/2557 BE.
//  Copyright (c) 2557 BE 365Zocial.com. All rights reserved.
//

#import "SignSettingViewController.h"
#import "QBFlatButton.h"
@interface SignSettingViewController ()<UIAlertViewDelegate>
{
    IBOutlet QBFlatButton *doneButton;
    IBOutlet UITextField *localURL_TextField, *onlineURL_TextField;
    IBOutlet UISegmentedControl *segmentedControl;
    IBOutlet QBFlatButton *clearCacheButton;
}

- (IBAction)saveButtonPressed:(id)sender;
- (IBAction)doneButtonPressed:(id)sender;
- (IBAction)segmentedControlValueChanged:(id)sender;
- (void)closeThisView;
- (void)displaySettingValue;
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
    
    [self displaySettingValue];
    
    [doneButton setFaceColor:[UIColor colorWithRed:0.92 green:0.652 blue:0.238 alpha:1]];
    [doneButton setSideColor:[UIColor colorWithRed:0.13 green:0.57 blue:0.13 alpha:1]];
    
    [clearCacheButton setFaceColor:[UIColor colorWithRed:0.889 green:0.17 blue:0.102 alpha:1]];
    [clearCacheButton setSideColor:[UIColor colorWithRed:0.351 green:0.069 blue:0.042 alpha:1]];
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

- (void)displaySettingValue
{
    localURL_TextField.text = [self.settingDict valueForKey:setting_localURL];
    
    onlineURL_TextField.text = [self.settingDict valueForKey:setting_onlineURL];
    if ([onlineURL_TextField.text length] < 1) {
        onlineURL_TextField.text = @"http://phuketsign.heroku.com/processupload";
    }
    
    NSInteger selectedIndex = [[self.settingDict valueForKey:setting_route_index_api] integerValue];
    [segmentedControl setSelectedSegmentIndex:selectedIndex];
}
- (IBAction)saveButtonPressed:(id)sender
{
    if ([localURL_TextField.text length] > 0 && [onlineURL_TextField.text length] > 0) {
        
        if (self.settingDict == nil) {
            self.settingDict = [[NSMutableDictionary alloc]init];
        }
        
        [self.settingDict setValue:localURL_TextField.text forKey:setting_localURL];
        [self.settingDict setValue:onlineURL_TextField.text forKey:setting_onlineURL];
        [self.settingDict setValue:[NSNumber numberWithInteger:segmentedControl.selectedSegmentIndex] forKey:setting_route_index_api];
        
        if (segmentedControl.selectedSegmentIndex == 1) {
            [self.settingDict setValue:onlineURL_TextField.text forKey:setting_route_url];
        }else{
            [self.settingDict setValue:localURL_TextField.text forKey:setting_route_url];
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:self.settingDict forKey:settingKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:setting_save_notification object:nil];
    }
    
    
    
    [self closeThisView];
}
- (IBAction)doneButtonPressed:(id)sender
{
    [self closeThisView];
}
- (void)closeThisView
{
    
    
    [self dismissViewControllerAnimated:YES completion:^(void){
        [[NSNotificationCenter defaultCenter] postNotificationName:setting_save_notification object:nil];
    }];
}
- (IBAction)segmentedControlValueChanged:(id)sender
{
    
}

- (IBAction)clearCacheButtonPressed:(id)sender
{
 
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning!" message:@"Clear cache?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
    alert.tag = 191;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 191) {
        if (buttonIndex == 1) {
            NSLog(@"Clear cache");
            [self clearCache];
        }
    }
}

- (void)clearCache{
    
    @try {
        NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSFileManager *filemanager = [NSFileManager defaultManager];
        
        NSError *error = nil;
        NSArray *files = [filemanager contentsOfDirectoryAtPath:documentsPath error:&error];
        NSLog(@"files %@",files);
        
        for (NSString *filename in files) {
            NSString *filepath = [[documentsPath stringByAppendingString:@"/"] stringByAppendingString:filename];
            NSLog(@"filepath %@",filepath);
            NSError *theError = nil;
            if ([filemanager fileExistsAtPath:filepath]) {
                [filemanager removeItemAtPath:filepath error:&error];
            }
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
    }
    
    
}
@end
