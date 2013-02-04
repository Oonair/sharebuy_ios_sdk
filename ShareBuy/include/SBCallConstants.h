//
//  SBCallConstants.h
//  SBXmpp
//
//  Created by Pierluigi Cifani on 1/21/13.
//  Copyright (c) 2013 Pierluigi Cifani. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum  TCallRole{
    ECallRoleNotDefined = 0,
    ECallRoleCaller,
    ECallRoleReceiver
} TCallRole;

typedef enum  TCallStage{
    ECallStagePreparing = 0,
    ECallStageSignaling,
    ECallStageConnecting,
    ECallStageTalking,
    ECallStageFinished
} TCallStage;

typedef enum  TRejectReason{
    EReasonBusy = 0,
    EReasonTransportNotAllowed,
    EReasonFeatureNotSupported,
    EReasonUserReject,
    EReasonUserHangUp,
    EReasonUserTimeout,
    EReasonUserDisconnected,
    EReasonConnectTimeout,
    EReasonUnknown
} TRejectReason;
