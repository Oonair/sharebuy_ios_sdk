//
//  AppDelegate.m
//  eshop
//
//  Created by Pierluigi Cifani on 28/11/12.
//  Copyright (c) 2013 Oonair. All rights reserved.
//

#import "AppDelegate.h"

// Shop Module
#import "ProductCategoriesViewController.h"
#import "ProductCategoriesViewController_Pad.h"

// S&B Module
#import "SBSessionHandler.h"
#import "SBCustomizer.h"

// Vendor
#import "IIViewDeckController.h" //Component available at: https://github.com/piercifani/ViewDeck

@interface AppDelegate () <IIViewDeckControllerDelegate, SBViewContainerProtocol>

@property (nonatomic, strong) SBSessionHandler *shareBuyHandler;
@property (nonatomic, strong) IIViewDeckController *viewDeck;
@property (nonatomic, strong) UIPopoverController *popoverController;

@end

@implementation AppDelegate 


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    [self setUpShareBuy];

    self.window.rootViewController = [self setUpViews];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:	(id)annotation
{
    return [self.shareBuyHandler handleOpenFromURL:url];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [self.shareBuyHandler setAppPushToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    [self.shareBuyHandler setAppPushToken:nil];
}

#pragma mark IIViewDeckControllerDelegate

- (BOOL)viewDeckControllerWillOpenRightView:(IIViewDeckController*)viewDeckController animated:(BOOL)animated;
{
    return YES;
}

- (BOOL)viewDeckControllerWillCloseRightView:(IIViewDeckController*)viewDeckController animated:(BOOL)animated;
{
    return YES;
}

- (void)viewDeckControllerDidOpenRightView:(IIViewDeckController*)viewDeckController animated:(BOOL)animated;
{
    //Block interaction on the Center view so user doesn't produce un-intended touches
    UINavigationController *centerController = (UINavigationController *) self.viewDeck.centerController;
    centerController.topViewController.view.userInteractionEnabled = NO;
    
    [self.shareBuyHandler shareBuyDidAppear];
}

- (void)viewDeckControllerDidCloseRightView:(IIViewDeckController*)viewDeckController animated:(BOOL)animated;
{
    //Reenable interaction on the Center view so user can use this view
    UINavigationController *centerController = (UINavigationController *) self.viewDeck.centerController;
    centerController.topViewController.view.userInteractionEnabled = YES;
    
    [self.shareBuyHandler shareBuyDidDisappear];
}

#pragma mark Internal

- (void) customizeShareBuy
{
    // First, Navigation bars
    UIImage *navBarImage = [[UIImage imageNamed:@"bg-navigation-big"]
                            resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 3, 0)];
    
    UIImage *navBarImageSmall = [[UIImage imageNamed:@"bg-navigation-small"]
                            resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 3, 0)];

    SBCustomizer *customizer = [SBCustomizer sharedCustomizer];
    
    [customizer setNavigationBarBackgroundImage:navBarImage];
    
    [customizer setNavigationBarBackgroundImageLandscapePhone:navBarImageSmall];

    // Second, BackButtons
    UIImage *buttonBack = [[UIImage imageNamed:@"bt-back"]
                             resizableImageWithCapInsets:UIEdgeInsetsMake(0, 13, 0, 5)];
    
    UIImage *buttonBackHigh = [[UIImage imageNamed:@"bt-back-high"]
                               resizableImageWithCapInsets:UIEdgeInsetsMake(0, 13, 0, 5)];

    [customizer setBarButtonBackImage:buttonBack];
    
    [customizer setBarBackButtonHighlightedImage:buttonBackHigh];

    // Third, BarButtons
    UIImage *barButton = [[UIImage imageNamed:@"bt-round"]
                           resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
    
    UIImage *barButtonHigh = [[UIImage imageNamed:@"bt-round-over"]
                               resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
    
    [customizer setBarButtonImage:barButton];
    [customizer setBarButtonHighlightedImage:barButtonHigh];
    
    
    UIImage *barDoneButton = [[UIImage imageNamed:@"bt-facebook"] resizableImageWithCapInsets:UIEdgeInsetsMake(17, 5, 17, 5)];
    
    UIImage *barDoneButtonHigh = [[UIImage imageNamed:@"bt-facebook-over"] resizableImageWithCapInsets:UIEdgeInsetsMake(17, 5, 17, 5)];
    
    [customizer setBarButtonDoneImage:barDoneButton];
    [customizer setBarButtonDoneHighlightedImage:barDoneButtonHigh];

    
    // Fourth, tableHeader
    [customizer setTableHeaderColor:[UIColor colorWithRed:157/255.0
                                                    green:165/255.0
                                                     blue:162/255.0
                                                    alpha:1]];
}

- (void) setUpShareBuy
{
    [self customizeShareBuy];
    
    self.shareBuyHandler = [SBSessionHandler sharedHandler];
    [self.shareBuyHandler setViewContainerDelegate:self];

#ifdef DEBUG
    [self.shareBuyHandler startWithAccountID:@"upo2w2h2laas"
                                 mobileAppID:@"q1opwe"];
#else
    [self.shareBuyHandler startWithAccountID:@"b69rbqhkfu6c"
                                 mobileAppID:@"m5uOco"];
#endif
}

- (void) customizeElements
{    
    UIImage *gradientImage44 = [[SBCustomizer sharedCustomizer] navigationBarBackgroundImage];
    
    UIImage *gradientImage32 = [[SBCustomizer sharedCustomizer] navigationBarBackgroundImageLandscapePhone];

    UIImage *barButton = [[SBCustomizer sharedCustomizer] barButtonImage];
    
    UIImage *barButtonHigh = [[SBCustomizer sharedCustomizer] barButtonHighlightedImage];
    
    UIImage *backButton = [[SBCustomizer sharedCustomizer] barButtonBackImage];

    UIImage *backButtonHigh = [[SBCustomizer sharedCustomizer] barBackButtonHighlightedImage];

    [[UINavigationBar appearance] setBackgroundImage:gradientImage44
                                       forBarMetrics:UIBarMetricsDefault];
    
    [[UINavigationBar appearance] setBackgroundImage:gradientImage32
                                       forBarMetrics:UIBarMetricsLandscapePhone];

    [[UIBarButtonItem appearance] setBackgroundImage:barButton
                                            forState:UIControlStateNormal
                                          barMetrics:UIBarMetricsDefault];
    
    [[UIBarButtonItem appearance] setBackgroundImage:barButtonHigh
                                            forState:UIControlStateHighlighted
                                          barMetrics:UIBarMetricsDefault];

    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backButton
                                                      forState:UIControlStateNormal
                                                    barMetrics:UIBarMetricsDefault];
    
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backButtonHigh
                                                      forState:UIControlStateHighlighted
                                                    barMetrics:UIBarMetricsDefault];
    
    //Customize UINavigationBar
    [[UINavigationBar appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor whiteColor],
      UITextAttributeTextColor,
      [UIColor clearColor],
      UITextAttributeTextShadowColor,
      nil]];
}

