//
//  SBEventContactStatus.h
//
//  Created by Pierluigi Cifani on 26/11/12.
//  Copyright (c) 2013 Oonair. All rights reserved.
//

#import "SBEvent.h"

/**
 @class SBEventContactStatus
 
 @brief This SBEvent subclass represents a change in a SBContact status property
 
 **/

@interface SBEventContactStatus : SBEvent

- (id)initWithType:(TEventKind)kind;

@end
