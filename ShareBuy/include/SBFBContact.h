//
//  SBFBContact.h
//
//  Created by Pierluigi Cifani on 12/20/12.
//  Copyright (c) 2012 Pierluigi Cifani. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBImageProtocol.h"

/**
 @class SBFBContact
 
 @brief This class represents a Facebook Friend.
 
 Use this class talk to represent and hold the Facebook information of a contact
 
 **/

@interface SBFBContact : NSObject <SBImageProtocol>

// Factory method to init a new instance using a FacebookID
+ (SBFBContact *) contactWithFacebookID:(NSString *)facebookID;

- (NSString *) getFullName;
- (NSString *) getMail;

@property (nonatomic, strong)   NSString *firstName;
@property (nonatomic, strong)   NSString *lastName;
@property (nonatomic, strong)   NSString *facebookID;

// Returns YES if this contact is online on the Facebook Instant Messaging platform
@property (nonatomic) BOOL isOnline;

@end
