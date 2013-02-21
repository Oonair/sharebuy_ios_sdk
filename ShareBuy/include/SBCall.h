//
//  SBCall.h
//
//  Created by Pierluigi Cifani on 1/21/13.
//  Copyright (c) 2013 Oonair. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef SBDEVEL
#import "SBXmpp/SBCallConstants.h"
#import "SBXmpp/SBRoom.h"
#else
#import "SBCallConstants.h"
#import "SBRoom.h"
#endif

@class SBContact;
@class SBRoom;
@class SBCall;

// This notification will be sent when a new call is received
extern NSString *SBRoomCallNotification;

// This the error domain for the  NSErrors passed by SBCall objects
extern NSString *SBRoomCallErrorDomain;

// This represents the error code for the NSError object passed in the SBCallRequestCompletionBlock for requests
typedef enum  TSBCallErrorCode {
    ESBErrorCallUnknown = 0,
    ESBErrorCallOngoing,
    ESBErrorNoParticipants,
    ESBErrorMaxParticipants,
    ESBErrorCallAuthentication,
    ESBErrorCallHardwareInitialization,
    ESBErrorCallServerUnreachable,
} TSBCallErrorCode;

/**
 @block SBCallRequestCompletionBlock
 
 @brief This block is the preferred way to handle responses to Call requests done to S&B objects. They will be executed when a response for the request is received.
 
 @param 'call' A SBCall object with the call initializated
 @param 'error' A NSError with a SBRoomCallErrorDomain, and an error code represented by TSBCallErrorCode
 
 **/
typedef void (^SBCallRequestCompletionBlock)(SBCall *call, NSError *error);

/**
 
 @category SBRoom (Call)
 
 @brief Adds methods to start calls in a SBRoom
 
 **/

@interface SBRoom (Call)

/**
 * Attempts to start a call in this room
 *
 * @param 'video' a BOOL value representing if video is available when starting the call
 * @param 'audio' a BOOL value representing if audio is available when starting the call
 * @param 'completionBlock' a SBCallRequestCompletionBlock to be executed when the call has started.
 */
- (void) startCallWithVideoEnabled:(BOOL)video
                      audioEnabled:(BOOL)audio
                   completionBlock:(SBCallRequestCompletionBlock)completionBlock;

/**
 * Returns the call in this room
 *
 * @return A SBCall object in case of an ongoing call in this SBRoom,
 * nil otherwise.
 */

- (SBCall *) currentCall;

@end

/**
 @protocol SBCallObserverProtocol
 @brief This protocol is designed to enable listening to call events
 **/

@protocol SBCallObserverProtocol <NSObject>

- (void) callDidTerminate;

- (void) callWillTerminateWithError:(NSError *)error;

@optional

/**
 * This message is sent each time a new frame is received and decoded 
 * from the video stream of remote users
 *
 * @param 'contact' A SBContact instance representing the contact that originated this frame
 * @param 'frame' A UIImage instance representing a frame of video.
 */
- (void) contact:(SBContact *)contact
    decodedFrame:(UIImage *)frame;

- (void) contactHasLeftCall:(SBContact *)contact
                 withReason:(TRejectReason)reason;

- (void) contactHasAnsweredCall:(SBContact *)contact;

- (void) userIsStreamingAudio:(BOOL)audio;

- (void) userIsStreamingVideo:(BOOL)video;

- (void) contactJoinedCall:(SBContact *)contact
          withAudioEnabled:(BOOL)audio
           andVideoEnabled:(BOOL)video;

- (void) contactChangedStream:(SBContact *)contact
             withAudioEnabled:(BOOL)audio
              andVideoEnabled:(BOOL)video;

- (void) userSignalStrenght:(NSInteger)percentage;

- (void) contact:(SBContact *)contact
  signalStrenght:(NSInteger)percentage;

@end


/**
 @class SBCall
 
 @brief This class represents a S&B Call. It encapsulates all the information and logic necessary to handle calls.
 
 Use this class to answer, reject or finish a call, toggling the audio and cameras, check who is in a call and more.
 
 In order to receive updates of events of new calls, register to the SBRoomCallNotification like this:
 
 [[NSNotificationCenter defaultCenter] addObserver:self
                                        selector:@selector(onSBRoomCall:)
                                            name:SBRoomCallNotification
                                          object:nil];
 
 - (void) onSBRoomCall:(NSNotification *)notification
 {
    SBCall *call = notification.object;
    SBRoom *callRoom = call.room;
    ...
 }
 
 **/

@interface SBCall : NSObject

/**
 * Attempts to hang the call represented by the instance
 * @return A BOOL value representing wheter the call could be hanged.
 */

- (BOOL) hangCall;

/**
 * Attempts to answer the call represented by the instance
 * @param 'video' a BOOL value representing if video is available when starting the call
 * @param 'audio' a BOOL value representing if audio is available when starting the call
 * @param 'completionBlock' a SBCallRequestCompletionBlock to be executed when the call has started.
 * @return A BOOL value representing wheter the call could be answered.
 */

- (BOOL) answerCallWithVideoEnabled:(BOOL)video
                       audioEnabled:(BOOL)audio
                    completionBlock:(SBCallRequestCompletionBlock)completionBlock;
/**
 * Attempts to answer the call represented by the instance
 * @param 'reason' a TRejectReason value representing the reason why the call couldn't be picked up
 * @return A BOOL value representing wheter the call could be rejected.
 */
- (BOOL) rejectCallWithReason:(TRejectReason)reason;

/**
 * Sets a UIImageView instance as the 'previewLayer', where the echo from the user's camera will be drawn
 * @param 'previewLayer' a UIImageView instance where to draw the echo from user's camera
 */
- (void) setPreviewLayer:(UIImageView *)previewLayer;

- (void) setVideoEnabled:(BOOL)videoEnabled;
- (void) setAudioEnabled:(BOOL)AudioEnabled;
- (void) toggleCameraPosition;

// Use this property to set the observer of the call
@property (nonatomic, weak) id <SBCallObserverProtocol> observer;

// Use this property to get user's role in this call
@property (nonatomic, readonly) TCallRole role;

// Use this property to get call's stage
@property (nonatomic, readonly) TCallStage stage;

// Use this property to get call's caller. It will return nil if the user role is ECallRoleCaller
@property (nonatomic, readonly) SBContact *caller;

// Returns an array of SBContacts that are participating in a call
@property (nonatomic, readonly) NSArray *participants;

// Returns the SBRoom where the call is ongoing
@property (nonatomic, readonly) SBRoom *room;

@property (nonatomic, readonly) BOOL streamingAudio;
@property (nonatomic, readonly) BOOL streamingVideo;

@end
