//
//  SBSessionHandler.m
//  eshop
//
//  Created by Pierluigi Cifani on 12/10/12.
//  Copyright (c) 2012 Pierluigi Cifani. All rights reserved.
//

#import "SBSessionHandler.h"
#import "IIViewDeckController.h"

#import "SBMainViewController.h"
#import "SBRoomViewController.h"
#import "SBRoomViewController_Pad.h"

#import "SBConnectionViewController.h"
#import "SBNavigationController.h"

#import "SBCurrentProductContainer.h"

#import "SBRemoteEventHandler.h"

//From S&B
#import "ShareBuy.h"
#import "SBRoom.h"


@interface SBSessionHandler ()
{
    ShareBuy *shareBuy;
    TShareBuyState shareBuyState;
}

@property (nonatomic, strong) UIViewController *currentViewController;
@property (nonatomic, strong) UINavigationController *currentNavigationController;

@property (nonatomic, strong) UIBarButtonItem *button;

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
                                                 name:SBStatus
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onSBError:)
                                                 name:SBError
                                               object:nil];

    [shareBuy setTestEnvironment];

    [shareBuy startWithAccountID:accountID
                     mobileAppID:mobileAppID];
    
    //Create Button
    self.button = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bt-launch"]
                                                    style:UIBarButtonItemStylePlain
                                                   target:self
                                                   action:@selector(onButtonTapped)];

    //Start this just so they can hear notifications
    [SBCurrentProductContainer sharedContainer];
    [[SBRemoteEventHandler sharedHandler] setRoomNavigationDelegate:self];
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
    UIViewController *topViewController = [_currentNavigationController topViewController];
    if ([topViewController isKindOfClass:[SBRoomViewController class]])
    {
        SBRoomViewController *roomViewController = (SBRoomViewController *) topViewController;
        return roomViewController.room;
    }
    
    return nil;
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

- (UIBarButtonItem *) getShareBuyButton;
{    
    return _button;
}

- (UIViewController *) getShareBuyViewController;
{
    return _currentNavigationController;
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
            [self createConnectionViewWithState:EStateConnectToFacebook];
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