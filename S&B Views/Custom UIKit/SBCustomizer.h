//
//  SBCustomizer.h
//  eshop
//
//  Created by Pierluigi Cifani on 2/4/13.
//  Copyright (c) 2013 Oonair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBPopoverBackgroundView.h"

@interface SBCustomizer : NSObject

+ (instancetype) sharedCustomizer;

- (UIFont *) defaultFontOfSize:(CGFloat)fontSize;
- (UIFont *) secondaryFontOfSize:(CGFloat)fontSize;

- (UIBarButtonItem *) barButtonWithImage:(UIImage *)image
                                  target:(id)target
                                  action:(SEL)action;

- (UIBarButtonItem *) barButtonWithTitle:(NSString *)title
                                  target:(id)target
                                  action:(SEL)action;

- (UIBarButtonItem *) doneBarButtonWithTitle:(NSString *)title
                                      target:(id)target
                                      action:(SEL)action;

- (UINavigationController *)navigationControllerWithRootViewController:(UIViewController *)controller;

- (UIView *)tableHeaderWithName:(NSString *)name tableWidth:(CGFloat)tableWidht;

// General elements
@property (nonatomic, strong) UIFont *defaultFont;
@property (nonatomic, strong) UIFont *secondaryFont;
@property (nonatomic, strong) UIColor *fontColor;
@property (nonatomic, strong) UIColor *textShadowColor;
@property (nonatomic, strong) UIColor *navigationBarTintColor;
@property (nonatomic, strong) UIColor *tableHeaderColor;

@property (nonatomic, strong) UIImage *navigationBarBackgroundImage;
@property (nonatomic, strong) UIImage *navigationBarBackgroundImageLandscapePhone;

// UIBarButtonItem
@property (nonatomic, strong) UIImage *barButtonImage;
@property (nonatomic, strong) UIImage *barButtonHighlightedImage;
@property (nonatomic, strong) UIImage *barButtonDoneImage;
@property (nonatomic, strong) UIImage *barButtonDoneHighlightedImage;
@property (nonatomic, strong) UIImage *barButtonBackImage;
@property (nonatomic, strong) UIImage *barBackButtonHighlightedImage;

// Cell customization
@property (nonatomic, strong) UIImage *noContactPlaceholder;
@property (nonatomic, strong) UIImage *groupChatPlaceholder;
@property (nonatomic, strong) UIImage *badgeImage;

// Chat table 
@property (nonatomic, strong) UIFont *chatBubbleFont;
@property (nonatomic, strong) UIColor *selfChatBubbleFontColor;
@property (nonatomic, strong) UIColor *otherChatBubbleFontColor;
@property (nonatomic, strong) UIImage *selfChatBubbleImage;
@property (nonatomic, strong) UIImage *otherChatBubbleImage;

@end
