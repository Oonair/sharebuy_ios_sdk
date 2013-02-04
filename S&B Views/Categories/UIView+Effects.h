//
//  UIView+Effects.h
//  ShareBuySDK
//
//  Created by Pierluigi Cifani on 10/29/12.
//  Copyright (c) 2012 Oonair. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Effects)

-(void)addSubviewWithFadeInEffect:(UIView *)view
                         duration:(NSTimeInterval)duration
                       completion:(void (^)(void)) completionBlock;

-(void)addSubviewWithFadeInEffect:(UIView *)view;
-(void)removeFromSuperviewWithFadeOutEffect;

@end
