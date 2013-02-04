//
//  AppDelegate.m
//  eshop
//
//  Created by Pierluigi Cifani on 28/11/12.
//  Copyright (c) 2012 Pierluigi Cifani. All rights reserved.
//

#import "AppDelegate.h"

// Shop Module
#import "ProductGridViewController.h"

// S&B Module
#import "SBSessionHandler.h"

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

#pragma mark Internal

- (void) setUpShareBuy
{
    self.shareBuyHandler = [SBSessionHandler sharedHandler];
    [self.shareBuyHandler setViewContainerDelegate:self];

    [self.shareBuyHandler startWithAccountID:@"upo2w2h2laas"
                                 mobileAppID:@"q1opwe"];
}

- (UIViewController *) setUpViews
{
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
    UIViewController *productGrid = [[ProductGridViewController alloc] init];
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
