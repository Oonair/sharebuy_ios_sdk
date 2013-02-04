//
//  SBFBContact.h
//  SBXmpp
//
//  Created by Pierluigi Cifani on 12/20/12.
//  Copyright (c) 2012 Pierluigi Cifani. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBImageProtocol.h"

@interface SBFBContact : NSObject <SBImageProtocol>

+ (SBFBContact *) contactWithFacebookID:(NSString *)facebookID;

- (NSString *) getFullName;
- (NSString *) getMail;

@property (nonatomic, strong)   NSString *firstName;
@property (nonatomic, strong)   NSString *lastName;
@property (nonatomic, strong)   NSString *facebookID;
@property (nonatomic) BOOL isOnline;

@end
