//
//  TheSignFlatButton.m
//  Sign
//
//  Created by iBankstory on 4/16/2558 BE.
//  Copyright (c) 2558 365Zocial.com. All rights reserved.
//

#import "TheSignFlatButton.h"

@implementation TheSignFlatButton


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, _borderColor.CGColor);
    CGContextFillRect(context, CGRectMake(0.0f, self.frame.size.height-_borderWidth, self.frame.size.width, _borderWidth));
    
}



@end
