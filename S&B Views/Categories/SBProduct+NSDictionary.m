//
//  SBProduct+NSDictionary.m
//  eshop
//
//  Created by Pierluigi Cifani on 12/18/12.
//  Copyright (c) 2013 Oonair. All rights reserved.
//

#import "SBProduct+NSDictionary.h"
#define kImageSize CGSizeMake(395, 507)

@implementation SBProduct (NSDictionary)

+ (SBProduct *) productFromDictionary:(NSDictionary *)dictionary
{
    id productID = [dictionary objectForKey:@"id"];
    if (![productID isKindOfClass:[NSString class]]) {
        productID = [productID stringValue];
    }
    NSString *ID = productID;
    
    SBProduct *product = [SBProduct productWithID:ID];
    product.name = [dictionary objectForKey:@"name"];
            
    NSURL *productImageURL = [NSURL URLWithString:[dictionary objectForKey:@"large_image_a"]];
    NSURL *productSnapshotURL = [NSURL URLWithString:[dictionary objectForKey:@"snapshot_a"]];

    [product setThumbnailURL:productSnapshotURL];
    [product addImageURL:productImageURL forSize:kImageSize];
    
    NSString *productURL = [dictionary objectForKey:@"product_url"];
    product.URL = [NSURL URLWithString:productURL];
    
    product.userMetadata = dictionary;
    
    return product;
}

+ (NSDictionary *) dictionaryFromProduct:(SBProduct *)product;
{
    if (product.userMetadata)
    {
        return product.userMetadata;
    }
    else
    {
        NSURL *imageURL = [product getImageURLForSize:kImageSize];
        NSString *imageStringURL = [imageURL absoluteString];
        
        NSURL *productURL = product.URL;
        NSString *productStringURL = [productURL absoluteString];
        
        NSString *productName = product.name;

        return @{@"id": product.ID,
                 @"large_image_a" : imageStringURL,
                 @"name" : productName,
                 @"product_url" : productStringURL};
    }
    return product.userMetadata;
}

@end
