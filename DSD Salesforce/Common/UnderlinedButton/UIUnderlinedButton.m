//
//  UIUnderlinedButton.m
//  DSD Salesforce
//
//  Created by iOS Developer on 7/5/18.
//  Copyright © 2018 iOS Developer. All rights reserved.
//

#import "UIUnderlinedButton.h"

@implementation UIUnderlinedButton

+ (UIUnderlinedButton*) underlinedButton {
    UIUnderlinedButton* button = [[UIUnderlinedButton alloc] init];
    return button;
}

- (void) drawRect:(CGRect)rect {
    CGRect textRect = self.titleLabel.frame;

    // need to put the line at top of descenders (negative value)
    CGFloat descender = self.titleLabel.font.descender;

    CGContextRef contextRef = UIGraphicsGetCurrentContext();

    // set to same colour as text
    CGContextSetStrokeColorWithColor(contextRef, self.titleLabel.textColor.CGColor);

    CGContextMoveToPoint(contextRef, textRect.origin.x, textRect.origin.y + textRect.size.height + descender);

    CGContextAddLineToPoint(contextRef, textRect.origin.x + textRect.size.width, textRect.origin.y + textRect.size.height + descender);

    CGContextClosePath(contextRef);

    CGContextDrawPath(contextRef, kCGPathStroke);
}

@end
