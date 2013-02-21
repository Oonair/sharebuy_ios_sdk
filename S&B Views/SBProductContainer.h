//
//  SBCurrentProductContainer.h
//  eshop
//
//  Created by Pierluigi Cifani on 12/18/12.
//  Copyright (c) 2013 Oonair. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SBProduct;

extern NSString *SBCurrentProduct;

@protocol SBCurrentProductProtocol <NSObject>

- (void) onNewCurrentProduct:(SBProduct *)product;

@end


@protocol SBProductNavigationProtocol <NSObject>

- (void) onNavigateToProduct:(SBProduct *)product;

@end

@interface SBProductContainer : NSObject

+ (instancetype) sharedContainer;

- (void)setContainerDelegate:(id <SBCurrentProductProtocol>) delegate;
- (void)setNavigationDelegate:(id <SBProductNavigationProtocol>) delegate;

- (SBProduct *)getCurrentProduct;

- (void) navigateToProduct:(SBProduct *)product;

@end
