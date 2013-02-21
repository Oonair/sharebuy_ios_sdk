//
//  SBCustomizer.m
//  eshop
//
//  Created by Pierluigi Cifani on 2/4/13.
//  Copyright (c) 2013 Oonair. All rights reserved.
//

#import "SBCustomizer.h"
#import "SBBarButtonItem.h"
#import "SBNavigationBar.h"
#import "SBNavigationController.h"

@interface SBCustomizer ()

@end

@implementation SBCustomizer

+ (id)sharedCustomizer
{
    static id sharedCustomizer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedCustomizer = [[SBCustomizer alloc] init];
    });
    
    return sharedCustomizer;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        //Set default values
        _defaultFont = [UIFont boldSystemFontOfSize:18.0f];
        _secondaryFont = [UIFont systemFontOfSize:12.0f];
        _fontColor = [UIColor whiteColor];
        _textShadowColor = [UIColor lightGrayColor];
        
        _chatBubbleFont = [UIFont systemFontOfSize:16.0f];
        _selfChatBubbleFontColor = [UIColor blackColor];
        _otherChatBubbleFontColor = [UIColor blackColor];

        _selfChatBubbleImage = [[UIImage imageNamed:@"mine"] stretchableImageWithLeftCapWidth:15
                                                                                 topCapHeight:14];
        
        _otherChatBubbleImage = [[UIImage imageNamed:@"other"] stretchableImageWithLeftCapWidth:21
                                                                                   topCapHeight:14];
       
        _noContactPlaceholder = [UIImage imageNamed:@"no-contact@2x"];
        
        _groupChatPlaceholder = [UIImage imageNamed:@"group-chat@2x"];
        
        _badgeImage = [UIImage imageNamed:@"badge@2x"];
    }
    return self;
}

- (UINavigationController *)navigationControllerWithRootViewController:(UIViewController *)controller;
{
    return [[SBNavigationController alloc] initWithRootViewController:controller];
}

- (UIBarButtonItem *) barButtonWithImage:(UIImage *)image
                               target:(id)target
                               action:(SEL)action;
{
    return [SBBarButtonItem buttonWithTarget:target
                                      action:action
                                       image:image];
}

- (UIBarButtonItem *) barButtonWithTitle:(NSString *)title
                               target:(id)target
                               action:(SEL)action;
{
    return [[SBBarButtonItem alloc] initWithTitle:title
                                            style:UIBarButtonItemStylePlain
                                           target:target
                                           action:action];
}


- (UIBarButtonItem *) doneBarButtonWithTitle:(NSString *)title
                                      target:(id)target
                                      action:(SEL)action;
{
    return [[SBBarButtonItem alloc] initWithTitle:title
                                            style:UIBarButtonItemStyleDone
                                           target:target
                                           action:action];
}

- (UIView *) tableHeaderWithName:(NSString *)name tableWidth:(CGFloat)tableWidht;
{
    if (_tableHeaderColor == nil) {
        return nil;
    }
    
    CGRect viewRect = CGRectMake(0, 0, tableWidht, 30);
    CGRect labelRect = CGRectMake(7, 3, tableWidht, 18);
    
    UIView *headerView = [[UIView alloc] initWithFrame:viewRect];
    [headerView setBackgroundColor:_tableHeaderColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:labelRect];
    [label setTextColor:[UIColor whiteColor]];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setFont:[[SBCustomizer sharedCustomizer] defaultFontOfSize:16.0]];
    
    [headerView addSubview:label];
    
    [label setText:name];
    
    return headerView;
}

- (UIFont *) defaultFontOfSize:(CGFloat)fontSize;
{
    return [_defaultFont fontWithSize:fontSize];
}
- (UIFont *) secondaryFontOfSize:(CGFloat)fontSize;
{
    return [_secondaryFont fontWithSize:fontSize];
}

- (void) customizeSBNavigationBar
{
    //Customize UINavigationBar
    [[SBNavigationBar appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      _fontColor,
      UITextAttributeTextColor,
      _textShadowColor,
      UITextAttributeTextShadowColor,
      [NSValue valueWithUIOffset:UIOffsetMake(0, -1)],
      UITextAttributeTextShadowOffset,
      _defaultFont,
      UITextAttributeFont,
      nil]];
}

