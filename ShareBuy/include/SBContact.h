//
//  SBXmpp
//
//  Created by Pierluigi Cifani on 26/11/12.
//  Copyright (c) 2012 Pierluigi Cifani. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBImageProtocol.h"

typedef enum TContactStatus{
    EContactUnknownStatus,
    EContactOnline,
    EContactOffline,
    EContactPending,
    EContactUnsubscribed
} TContactStatus;

typedef enum TWritingStatus{
    EWritingUnknown,
    EWritingPaused,
    EWritingComposing,
    EWritingActive
} TWritingStatus;

extern NSString *SBContactUpdateNotification;

@interface SBContact : NSObject <SBImageProtocol>

@property (nonatomic, readonly, strong) NSString    *ID;
@property (nonatomic, strong) NSString    *firstName;
@property (nonatomic, strong) NSString    *lastName;
@property (nonatomic, strong) NSDate      *lastTimeSeen;

@property (nonatomic) TWritingStatus writingStatus;
@property (nonatomic) TContactStatus contactStatus;

- (NSString *) getFullName;

@end
