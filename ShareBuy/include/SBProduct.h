//
//  SBProduct.h
//  SBXmpp
//
//  Created by Pierluigi Cifani on 26/11/12.
//  Copyright (c) 2012 Pierluigi Cifani. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBImageProtocol.h"

extern NSString *SBProductUpdateNotification;

@interface SBProduct : NSObject <SBImageProtocol>

- (id) initWithProductID:(NSString *)productID;

+ (SBProduct *)productWithID:(NSString *)productID;

- (NSArray *)getLikeContactsID;

@property (nonatomic, strong) NSString *name;   // Title of the product
@property (nonatomic, strong) NSString *ID;     // Unique ID of the product
@property (nonatomic, strong) NSDate *date;     // Date when the product was shared
@property (nonatomic, strong) NSString *userID; // ID of the user that shared the product

@property (nonatomic) BOOL like;                // Indicates wheterer the current user likes this product

@property (nonatomic, strong) NSDictionary *userMetadata;   // Custom Metadata, user can send any desired information in this field

@end
