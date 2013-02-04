//
//  SBViewProtocols.h
//  eshop
//
//  Created by Pierluigi Cifani on 1/30/13.
//  Copyright (c) 2013 Pierluigi Cifani. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SBRoom;
@class SBRoomViewController;

@protocol SBViewContainerProtocol <NSObject>

- (void) showShareBuy;
- (void) hideShareBuy;
- (BOOL) isShareBuyVisible;
- (BOOL) isShareBuyAvailable;
- (void) setShareBuyViewController:(UIViewController *)viewController;

@end

@protocol SBRoomNavigationProtocol <NSObject>

- (SBRoom *) currentRoom;
- (SBRoomViewController *) navigateToRoom:(SBRoom *)room;

@end

@protocol SBViewProviderProtocol <NSObject>

- (UIBarButtonItem *) getShareBuyButton;
- (UIViewController *) getShareBuyViewController;

@end
