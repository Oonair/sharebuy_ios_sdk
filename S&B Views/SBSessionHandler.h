//
//  SBSessionHandler.h
//  eshop
//
//  Created by Pierluigi Cifani on 12/10/12.
//  Copyright (c) 2013 Oonair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBViewProtocols.h"

@class SBRoom;

@interface SBSessionHandler : NSObject <SBViewProviderProtocol, SBRoomNavigationProtocol, SBViewProtocol>

+ (instancetype) sharedHandler;

- (void) startWithAccountID:(NSString *)accountID
                mobileAppID:(NSString *)mobileAppID;

- (void) setViewContainerDelegate:(id <SBViewContainerProtocol>) delegate;

//From UIAppDelegate
- (void) setAppPushToken:(NSData *)token;
- (BOOL) handleOpenFromURL:(NSURL *)url;
- (void) handleDidBecomeActive;
- (void) handleAppWillTerminate;
- (void) handlePushNotification:(NSDictionary *)pushNotification;

@end
