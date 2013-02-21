//
//  SBProduct+NSDictionary.h
//  eshop
//
//  Created by Pierluigi Cifani on 12/18/12.
//  Copyright (c) 2013 Oonair. All rights reserved.
//

#import "SBProduct.h"

@interface SBProduct (NSDictionary)

+ (SBProduct *) productFromDictionary:(NSDictionary *)dictionary;

+ (NSDictionary *) dictionaryFromProduct:(SBProduct *)product;

@end
