//
//  SBXmpp
//
//  Created by Pierluigi Cifani on 26/11/12.
//  Copyright (c) 2013 Oonair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBImageProtocol.h"

/**
 @class SBContact
 
 @brief This class represents a contact that has subscribed to the S&B platform.
 
 Use this class talk to represent and hold information of a contact
 
 In order to receive updates of events of this contact, register as an observer to 
 the notification SBContactUpdateNotification, like this:
 
 [[NSNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(onSBContactUpdate:)
                                              name:SBContactUpdateNotification
                                            object:aContact];
 **/


typedef enum TContactStatus{
    // The contact is in an unknown status
    EContactUnknownStatus,
    
    // The contact is online and immediately reachable.
    EContactOnline,
    
    // The contact is offline, but can be reached via APNS.
    EContactOffline,
    
    // The contact is haven't yet accepted the invitation to join S&B.
    EContactPending,
    
    // The contact has left the room.
    EContactUnsubscribed
} TContactStatus;

typedef enum TWritingStatus{
    
    // The contact writing status is unknown.
    EWritingUnknown,
    
    // The contact writing status is paused.
    EWritingPaused,
    
    // The contact writing status is writing.
    EWritingComposing,
    
    // The contact writing status is active, which means it just finished sending a message.
    EWritingActive
} TWritingStatus;


// This notification will the contact information will be updated, IE: it's writingStatus or contactStatus.
extern NSString *SBContactUpdateNotification;

@interface SBContact : NSObject <SBImageProtocol>

//Returns an NSString representing a unique ID for each contact
@property (nonatomic, readonly, strong) NSString    *ID;
@property (nonatomic, strong) NSString    *firstName;
@property (nonatomic, strong) NSString    *lastName;
@property (nonatomic, strong) NSDate      *lastTimeSeen;

@property (nonatomic) TWritingStatus writingStatus;
@property (nonatomic) TContactStatus contactStatus;

- (NSString *) getFullName;

@end
