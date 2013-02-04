//
//  UIView+Effects.m
//  ShareBuySDK
//
//  Created by Pierluigi Cifani on 10/29/12.
//  Copyright (c) 2012 Oonair. All rights reserved.
//

#import "UIView+Effects.h"

@implementation UIView (Effects)

-(void)addSubviewWithFadeInEffect:(UIView *)view
                         duration:(NSTimeInterval)duration
                       completion:(void (^)(void)) completionBlock;
{
    view.alpha = 0.0;
    [self addSubview:view];
    
    [UIView animateWithDuration:duration
                     animations:^{
                         view.alpha = 1.0;
                     }
                     completion:^(BOOL finished){
                         completionBlock();
                     }];
}

-(void)addSubviewWithFadeInEffect:(UIView *)view;
{
    [self addSubviewWithFadeInEffect:view
                            duration:0.3
                          completion:^{
    
                          }];
}

-(void)removeFromSuperviewWithFadeOutEffect;
{
    self.alpha = 1.0;
    __block UIView *blockSelf = self;
    [UIView animateWithDuration:0.3
                     animations:^{
                         blockSelf.alpha = 0.0;
                     }
                     completion:^(BOOL finished){
                         [blockSelf removeFromSuperview];
                     }];
}


@end
