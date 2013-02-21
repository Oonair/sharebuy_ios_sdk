//
//  SBEventHandler.h
//  eshop
//
//  Created by Pierluigi Cifani on 1/29/13.
//  Copyright (c) 2013 Oonair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBViewProtocols.h"

@interface SBRemoteEventHandler : NSObject

+ (instancetype)sharedHandler;

- (NSInteger)roomsWithPendingEvents;

- (void) setRoomNavigationDelegate:(id <SBRoomNavigationProtocol>)delegate;
- (void) setViewContainerDelegate:(id <SBViewContainerProtocol>)delegate;
- (void) setViewProviderDelegate:(id <SBViewProviderProtocol>)delegate;

@end
