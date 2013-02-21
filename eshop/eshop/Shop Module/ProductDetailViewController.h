//
//  ProductDetailViewController.h
//  eshop
//
//  Created by Pierluigi Cifani on 12/10/12.
//  Copyright (c) 2013 Oonair. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NavigateToProductProtocol <NSObject>

- (void)userTappedOnDoneButton;

@end

@interface ProductDetailViewController : UIViewController

- (id)initWithProduct:(NSDictionary *)aProduct forIndex:(NSInteger)index;
- (void)setNavigateToProductDelegate:(id <NavigateToProductProtocol>)delegate;

@property (nonatomic) NSInteger index;

@property (nonatomic, strong) NSDictionary *product;

@end
