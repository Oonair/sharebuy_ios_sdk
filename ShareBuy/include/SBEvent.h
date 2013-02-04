//
//  SBEvent.h
//  SBXmpp
//
//  Created by Pierluigi Cifani on 26/11/12.
//  Copyright (c) 2012 Pierluigi Cifani. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SBContact;

typedef enum  TEventKind {
    EEventTextMessage = 0,  //Class SBEventMessage
    EEventUserOnline,       //Class SBEventContactStatus
    EEventUserOffline,      //Class SBEventContactStatus
    EEventUserLeft,         //Class SBEventContactStatus
    EEventInvitationSent,   //Class SBEventContactStatus
    EEventProductShared,    //Class SBEventProduct
    EEventProductRemoved,   //Class SBEventProduct
    EEventLikeProduct,      //Class SBEventProduct
    EEventLikeStopProduct,  //Class SBEventProduct
} TEventKind;

@interface SBEvent : NSObject

@property (nonatomic) TEventKind kind;
@property (nonatomic) BOOL read;
@property (nonatomic, strong) NSDate *time;
@property (nonatomic, strong) NSString *contactID;

- (NSComparisonResult)compare:(SBEvent *)other;

@end
