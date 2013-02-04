//
//  SBInvitationProtocols.h
//  eshop
//
//  Created by Pierluigi Cifani on 1/14/13.
//  Copyright (c) 2013 Pierluigi Cifani. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SBInvitationProtocol <NSObject>

- (void) invitedFacebookContacts:(NSArray *)contacts;
- (void) invitedMailContact:(NSArray *)contacts;

@end

@protocol SBInviteMailProtocol <NSObject>

- (void) invitedMailContacts:(NSArray *)contacts;

@end