- (UIViewController *) setUpViews
{
    [self customizeElements];
    
    if (INTERFACE_IS_PHONE) {
        return [self setUpViewsPhone];
    } else {
        return [self setUpViewsPad];
    }
}

- (UIViewController *) setUpViewsPad
{
    UINavigationController *storeNavigation = [self createProductGrid];

    self.popoverController = [[UIPopoverController alloc] initWithContentViewController:[self.shareBuyHandler getShareBuyViewController]];
    _popoverController.popoverBackgroundViewClass = [SBPopoverBackgroundView class];

    
    [self.popoverController setPassthroughViews:@[storeNavigation.view]];
    return storeNavigation;
}

- (UIViewController *) setUpViewsPhone
{
    UINavigationController *storeNavigation = [self createProductGrid];

    UIViewController *shareBuyVC = [self.shareBuyHandler getShareBuyViewController];
    IIViewDeckController *deckController =  [[IIViewDeckController alloc] initWithCenterViewController:storeNavigation
                                                                                    rightViewController:shareBuyVC];
    deckController.rightLedge = 50;
    deckController.delegate = self;
    
    self.viewDeck = deckController;
    
    return deckController;
}


- (UINavigationController *)createProductGrid
{
    UIViewController *productGrid;
    if (INTERFACE_IS_PHONE)
    {
        productGrid = [[ProductCategoriesViewController alloc] init];
    }
    else
    {
        productGrid = [[ProductCategoriesViewController_Pad alloc] init];
    }
    
    UINavigationController *storeNavigation = [[UINavigationController alloc] initWithRootViewController:productGrid];
    return storeNavigation;
}

#pragma mark SBViewContainerProtocol

- (void) showShareBuy;
{
    if (INTERFACE_IS_PHONE)
    {
        [self.viewDeck openRightViewAnimated:YES];
    } else
    {
        [self.popoverController presentPopoverFromBarButtonItem:[self.shareBuyHandler getShareBuyButton]
                                       permittedArrowDirections:UIPopoverArrowDirectionUp
                                                       animated:YES];
        
        [self.shareBuyHandler shareBuyDidAppear];
    }
}
- (void) hideShareBuy;
{
    if (INTERFACE_IS_PHONE)
    {
        [self.viewDeck closeRightViewAnimated:YES];
    } else
    {
        [self.popoverController dismissPopoverAnimated:YES];
        
        [self.shareBuyHandler shareBuyDidDisappear];
    }
}

- (BOOL) isShareBuyVisible;
{
    if (INTERFACE_IS_PHONE)
    {
        return [self.viewDeck rightControllerIsOpen];
    } else
    {
        return [self.popoverController isPopoverVisible];
    }
}

- (BOOL) isShareBuyAvailable;
{
    // Return NO if in some cases (Like when the current
    // ViewController is the shopping cart) you want to disable it
    return YES;
}

- (void) setShareBuyViewController:(UIViewController *)viewController;
{
    if (INTERFACE_IS_PHONE)
    {
        [self.viewDeck setRightController:viewController];
    } else
    {
        [self.popoverController setContentViewController:viewController];
    }
}

@end
