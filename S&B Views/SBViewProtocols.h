//
//  SBViewProtocols.h
//  eshop
//
//  Created by Pierluigi Cifani on 1/30/13.
//  Copyright (c) 2013 Oonair. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SBRoom;
@class SBRoomViewController;

extern NSString *SBViewDidAppear;
extern NSString *SBViewDidDisappear;

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

@protocol SBViewProtocol <NSObject>

- (void) shareBuyDidAppear;
- (void) shareBuyDidDisappear;

@end
