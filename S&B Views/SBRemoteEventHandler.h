//
//  SBEventHandler.h
//  eshop
//
//  Created by Pierluigi Cifani on 1/29/13.
//  Copyright (c) 2013 Pierluigi Cifani. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBViewProtocols.h"

@interface SBRemoteEventHandler : NSObject

+ (id)sharedHandler;

- (void) setRoomNavigationDelegate:(id <SBRoomNavigationProtocol>)delegate;
- (void) setViewContainerDelegate:(id <SBViewContainerProtocol>)delegate;

@end
