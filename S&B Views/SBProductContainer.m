//
//  SBCurrentProductContainer.m
//  eshop
//
//  Created by Pierluigi Cifani on 12/18/12.
//  Copyright (c) 2013 Oonair. All rights reserved.
//

#import "SBProductContainer.h"

NSString *SBCurrentProduct = @"SBCurrentProduct";

@interface SBProductContainer ()

@property (nonatomic, strong) SBProduct *currentProduct;
@property (nonatomic, weak) id <SBCurrentProductProtocol> delegate;
@property (nonatomic, weak) id <SBProductNavigationProtocol> navigationDelegate;

@end

@implementation SBProductContainer

+ (id) sharedContainer;
{
    static dispatch_once_t onceToken;
    static SBProductContainer *sharedMyContainer = nil;
    
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

- (void)setContainerDelegate:(id <SBCurrentProductProtocol>) delegate;
{
    self.delegate = delegate;
}

- (void)setNavigationDelegate:(id <SBProductNavigationProtocol>) delegate;
{
    _navigationDelegate = delegate;
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

- (void) navigateToProduct:(SBProduct *)product;
{
    [self.navigationDelegate onNavigateToProduct:product];
}

@end
