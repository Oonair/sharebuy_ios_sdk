//
//  SBInvitation
//
//  Created by Pierluigi Cifani on 10/25/12.
//  Copyright (c) 2012 Oonair. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SBInvitation : NSObject

- (id) initWithInvitationDictionary:(NSDictionary *)aDictionary;

@property (nonatomic, strong) NSString *fromName;
@property (nonatomic, strong) NSString *fromPhoto;
@property (nonatomic, strong) NSString *productName;
@property (nonatomic, strong) NSString *productThumbnail;
@property (nonatomic, strong) NSString *productURL;
@property (nonatomic, strong) NSString *roomName;
@property (nonatomic, strong) NSString *invitationToken;

@end
