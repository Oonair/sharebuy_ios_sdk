//
//  SBSessionHandler.h
//  eshop
//
//  Created by Pierluigi Cifani on 12/10/12.
//  Copyright (c) 2012 Pierluigi Cifani. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBViewProtocols.h"

@class SBRoom;

@interface SBSessionHandler : NSObject <SBViewProviderProtocol, SBRoomNavigationProtocol>

+ (id) sharedHandler;

- (void) startWithAccountID:(NSString *)accountID
                mobileAppID:(NSString *)mobileAppID;

- (void) setViewContainerDelegate:(id <SBViewContainerProtocol>) delegate;

- (void) setAppPushToken:(NSData *)token;
- (BOOL) handleOpenFromURL:(NSURL *)url;
- (void) handleDidBecomeActive;
- (void) handleAppWillTerminate;

@end
