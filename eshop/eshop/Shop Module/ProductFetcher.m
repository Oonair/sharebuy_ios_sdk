//
//  ProductFetcher.m
//  eshop
//
//  Created by Pierluigi Cifani on 2/14/13.
//  Copyright (c) 2013 Oonair. All rights reserved.
//

#import "ProductFetcher.h"
#import "SBJsonParser.h"

@implementation ProductFetcher

+ (void) fetchProductList:(ProductFetcherBlock)completionBlock
{
    dispatch_queue_t fetcherQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, nil);
    dispatch_async(fetcherQueue, ^{
        
        NSURL *productsURL = nil;
        
#ifdef DEBUG
        productsURL = [NSURL URLWithString:@"http://eshop.test.oonair.net/categories/"];
#else 
        productsURL = [NSURL URLWithString:@"http://eshop.oonair.net/categories/"];
#endif
        NSError *error = nil;
        NSData *data = [NSData dataWithContentsOfURL:productsURL
                                             options:NSDataReadingUncached
                                               error:&error];
        
        if (error)
        {
            [ProductFetcher executeCompletionBlock:completionBlock response:nil];
            return;
        }
        
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        
        id response = [parser objectWithData:data ];
        
        [ProductFetcher executeCompletionBlock:completionBlock response:response];
    });
}

+ (void) executeCompletionBlock:(ProductFetcherBlock)completionBlock response:(id)response
{
    dispatch_async(dispatch_get_main_queue(), ^{
        completionBlock (response);
    });
}

@end
