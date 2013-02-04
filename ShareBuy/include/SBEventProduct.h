//
//  SBEventProduct.h
//  SBXmpp
//
//  Created by Pierluigi Cifani on 26/11/12.
//  Copyright (c) 2012 Pierluigi Cifani. All rights reserved.
//

#import "SBEvent.h"

@interface SBEventProduct : SBEvent

- (id)initWithType:(TEventKind)kind;

+ (SBEventProduct *)eventProductWithKind:(TEventKind)kind andID:(NSString *)ID;

@property(nonatomic, strong) NSString *productID;

@end
