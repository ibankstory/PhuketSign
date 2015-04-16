//
//  TheSignFlatButton.h
//  Sign
//
//  Created by iBankstory on 4/16/2558 BE.
//  Copyright (c) 2558 365Zocial.com. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE

@interface TheSignFlatButton : UIButton
@property (strong) IBInspectable UIColor *borderColor;
@property (nonatomic) IBInspectable CGFloat borderWidth;
@property (nonatomic) IBInspectable UIColor *defaultBackgroundColor;
@property (nonatomic) IBInspectable UIColor *activeBackgroundColor;

@end
