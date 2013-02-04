//
//  UIImageView+ActivityIndicator.m
//  ShareBuy
//
//  Created by Pierluigi Cifani on 10/19/12.
//  Copyright (c) 2012 Oonair. All rights reserved.
//

#import "UIImageView+ActivityIndicator.h"
#import "UIView+CenterInSuperView.h"
#import <objc/runtime.h>

static char overviewKey;

@implementation UIImageView (ActivityIndicator)


- (void) placeActivityIndicatorViewInCenterWithStyle:(UIActivityIndicatorViewStyle)style;
{
    [self placeActivityIndicatorViewInCenterWithStyle:style withColor:nil];
}

- (void) placeActivityIndicatorViewInCenterWithStyle:(UIActivityIndicatorViewStyle)style
                                           withColor:(UIColor *)aColor;
{
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:style];
    [self addSubview:spinner];
    [spinner centerInSuperview];
    [spinner startAnimating];
    
    if (aColor) {
        [spinner setColor:aColor];
    }
    
    objc_setAssociatedObject (self,
                              &overviewKey,
                              spinner,
                              OBJC_ASSOCIATION_RETAIN
                              );
    return;
}

- (void) cancelActivityIndicatorView;
{
    UIActivityIndicatorView *spinner =
    (UIActivityIndicatorView *) objc_getAssociatedObject (self, &overviewKey);
    
    [spinner stopAnimating];
    [spinner removeFromSuperview];
    
    objc_setAssociatedObject (self,
                              &overviewKey,
                              nil,
                              OBJC_ASSOCIATION_ASSIGN
                              );
}

@end