- (void) setDefaultFont:(UIFont *)defaultFont
{
    _defaultFont = defaultFont;
    [self customizeSBNavigationBar];
}

- (void) setFontColor:(UIColor *)fontColor
{
    _fontColor = fontColor;
    [self customizeSBNavigationBar];
}

- (void) setTextShadowColor:(UIColor *)textShadowColor
{
    _textShadowColor = textShadowColor;
    [self customizeSBNavigationBar];
}

- (void) setNavigationBarTintColor:(UIColor *)navigationBarTintColor
{
    _navigationBarTintColor = navigationBarTintColor;
    
    [[SBNavigationBar appearance] setTintColor:_navigationBarTintColor];
}

- (void) setNavigationBarBackgroundImage:(UIImage *)navigationBarBackgroundImage
{
    _navigationBarBackgroundImage = navigationBarBackgroundImage;
    
    [[SBNavigationBar appearance] setBackgroundImage:_navigationBarBackgroundImage
                                       forBarMetrics:UIBarMetricsDefault];
}

- (void) setNavigationBarBackgroundImageLandscapePhone:(UIImage *)navigationBarBackgroundImageLandscapePhone
{
    _navigationBarBackgroundImageLandscapePhone = navigationBarBackgroundImageLandscapePhone;
    
    [[SBNavigationBar appearance] setBackgroundImage:_navigationBarBackgroundImageLandscapePhone
                                       forBarMetrics:UIBarMetricsLandscapePhone];
}

- (void) setBarButtonDoneImage:(UIImage *)barButtonDoneImage
{
    _barButtonDoneImage = barButtonDoneImage;
    
    [[SBBarButtonItem appearanceWhenContainedIn:[SBNavigationBar class], nil] setBackgroundImage:_barButtonDoneImage
                                            forState:UIControlStateNormal
                                               style:UIBarButtonItemStyleDone
                                          barMetrics:UIBarMetricsDefault];
    
}

- (void) setBarButtonDoneHighlightedImage:(UIImage *)barButtonDoneHighlightedImage
{
    _barButtonDoneHighlightedImage = barButtonDoneHighlightedImage;
    
    [[SBBarButtonItem appearanceWhenContainedIn:[SBNavigationBar class], nil] setBackgroundImage:_barButtonDoneHighlightedImage
                                            forState:UIControlStateHighlighted
                                               style:UIBarButtonItemStyleDone
                                          barMetrics:UIBarMetricsDefault];
    
}


- (void) setBarButtonImage:(UIImage *)barButtonImage
{
    _barButtonImage = barButtonImage;
    
    [[SBBarButtonItem appearanceWhenContainedIn:[SBNavigationBar class], nil] setBackgroundImage:_barButtonImage
                                            forState:UIControlStateNormal
                                          barMetrics:UIBarMetricsDefault];

}

- (void) setBarButtonHighlightedImage:(UIImage *)barButtonHighlightedImage
{
    _barButtonHighlightedImage = barButtonHighlightedImage;
    
    [[SBBarButtonItem appearanceWhenContainedIn:[SBNavigationBar class], nil] setBackgroundImage:_barButtonHighlightedImage
                                            forState:UIControlStateHighlighted
                                          barMetrics:UIBarMetricsDefault];
    
}

- (void) setBarButtonBackImage:(UIImage *)barButtonBackImage
{
    _barButtonBackImage = barButtonBackImage;

    [[SBBarButtonItem appearanceWhenContainedIn:[SBNavigationBar class], nil] setBackButtonBackgroundImage:_barButtonBackImage
                                                      forState:UIControlStateNormal
                                                    barMetrics:UIBarMetricsDefault];
}

- (void) setBarBackButtonHighlightedImage:(UIImage *)barBackButtonHighlightedImage
{
    _barBackButtonHighlightedImage = barBackButtonHighlightedImage;
    
    [[SBBarButtonItem appearanceWhenContainedIn:[SBNavigationBar class], nil] setBackButtonBackgroundImage:_barBackButtonHighlightedImage
                                                      forState:UIControlStateHighlighted
                                                    barMetrics:UIBarMetricsDefault];
}

@end
