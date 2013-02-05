//
//  SBEventMessage
//
//  Created by Pierluigi Cifani on 26/11/12.
//  Copyright (c) 2012 Pierluigi Cifani. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBEvent.h"

/**
 @class SBEventMessage
 
 @brief This SBEvent subclass represents an message in a SBRoom
 
 **/

@interface SBEventMessage : SBEvent

+ (SBEventMessage *) message;

//Returns the body of the message
@property (nonatomic, strong) NSString *body;

@end
