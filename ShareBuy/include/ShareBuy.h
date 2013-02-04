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

@class SBRoom;
@class SBContact;
@class SBFBContact;
@class SBCall;

/* The error domain of all error codes returned by S&B*/
extern NSString *SBErrorDomain;

/* This notification will be sent when S&B changes state. 
 A TShareBuyState value wrapped in a NSNumber will be passed*/
extern NSString *SBStatus;

/* This notification will be sent when S&B Error occurs.
 A NSError object with a TShareBuyError code*/
extern NSString *SBError;

/* This notification will be sent when the list of FB friends is updated*/
extern NSString *SBFBFriendsUpdate;

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
 and the NSNotifications will be sent. If not called, the Main Queue will be used. Stores a weak reference to the queue */
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

/* Returns the list of FB friends of the user. Each friend will be a SBContact object*/
- (NSArray *) getFacebookContactsSorted:(BOOL)sorted;

- (SBFBContact *) userFacebookRepresentation;

/* If a Redirect URL suffix is set in this application, please provide it here*/
- (void) setFacebookRedirectURLSuffix:(NSString *)suffix;

/******S&B API******/

/* Returns the list of S&B rooms of this user. Each room will be a SBRoom object*/
- (NSArray *) getRooms;

/* Creates a room with the given contact. Will use the FB-ID to process the invitation
 The completion block will be executed when the invitation has been sent*/
- (SBRoom *) createRoomInviteUser:(SBFBContact *)contact
                  completionBlock:(SBRequestCompletionBlock)completionBlock;

/* Creates a room with the given email
 The completion block will be executed when the invitation has been sent*/
- (SBRoom *) createRoomInviteUserWithMail:(NSString *)mail
                          completionBlock:(SBRequestCompletionBlock)completionBlock;

/* Requests if there are available rooms with the given user. Will use the FB-ID to process the request
 The completion block will return the requested SBRoom */
- (NSString *) getRoomWithUser:(SBFBContact *)contact
               completionBlock:(SBRequestCompletionBlock)completionBlock;

/* Requests if there are available rooms with the given mail
 The completion block will return the requested SBRoom */
- (NSString *) getRoomWithUserUserMail:(NSString *)mail
                       completionBlock:(SBRequestCompletionBlock)completionBlock;

/* TEST PRODUCTION ENVRIOMENT*/
- (void) setTestEnvironment;

@end
