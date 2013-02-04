//
//  UIView+CenterInSuperView.m
//  ShareBuy
//
//  Created by Pierluigi Cifani on 7/18/12.
//  Copyright (c) 2012 Oonair. All rights reserved.
//

#import "UIView+CenterInSuperView.h"

@implementation UIView (CenterInSuperView)

- (void) centerInSuperview;
{
    [self centerInSuperviewWithOffset:CGPointZero];
}


- (void) centerInSuperviewWithOffset:(CGPoint)aOffset;
{
    CGPoint superCenter = CGPointMake([[self superview] bounds].size.width / 2.0 + aOffset.x, [[self superview] bounds].size.height / 2.0 + aOffset.y);
    [self setCenter:superCenter];
}

- (void) centerXInSuperview;
{
    CGPoint newCenter = CGPointMake([[self superview] bounds].size.width / 2.0, self.bounds.origin.y);
    [self setCenter:newCenter];
}

@end
