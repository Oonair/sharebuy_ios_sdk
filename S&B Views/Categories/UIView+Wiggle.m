//
//  UIView+Wiggle.m
//  ShareBuySDK
//
//  Created by Pierluigi Cifani on 1/18/13.
//  Copyright (c) 2013 Oonair. All rights reserved.
//

#import "UIView+Wiggle.h"

#import <QuartzCore/QuartzCore.h>

@implementation UIView (Wiggle)

- (void)wiggle
{
    //Start at negative kWiggleAnimationAngle so we animate to positive kWiggleAnimationAngle
    
    CGFloat kWiggleAnimationAngle = 0.05;
    self.layer.transform = CATransform3DMakeRotation(-kWiggleAnimationAngle, 0, 0, 1.0);
    
    //Setup a transform that will rotate our view to positive kWiggleAnimationAngle
    CATransform3D transform = CATransform3DMakeRotation(kWiggleAnimationAngle, 0, 0, 1.0);
    
    //Setup our animation with the transform
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.toValue = [NSValue valueWithCATransform3D:transform];
    animation.repeatCount = 4;
    animation.duration = 0.10;
    animation.autoreverses = YES;
    animation.delegate = self;
    [self.layer addAnimation:animation forKey:@"wiggle"];
}

- (void)cancelWiggle
{
    [self.layer removeAnimationForKey:@"wiggle"];
}

- (void) animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    self.layer.transform = CATransform3DMakeRotation(0, 0, 0, 1.0);
}


@end
