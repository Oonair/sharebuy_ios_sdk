//
//  SBProduct+NSDictionary.m
//  eshop
//
//  Created by Pierluigi Cifani on 12/18/12.
//  Copyright (c) 2012 Pierluigi Cifani. All rights reserved.
//

#import "SBProduct+NSDictionary.h"

@implementation SBProduct (NSDictionary)

+ (SBProduct *) productFromDictionary:(NSDictionary *)dictionary
{
    NSString *ID = [[dictionary objectForKey:@"id"] stringValue];
    
    SBProduct *product = [SBProduct productWithID:ID];
    product.name = [dictionary objectForKey:@"name"];
    [product setThumbnailURL:[NSURL URLWithString:[dictionary objectForKey:@"snapshot"]]];
    
    NSURL *imageURL = [NSURL URLWithString:[dictionary objectForKey:@"large_image"]];
    
    [product addImageURL:imageURL forSize:CGSizeMake(395, 507)];
    product.userMetadata = dictionary;
    
    return product;
}

@end
