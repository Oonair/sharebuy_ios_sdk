//
//  UIButton+ActivityIndicator.m
//  eshop
//
//  Created by Pierluigi Cifani on 2/11/13.
//  Copyright (c) 2013 Oonair. All rights reserved.
//

#import "UIButton+ActivityIndicator.h"
#import "UIView+CenterInSuperView.h"

#import <objc/runtime.h>

NSString * const kActivityKey       = @"kActivityKey";
NSString * const kConfigurationKey  = @"kConfigurationKey";

#define kTitleControlStateNormal        @"kTitleControlStateNormal"
#define kTitleControlStateHighlighted   @"kTitleControlStateHighlighted"
#define kImageControlStateNormal        @"kImageControlStateNormal"
#define kImageControlStateHighlighted   @"kImageControlStateHighlighted"

@interface  UIButton (ActivityIndicatorPrivate)
@property (nonatomic, strong) NSDictionary *initialConfiguration;
@end

@implementation UIButton (ActivityIndicator)

- (void) setInitialConfiguration:(NSDictionary *)dictionary
{
	objc_setAssociatedObject(self, (__bridge void *)kConfigurationKey, dictionary, OBJC_ASSOCIATION_RETAIN);
}

- (NSDictionary *) initialConfiguration
{
	return objc_getAssociatedObject(self, (__bridge void *)kConfigurationKey);
}

- (void) setActivityIndicator:(UIActivityIndicatorView *)activityIndicator
{
	objc_setAssociatedObject(self, (__bridge void *)kActivityKey, activityIndicator, OBJC_ASSOCIATION_RETAIN);
}

- (UIActivityIndicatorView *) activityIndicator
{
	return objc_getAssociatedObject(self, (__bridge void *)kActivityKey);
}


- (void) startActivityIndicator;
{
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhite];
    
    [self setActivityIndicator:indicator];
    
    [self addSubview:indicator];
    [indicator centerInSuperview];
    [indicator startAnimating];
    
    UIImage *normalImage    = [self imageForState:UIControlStateNormal];
    UIImage *highImage      = [self imageForState:UIControlStateHighlighted];
    NSString *normalTitle   = [self titleForState:UIControlStateNormal];
    NSString *highTitle     = [self titleForState:UIControlStateHighlighted];

    NSMutableDictionary *configuration = [NSMutableDictionary dictionary];
    
    if (normalImage) {
        [configuration setObject:normalImage
                          forKey:kImageControlStateNormal];
    }
    
    if (highImage) {
        [configuration setObject:highImage
                          forKey:kImageControlStateHighlighted];
    }
    
    if (normalTitle) {
        [configuration setObject:normalTitle
                          forKey:kTitleControlStateNormal];
    }
    
    if (highTitle) {
        [configuration setObject:highTitle
                          forKey:kTitleControlStateHighlighted];
    }
    
    self.initialConfiguration = configuration;
    
    [self setImage:nil forState:UIControlStateNormal];
    [self setImage:nil forState:UIControlStateHighlighted];
    [self setTitle:nil forState:UIControlStateNormal];
    [self setTitle:nil forState:UIControlStateHighlighted];
    
}

- (void) stopActivityIndicator;
{
    [self.activityIndicator stopAnimating];
    [self.activityIndicator removeFromSuperview];
    self.activityIndicator = nil;
    
    UIImage *normalImage    = [self.initialConfiguration objectForKey:kImageControlStateNormal];
    UIImage *highImage      = [self.initialConfiguration objectForKey:kImageControlStateHighlighted];
    NSString *normalTitle   = [self.initialConfiguration objectForKey:kTitleControlStateNormal];
    NSString *highTitle     = [self.initialConfiguration objectForKey:kTitleControlStateHighlighted];

    if (normalImage) {
        [self setImage:normalImage
              forState:UIControlStateNormal];
    }
    
    if (highImage) {
        [self setImage:highImage
              forState:UIControlStateHighlighted];
    }
    
    if (normalTitle) {
        [self setTitle:normalTitle
              forState:UIControlStateNormal];
    }
    
    if (highTitle) {
        [self setTitle:highTitle
              forState:UIControlStateHighlighted];
    }
    

    self.initialConfiguration = nil;
}

@end
