//
//  UIImageView+ActivityIndicator.h
//  ShareBuy
//
//  Created by Pierluigi Cifani on 10/19/12.
//  Copyright (c) 2012 Oonair. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (ActivityIndicator)

- (void) placeActivityIndicatorViewInCenterWithStyle:(UIActivityIndicatorViewStyle)style withColor:(UIColor *)aColor;

- (void) placeActivityIndicatorViewInCenterWithStyle:(UIActivityIndicatorViewStyle)style;

- (void) cancelActivityIndicatorView;

@end
