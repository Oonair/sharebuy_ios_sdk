//
//  SBRoom.h
//
//  Created by Pierluigi Cifani on 26/11/12.
//  Copyright (c) 2012 Pierluigi Cifani. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SBRequestProtocol.h"

/**
 @class SBRoom
 
 @brief This class represents a S&B Chat Room.
 
 Use this class talk to a friend, share a product, like a product and invite more
 people to this Room.
 
 In order to receive updates of events of a room, register as an observer to the notification you
 are interested indicating the room you are interested in listening events, like this:
 
 [[NSNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(onSBRoomStatus:)
                                              name:SBRoomStatusNotification
                                            object:aRoom];
 **/

@class SBContact;
@class SBFBContact;
@class SBProduct;
@class SBEventMessage;

// This notification will be sent when the State of the Room changes.
extern NSString *SBRoomStatusNotification;

// This notification will be sent when a new message (please check the SBEventMessage class header)
// is received in the room.
extern NSString *SBRoomMessageNotification;

// This notification will be sent when a new message (please check the SBEvent class header)
// is received in the room.
extern NSString *SBRoomEventNotification;

// This notification will be sent when a new product is shared in the room
extern NSString *SBRoomProductNotification;

// This notification will be sent when a new contact joins the room
extern NSString *SBRoomContactNotification;

// This represents the state of the SBRoom object
typedef enum  TRoomState{
    // The room is correctly created, but invitations to the users still haven't been sent
    ERoomStateIdle = 0,
    
    // The room is fetching data from the server, not ready to use yet
    ERoomStateLoading,
    
    // The room is ready to use
    ERoomStateReady,
    
    // The room was requested to be deleted with the exitRoomPermanently message and the transaction with the server is ongoing
    ERoomStateDeleting
} TRoomState;

@interface SBRoom : NSObject <SBRequestProtocol>

@property (nonatomic, strong) NSString *ID;

// Returns whether the room is ready to be used.
// Requests done in this state are stored for being processed when possible
- (BOOL) isRoomReady;

// Returns the current state of this room
- (TRoomState) getRoomState;

// Please send this message when the Room-ViewController appears
- (void) enterRoom;

// Please send this message when the Room-ViewController dissappears
- (void) leaveRoom;

// Returns an array with the chronologically ordered messages (SBEventMessage instances)
- (NSArray *) getRoomMessages;

// Returns the last message received
- (SBEventMessage *) lastMessage;

// Returns an NSArray with the chronologically ordered events (SBEvent instances)
- (NSArray *) getRoomEvents;

// Returns an NSArray with the chronologically ordered products (SBProduct instances)
- (NSArray *) getRoomProducts;

// Returns the last shared product 
- (SBProduct *) lastSharedProduct;

// Returns an NSArray with the friends participating in this room (SBContact instances)
- (NSArray *) getRoomContacts;

// Returns a NSString with all the first names of the friends in this room
- (NSString *) getRoomContactsStringRepresentation;

// Returns the SBContact with the given userID. Returns nil if not found
- (SBContact *) getContactForUserID:(NSString *)userID;

// Returns the SBProduct with the given product. Returns nil if not found
- (SBProduct *) getProductForID:(NSString *)productID;

// Returns the number of unread messages
- (NSInteger) pendingMessages;

// Returns the number of unread events
- (NSInteger) pendingEvents;

// Returns a NSDate representing the last time the Room was accessed
- (NSDate *) lastAccess;

// Send this message when the user enters text into the UITextField in order
// to send a "Writing" message
- (void) userIsWritingMessage;

/* Requests:
 
 The following methods are used to trigger requests to S&B servers. 
 All of these methods are asynchronous methods
 Completion blocks will be executed when the request is completed
 They can be cancelled using the messages defined in @protocol(SBRequestProtocol) 
 */

/**
 * Send a message to the room
 *
 * @param 'message' A NSString representing the message to be sent
 * @param 'completionBlock' Block to be executed when the message is sent. 
 * @block param 'response' An instance of SBEventMessage representing the message just generated
 * @block param 'error' An instance of NSError representing the error generated
 * @return A NSString representing the requestID of this action.
 */

- (NSString *) sendMessage:(NSString *)message
           completionBlock:(SBRequestCompletionBlock)completionBlock;

/**
 * Invites a contact to the room using email
 *
 * @param 'contactMail' A NSString representing the user's email address
 * @param 'completionBlock' Block to be executed when the invitation is sent.
 * @block param 'response' An instance of SBContact representing the contact just invited
 * @block param 'error' An instance of NSError representing the error generated
 * @return A NSString representing the requestID of this action.
 */

- (NSString *) inviteContactUsingMail:(NSString *)contactMail
                      completionBlock:(SBRequestCompletionBlock)completionBlock;

/**
 * Invites a contact to the room using email
 *
 * @param 'contact' A SBFBContact representing the user's Facebook information
 * @param 'completionBlock' Block to be executed when the invitation is sent.
 * @block param 'response' An instance of SBContact representing the contact just invited
 * @block param 'error' An instance of NSError representing the error generated
 * @return A NSString representing the requestID of this action.
 */

- (NSString *) inviteContact:(SBFBContact *)contact
             completionBlock:(SBRequestCompletionBlock)completionBlock;

/**
 * Shares a product in the room
 *
 * @param 'product' A SBProduct instance of the product to be shared
 * @param 'completionBlock' Block to be executed when the product is shared.
 * @block param 'response' An instance of SBProduct representing the product just shared
 * @block param 'error' An instance of NSError representing the error generated
 * @return A NSString representing the requestID of this action.
 */

- (NSString *) shareProduct:(SBProduct *)product
            completionBlock:(SBRequestCompletionBlock)completionBlock;

/**
 * Likes a product in the room
 *
 * @param 'product' A SBProduct instance of the product to be liked
 * @param 'completionBlock' Block to be executed when the product is liked.
 * @block param 'response' An instance of SBProduct representing the product just shared with the updated 'like' values
 * @block param 'error' An instance of NSError representing the error generated
 * @return A NSString representing the requestID of this action.
 */

- (NSString *) likeProduct:(SBProduct *)product
           completionBlock:(SBRequestCompletionBlock)completionBlock;

/**
 * Stops liking a product the room
 *
 * @param 'product' A SBProduct instance of the product to be un-liked
 * @param 'completionBlock' Block to be executed when the product is un-liked.
 * @block param 'response' An instance of SBProduct representing the product just shared with the updated 'like' values
 * @block param 'error' An instance of NSError representing the error generated
 * @return A NSString representing the requestID of this action.
 */

- (NSString *) stopLikeProduct:(SBProduct *)product
               completionBlock:(SBRequestCompletionBlock)completionBlock;

/**
 * Exits a room permanently. This will destroy the room if you are the only person inside it.
 * This action CANNOT be cancelled.
 * @param 'completionBlock' Block to be executed when the room is permanently left.
 * @block param 'response' Will allways be nil
 * @block param 'error' An instance of NSError representing the error generated
 */

- (void) exitRoomPermanently:(SBRequestCompletionBlock)completionBlock;

@end
