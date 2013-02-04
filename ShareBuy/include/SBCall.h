//
//  SBCall.h
//  SBSDK
//
//  Created by Pierluigi Cifani on 1/21/13.
//  Copyright (c) 2013 Pierluigi Cifani. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef SBDEVEL
#import "SBXmpp/SBCallConstants.h"
#import "SBXmpp/SBRoom.h"
#else
#import "SBCallConstants.h"
#import "SBRoom.h"
#endif

extern NSString *SBRoomCallNotification;
extern NSString *SBRoomCallErrorDomain;

typedef enum  TSBCallError {
    ESBErrorCallUnknown = 0,
    ESBErrorCallOngoing,
    ESBErrorNoParticipants,
    ESBErrorMaxParticipants,
    ESBErrorCallAuthentication,
    ESBErrorCallHardwareInitialization,
    ESBErrorCallServerUnreachable,
} TSBCallError;

@class SBContact;
@class SBRoom;

@protocol SBCallObserverProtocol <NSObject>

- (void) callTerminated;

- (void) callWillTerminateWithError:(NSError *)error;

@optional

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

@class SBCall;

@interface SBRoom (Call)

- (void) startCallWithVideoEnabled:(BOOL)video
                      audioEnabled:(BOOL)audio
                   completionBlock:(SBRequestCompletionBlock)completionBlock;

- (SBCall *) currentCall;

@end

@interface SBCall : NSObject

- (BOOL) hangCall;

- (BOOL) answerCallWithVideoEnabled:(BOOL)video
                       audioEnabled:(BOOL)audio
                    completionBlock:(SBRequestCompletionBlock)completionBlock;

- (BOOL) rejectCallWithReason:(TRejectReason)reason;

- (void) setPreviewLayer:(UIImageView *)previewLayer;
- (void) setVideoEnabled:(BOOL)videoEnabled;
- (void) setAudioEnabled:(BOOL)AudioEnabled;
- (void) toggleCameraPosition;

@property (nonatomic, weak) id <SBCallObserverProtocol> observer;
@property (nonatomic, readonly) TCallRole role;
@property (nonatomic, readonly) TCallStage stage;
@property (nonatomic, readonly) SBContact *caller;
@property (nonatomic, readonly) NSArray *participants;
@property (nonatomic, readonly) SBRoom *room;

@property (nonatomic, readonly) BOOL streamingAudio;
@property (nonatomic, readonly) BOOL streamingVideo;

@end
