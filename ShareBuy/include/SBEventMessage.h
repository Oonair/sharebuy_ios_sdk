//
//  SBMessage.h
//  SBXmpp
//
//  Created by Pierluigi Cifani on 26/11/12.
//  Copyright (c) 2012 Pierluigi Cifani. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBEvent.h"

@interface SBEventMessage : SBEvent

+ (SBEventMessage *) message;

@property (nonatomic, strong) NSString *body;

@end
