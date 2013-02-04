//
//  SBRoom.h
//
//  Created by Pierluigi Cifani on 26/11/12.
//  Copyright (c) 2012 Pierluigi Cifani. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SBRequestProtocol.h"

@class SBContact;
@class SBFBContact;
@class SBProduct;
@class SBEventMessage;

extern NSString *SBRoomStatusNotification;
extern NSString *SBRoomMessageNotification;
extern NSString *SBRoomEventNotification;
extern NSString *SBRoomProductNotification;
extern NSString *SBRoomContactNotification;

typedef enum  {
    ERoomStateIdle = 0,
    ERoomStateLoading,
    ERoomStateReady,
    ERoomStateDeleting
} TRoomState;

@interface SBRoom : NSObject <SBRequestProtocol>

@property (nonatomic, strong) NSString *ID;

- (BOOL) isRoomReady;

- (TRoomState) getRoomState;

- (void) enterRoom;
- (void) leaveRoom;

- (NSString *) sendMessage:(NSString *)message
           completionBlock:(SBRequestCompletionBlock)completionBlock;

- (NSString *) inviteContactUsingMail:(NSString *)contactMail
                      completionBlock:(SBRequestCompletionBlock)completionBlock;

- (NSString *) inviteContact:(SBFBContact *)contact
             completionBlock:(SBRequestCompletionBlock)completionBlock;

- (NSString *) shareProduct:(SBProduct *)product
            completionBlock:(SBRequestCompletionBlock)completionBlock;

- (NSString *) likeProduct:(SBProduct *)product
           completionBlock:(SBRequestCompletionBlock)completionBlock;

- (NSString *) stopLikeProduct:(SBProduct *)product
               completionBlock:(SBRequestCompletionBlock)completionBlock;

- (void) exitRoomPermanently:(SBRequestCompletionBlock)completionBlock;

- (void) userIsWritingMessage;

- (NSArray *) getRoomMessages;
- (SBEventMessage *) lastMessage;

- (NSArray *) getRoomEvents;

- (NSArray *) getRoomProducts;

- (NSArray *) getRoomContacts;

- (NSString *) getRoomContactsStringRepresentation;

- (SBContact *) getContactForUserID:(NSString *)userID;
- (SBProduct *) getProductForID:(NSString *)productID;

- (NSInteger) pendingMessages;
- (NSInteger) pendingEvents;

- (NSDate *) lastAccess;

@end
