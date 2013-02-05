//
//  ShareBuy.h
//  SBSDK
//
//  Created by Pierluigi Cifani on 28/11/12.
//  Copyright (c) 2012 Pierluigi Cifani. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#ifdef SBDEVEL
#import "SBXmpp/SBRequestProtocol.h"
#else
#import "SBRequestProtocol.h"
#endif

/**
 @class ShareBuy
 
 @brief This class represents the main entry point to all ShareBuy functionality.
 
 This class uses the singleton design pattern, use the sharedInstance method to get the instance.
 
 Use this class to init the S&B stack with your Account and App ID, to 
 login and logout from Facebook and get a representation of your friends, and
 to start Chat Rooms with your friends.  
 
 **/

@class SBRoom;
@class SBContact;
@class SBFBContact;

/* The error domain of all error codes returned by S&B*/
extern NSString *SBErrorDomain;

/* This notification will be sent when S&B changes state. 
 A TShareBuyState value wrapped in a NSNumber will be passed*/
extern NSString *SBStatusNotification;

/* This notification will be sent when S&B Error occurs.
 A NSError object with a TShareBuyError code*/
extern NSString *SBErrorNotification;

/* This notification will be sent when the list of FB friends is updated*/
extern NSString *SBFBFriendsUpdateNotification;

/* This notification will be sent when S&B receives an invitaion to a new room.
 A SBRoom will be passed*/
extern NSString *SBInvitation;

/* States for the S&B singleton*/
typedef enum  TShareBuyState{
    /* Singleton is initialized, waiting for startWithClientID: 
     message to be sent*/
    ESBStateIdle = 0,
    
    /* No Previous FB Session was found, waiting for loginFacebook
     message to be sent*/
    ESBStateWaitingFBLogin,
    
    /* Authenticating with S&B platform*/
    ESBStateAuthenticating,
    
    /* No Internet connection available*/
    ESBStateOffline,
    
    /* Succesfully connected to the S&B platform*/
    ESBStateOnline
} TShareBuyState;

/* Error code for the all the errors sent by S&B*/
typedef enum  TShareBuyError {
    
    /* Couldn't get valid credentials from S&B API*/
    ESBApiUnreachable = 0,
    
    /* Couldn't connect to S&B instant message servers*/
    ESBXmppUnreachable,
    
    /* Error initializing Push Notification Support*/
    ESBPushFailed
} TShareBuyError;

@interface ShareBuy : NSObject <SBRequestProtocol>

+ (id) sharedInstance;

/* Sets the Queue where the completion blocks will be called 
 and the NSNotifications will be sent. If not called, the Main Queue will be used.
 Stores a weak reference to the queue */
- (void) setDelegateQueue:(dispatch_queue_t)queue;

/* Start the Module with the given ClientID obtained from oonair.com*/
- (void) startWithAccountID:(NSString *)accountID
                mobileAppID:(NSString *)mobileID;

/* Please forward the token provided by the system in these AppDelegate methods using this message:
 - (void)application:didRegisterForRemoteNotificationsWithDeviceToken:
 - (void)application:didFailToRegisterForRemoteNotificationsWithError: */
- (void) setAppPushToken:(NSData *)pushToken;

/* Please forward the URL provided by the system in this AppDelegate method:
 - (BOOL)application:openURL:sourceApplication:annotation:*/
- (BOOL) handleOpenFromURL:(NSURL *)url;
- (void) handleDidBecomeActive;
- (void) handleAppWillTerminate;

/* Gets the current S&B state*/
- (TShareBuyState) getShareBuyState;

/* Attempts reconnection in case of a network loss*/
- (void) attemptReconnection;

/* Returns the unique S&B ID of the user.*/
- (NSString *) userID;

/******Facebook Support******/

/* Starts the FB login process*/
- (void) loginFacebook;

/* Logs out from FB*/
- (void) logoutFacebook;

/* Returns the list of FB friends of the user. Each friend will be a SBFBContact object*/
- (NSArray *) getFacebookContactsSorted:(BOOL)sorted;

- (SBFBContact *) userFacebookRepresentation;

/* If a Redirect URL suffix is set in this application, please provide it here*/
- (void) setFacebookRedirectURLSuffix:(NSString *)suffix;

// Returns an NSArray populated with the active rooms of this user. (SBRoom instances)
- (NSArray *) getRooms;

/* Requests:
 
 The following methods are used to trigger requests to S&B servers.
 All of these methods are asynchronous methods
 Completion blocks will be executed when the request is completed
 They can be cancelled using the messages defined in @protocol(SBRequestProtocol)
 */

/**
 * Creates a room with the given contact. Will use the FB-ID to process the invitation
 *
 * @param 'contact' A SBFBContact representing the contact to be invited
 * @param 'completionBlock' Block to be executed when the invitation is sent.
 * @block param 'response' An instance of SBContact representing the contact just invited
 * @block param 'error' An instance of NSError representing the error generated
 * @return A SBRoom representing the created Chat Room.
 */

- (SBRoom *) createRoomInviteUser:(SBFBContact *)contact
                  completionBlock:(SBRequestCompletionBlock)completionBlock;

/**
 * Creates a room with the given email. Will use email to process the invitation
 *
 * @param 'mail' A NSString representing the email of the contact to be invited
 * @param 'completionBlock' Block to be executed when the invitation is sent.
 * @block param 'response' An instance of SBContact representing the contact just invited
 * @block param 'error' An instance of NSError representing the error generated
 * @return A SBRoom representing the created Chat Room.
 */
- (SBRoom *) createRoomInviteUserWithMail:(NSString *)mail
                          completionBlock:(SBRequestCompletionBlock)completionBlock;

/**
 * Requests if there are available rooms with the given user
 *
 * @param 'contact' A SBFBContact representing the contact to query the servers
 * @param 'completionBlock' Block to be executed when the request is complete.
 * @block param 'response' A NSArray with the SBRooms availables with this user
 * @block param 'error' An instance of NSError representing the error generated
 * @return A NSString representing the requestID of this action.
 */

- (NSString *) getRoomWithUser:(SBFBContact *)contact
               completionBlock:(SBRequestCompletionBlock)completionBlock;

/**
 * Requests if there are available rooms with the given email
 *
 * @param 'mail' A NSString representing the email of the contact to query the servers
 * @param 'completionBlock' Block to be executed when the request is complete.
 * @block param 'response' A NSArray with the SBRooms availables with this user
 * @block param 'error' An instance of NSError representing the error generated
 * @return A NSString representing the requestID of this action.
 */
- (NSString *) getRoomWithUserUserMail:(NSString *)mail
                       completionBlock:(SBRequestCompletionBlock)completionBlock;

/* TEST PRODUCTION ENVRIONMENT*/
- (void) setTestEnvironment;

@end
