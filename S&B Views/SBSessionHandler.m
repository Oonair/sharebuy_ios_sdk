//
//  SBSessionHandler.m
//  eshop
//
//  Created by Pierluigi Cifani on 12/10/12.
//  Copyright (c) 2013 Oonair. All rights reserved.
//

#import "SBSessionHandler.h"
#import "IIViewDeckController.h"

#import "SBMainViewController.h"
#import "SBRoomViewController.h"
#import "SBRoomViewController_Pad.h"

#import "SBWelcomeViewController.h"
#import "SBConnectionViewController.h"
#import "SBNavigationController.h"
#import "SBBarButtonItem.h"

#import "SBProductContainer.h"

#import "SBRemoteEventHandler.h"

//From S&B
#import "ShareBuy.h"
#import "SBRoom.h"

#define kButtonImage [UIImage imageNamed:@"bt-launch"]

NSString *SBViewDidAppear       = @"SBViewDidAppear";
NSString *SBViewDidDisappear    = @"SBViewDidDisappear";

@interface SBSessionHandler ()
{
    ShareBuy *shareBuy;
    TShareBuyState shareBuyState;
}

@property (nonatomic, strong) UIViewController *currentViewController;
@property (nonatomic, strong) SBNavigationController *currentNavigationController;

@property (nonatomic, strong) SBBarButtonItem *button;

@property (nonatomic, weak) id <SBViewContainerProtocol> delegate;

@end

@implementation SBSessionHandler

+ (id)sharedHandler
{
    static dispatch_once_t onceToken;
    static SBSessionHandler *sharedMyInstance = nil;
    
    dispatch_once(&onceToken, ^{
        sharedMyInstance = [[self alloc] init];
    });
    return sharedMyInstance;
}

- (void) startWithAccountID:(NSString *)accountID
                mobileAppID:(NSString *)mobileAppID;
{
    shareBuy = [ShareBuy sharedInstance];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onSBStatus:)
                                                 name:SBStatusNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onSBError:)
                                                 name:SBErrorNotification
                                               object:nil];
#ifdef DEBUG
    [shareBuy setTestEnvironment];
#endif
    
    [shareBuy startWithAccountID:accountID
                     mobileAppID:mobileAppID];
    
    //Create Button
    self.button = [SBBarButtonItem buttonWithTarget:self
                                             action:@selector(onButtonTapped)
                                              image:kButtonImage];

    //Start the other modules
    [SBProductContainer sharedContainer];
    [[SBRemoteEventHandler sharedHandler] setRoomNavigationDelegate:self];
    [[SBRemoteEventHandler sharedHandler] setViewProviderDelegate:self];
    
    //Clear notifications from Notification center
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

#pragma mark API

- (void) setViewContainerDelegate:(id <SBViewContainerProtocol>) delegate;
{
    self.delegate = delegate;
    [[SBRemoteEventHandler sharedHandler] setViewContainerDelegate:delegate];
}

- (BOOL) handleOpenFromURL:(NSURL *)url;
{
    return [shareBuy handleOpenFromURL:url];
}

- (void) handleDidBecomeActive;
{
    [shareBuy handleDidBecomeActive];
}

- (void) handleAppWillTerminate;
{
    [shareBuy handleAppWillTerminate];
}

- (void) setAppPushToken:(NSData *)token;
{
    [shareBuy setAppPushToken:token];
}

#pragma mark SBRoomNavigationProtocol

- (SBRoom *) currentRoom;
{
    return [self.currentNavigationController currentRoom];
}

- (SBRoomViewController *) navigateToRoom:(SBRoom *)desideredRoom;
{
    UIViewController *topViewController = [_currentNavigationController topViewController];
    
    if ([topViewController isKindOfClass:[SBRoomViewController class]]) {
        SBRoomViewController *roomController = (SBRoomViewController *) topViewController;
        if (roomController.room == desideredRoom)
        {
            //The desired room is already being shown, just return
            return roomController;
        }
    }

    [_currentNavigationController popToRootViewControllerAnimated:NO];

    SBRoomViewController *newRoomViewController;
    
    if (INTERFACE_IS_PAD) {
        newRoomViewController = [[SBRoomViewController_Pad alloc] initWithRoom:desideredRoom
                                                                        userID:[shareBuy userID]];
    } else {
        newRoomViewController = [[SBRoomViewController alloc] initWithRoom:desideredRoom
                                                                    userID:[shareBuy userID]];
    }
    
    [_currentNavigationController pushViewController:newRoomViewController animated:YES];
    
    if ([_delegate isShareBuyVisible] == NO) {
        [_delegate showShareBuy];
    }
    
    return newRoomViewController;
}

