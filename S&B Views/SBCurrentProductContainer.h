//
//  SBCurrentProductContainer.h
//  eshop
//
//  Created by Pierluigi Cifani on 12/18/12.
//  Copyright (c) 2012 Pierluigi Cifani. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SBProduct;

@protocol SBCurrentProductContainerProtocol <NSObject>

- (void) onNewCurrentProduct:(SBProduct *)product;

@end

@interface SBCurrentProductContainer : NSObject

+ (id) sharedContainer;

- (void)setContainerDelegate:(id <SBCurrentProductContainerProtocol>) delegate;

- (SBProduct *)getCurrentProduct;

@end
