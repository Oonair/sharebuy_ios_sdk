//
//  UIButton+ActivityIndicator.h
//  eshop
//
//  Created by Pierluigi Cifani on 2/11/13.
//  Copyright (c) 2013 Oonair. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (ActivityIndicator)

- (void) startActivityIndicator;
- (void) stopActivityIndicator;

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end
