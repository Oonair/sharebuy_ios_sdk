//
//  SBCallConstants.h
//  SBXmpp
//
//  Created by Pierluigi Cifani on 1/21/13.
//  Copyright (c) 2013 Pierluigi Cifani. All rights reserved.
//

#import <Foundation/Foundation.h>

// This represents the role in the call of a SBContact
typedef enum  TCallRole
{
    // Unknown role
    ECallRoleNotDefined = 0,
    
    // This is the contact that initated the call
    ECallRoleCaller,
    
    // This the contact has received the call
    ECallRoleReceiver
} TCallRole;

// This represents the stage of the SBCall
typedef enum  TCallStage
{    
    // The call is being prepared
    ECallStagePreparing = 0,
    
    // Waiting for the user to Accept/Reject the call
    ECallStageSignaling,
    
    // Connecting to remote user
    ECallStageConnecting,
    
    // The call is ongoing
    ECallStageTalking,
    
    // The call is ongoing
    ECallStageFinished
} TCallStage;

// This represents the reasons that a call couldn't be completed
typedef enum  TRejectReason{
    // User was busy in another call
    EReasonBusy = 0,
    // User's network doesn't support S&B calls. IE: 2G networks
    EReasonTransportNotAllowed,
    // User's device doesn't support S&B calls. IE: iPod Touch
    EReasonFeatureNotSupported,
    // User has rejected the call
    EReasonUserReject,
    // User has hanged up the call
    EReasonUserHangUp,
    // User didn't response to the call
    EReasonUserTimeout,
    // User lost connectivity to the server
    EReasonUserDisconnected,
    // User didn't connect to remote video-call server
    EReasonConnectTimeout,
    // Unknown reason
    EReasonUnknown
} TRejectReason;
