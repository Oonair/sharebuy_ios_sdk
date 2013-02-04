//
//  SBCurrentProductContainer.m
//  eshop
//
//  Created by Pierluigi Cifani on 12/18/12.
//  Copyright (c) 2012 Pierluigi Cifani. All rights reserved.
//

#import "SBCurrentProductContainer.h"

NSString *SBCurrentProduct = @"SBCurrentProduct";

@interface SBCurrentProductContainer ()

@property (nonatomic, strong) SBProduct *currentProduct;
@property (nonatomic, weak) id <SBCurrentProductContainerProtocol> delegate;

@end

@implementation SBCurrentProductContainer

+ (id) sharedContainer;
{
    static dispatch_once_t onceToken;
    static SBCurrentProductContainer *sharedMyContainer = nil;
    
    dispatch_once(&onceToken, ^{
        sharedMyContainer = [[self alloc] init];
    });
    return sharedMyContainer;
}

- (id)init
{
    self = [super init];
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onCurrentProduct:)
                                                     name:SBCurrentProduct
                                                   object:nil];
    }
    return self;
}

- (void)setContainerDelegate:(id <SBCurrentProductContainerProtocol>) delegate;
{
    self.delegate = delegate;
}

- (void)onCurrentProduct:(NSNotification *)notification
{
    SBProduct *currentProduct = notification.object;
    self.currentProduct = currentProduct;
    [self.delegate onNewCurrentProduct:self.currentProduct];
}

- (SBProduct *)getCurrentProduct;
{
    return self.currentProduct;
}

@end
