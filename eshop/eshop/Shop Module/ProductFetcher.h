//
//  ProductFetcher.h
//  eshop
//
//  Created by Pierluigi Cifani on 2/14/13.
//  Copyright (c) 2013 Oonair. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^ProductFetcherBlock)(NSArray *);

@interface ProductFetcher : NSObject

+ (void) fetchProductList:(ProductFetcherBlock)completionBlock;

@end
