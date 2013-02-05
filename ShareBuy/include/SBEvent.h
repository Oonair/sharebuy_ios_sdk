//
//  SBEvent.h
//
//  Created by Pierluigi Cifani on 26/11/12.
//  Copyright (c) 2012 Pierluigi Cifani. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 @class SBEvent
 
 @brief This base-class represents an event generated in a SBRoom.
 
 Use the 'kind' property to get the specific class for each event.
 **/


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

//Returns the kind of event. Use this property to get the specific class of SBEvent
@property (nonatomic) TEventKind kind;

//Returns YES if the event was read by the user
@property (nonatomic) BOOL read;

//Returns the NSDate representing the time when this event happened
@property (nonatomic, strong) NSDate *time;

//Returns an NSString representing the contactID
@property (nonatomic, strong) NSString *contactID;

- (NSComparisonResult)compare:(SBEvent *)other;

@end
