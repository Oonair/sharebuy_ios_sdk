//
//  SBEventProduct.h
//
//  Created by Pierluigi Cifani on 26/11/12.
//  Copyright (c) 2013 Oonair. All rights reserved.
//

#import "SBEvent.h"

/**
 @class SBEventProduct
 
 @brief This SBEvent subclass represents an action performed to a SBProduct
 
 **/

@interface SBEventProduct : SBEvent

- (id)initWithType:(TEventKind)kind;

+ (SBEventProduct *)eventProductWithKind:(TEventKind)kind andID:(NSString *)ID;

//Returns an NSString representating the productID of the SBProduct
@property(nonatomic, strong) NSString *productID;

@end