#pragma mark SBViewProviderProtocol

- (SBBarButtonItem *) getShareBuyButton;
{
    return _button;
}

- (UIViewController *) getShareBuyViewController;
{
    return _currentNavigationController;
}

- (void) shareBuyDidAppear;
{
    [[NSNotificationCenter defaultCenter] postNotificationName:SBViewDidAppear
                                                        object:nil];
}
- (void) shareBuyDidDisappear;
{
    [[NSNotificationCenter defaultCenter] postNotificationName:SBViewDidDisappear
                                                        object:nil];
}

#pragma mark SB Notifications

- (void)onSBError:(NSNotification *)notification
{
    NSError *nsError = notification.object;
    
    TShareBuyError error = nsError.code;
    
    NSString *errorMessage = nil;
    
    switch (error) {
            
        case ESBApiUnreachable:
            errorMessage = @"API Unreachable";
            break;
            
        case ESBPushFailed:

#if TARGET_IPHONE_SIMULATOR
#else
            errorMessage = @"Push Notifications Failed";
#endif
            break;
            
        case ESBXmppUnreachable:
            errorMessage = @"XMPP disconnected";
            break;
    }
    
    if (errorMessage) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR"
                                                         message:errorMessage
                                                        delegate:nil
                                               cancelButtonTitle:@"Dismiss"
                                               otherButtonTitles:nil];
        [alert show];
    }
}

- (void)onSBStatus:(NSNotification *)notification
{
    shareBuyState = [[ShareBuy sharedInstance] getShareBuyState];
    
    switch (shareBuyState) {
        case ESBStateIdle:
            break;
            
        case ESBStateWaitingFBLogin:
        {
            [self createWelcomeView];
        }
            break;
            
        case ESBStateAuthenticating:
        {
            [self createConnectionViewWithState:EStateConnecting];
        }
            break;
            
        case ESBStateOffline:
        {
            [self createConnectionViewWithState:EStateOffline];
        }
            break;

        case ESBStateOnline:
        {
            [self createMainChatView];
        }
            break;

        default:
            break;
    }
}

#pragma mark Internal

- (void)onButtonTapped
{
    if ([self.delegate isShareBuyAvailable])
    {
        if ([self.delegate isShareBuyVisible])
        {
            [self.delegate hideShareBuy];
        }
        else
        {
            [self.delegate showShareBuy];
        }
    }
}

- (void) setViewControllerInContainer:(UIViewController *)controller
{
    [self.delegate setShareBuyViewController:controller];
}

- (void) createMainChatView
{
    SBMainViewController *mainController = [[SBMainViewController alloc] init];
    SBNavigationController *navController = [[SBNavigationController alloc] initWithRootViewController:mainController];
   
    self.currentViewController = mainController;
    self.currentNavigationController = navController;
    
    [self setViewControllerInContainer:navController];
}

- (void) createWelcomeView
{
    SBWelcomeViewController *welcome = [[SBWelcomeViewController alloc] init];
    SBNavigationController *navController = [[SBNavigationController alloc] initWithRootViewController:welcome];
    
    self.currentViewController = welcome;
    self.currentNavigationController = navController;
    
    [self setViewControllerInContainer:navController];
}

- (void) createConnectionViewWithState:(TConnectionViewState)aState
{
    if ([self.currentViewController isKindOfClass:[SBConnectionViewController class]])
    {
        [(SBConnectionViewController *) self.currentViewController setCurrentState:aState];
    }
    else
    {
        SBConnectionViewController *errorController = [[SBConnectionViewController alloc] initWithState:aState];
        SBNavigationController *navController = [[SBNavigationController alloc] initWithRootViewController:errorController];
       
        self.currentViewController = errorController;
        self.currentNavigationController = navController;
        
        [self setViewControllerInContainer:navController];
    }
}

@end
