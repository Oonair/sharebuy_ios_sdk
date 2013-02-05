//
//  SBProduct.h
//
//  Created by Pierluigi Cifani on 26/11/12.
//  Copyright (c) 2012 Pierluigi Cifani. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBImageProtocol.h"

/**
 @class SBProduct
 
 @brief This class represents a Product.
 
 Use this class to store relevant information of the product you want to share.
 
 In order to receive updates of events of this product, register as an observer to the 
 SBProductUpdateNotification, like this:
 
 [[NSNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(onSBProductUpdate:)
                                              name:SBProductUpdateNotification
                                            object:aProduct];
 **/

// This notification will be a value of the SBProduct is updated.
extern NSString *SBProductUpdateNotification;

@interface SBProduct : NSObject <SBImageProtocol>

// Initializes a product with a given UNIQUE ID.
- (id) initWithProductID:(NSString *)productID;
+ (SBProduct *)productWithID:(NSString *)productID;

// Returns an NSArray populated with the userID of the SBContacts that like this product.
- (NSArray *)getLikeContactsID;

@property (nonatomic, strong) NSString *name;   // Title of the product
@property (nonatomic, strong) NSString *ID;     // Unique ID of the product
@property (nonatomic, strong) NSDate *date;     // Date when the product was shared
@property (nonatomic, strong) NSString *userID; // ID of the user that shared the product

@property (nonatomic) BOOL like; // Indicates wheterer the current user likes this product

// Custom Metadata, user can send any desired information in this field
// NOTE: please make sure that this metadata can be serialized into JSON format, otherwise the guarantee when sent is not assured
@property (nonatomic, strong) NSDictionary *userMetadata;

@end
