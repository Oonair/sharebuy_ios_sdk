//
//  SBProductViewController.h
//  eshop
//
//  Created by Pierluigi Cifani on 1/2/13.
//  Copyright (c) 2013 Pierluigi Cifani. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SBProductView.h"

@class SBProduct;

@interface SBProductViewController : UIViewController

- (id)initWithDelegate:(id <SBProductViewProtocol>)delegate
            pageNumber:(NSInteger)pageNumber;

- (void) setRightProduct:(SBProduct *)product mode:(TProductViewMode)mode;
- (void) setLeftProduct:(SBProduct *)product mode:(TProductViewMode)mode;

@property (nonatomic) NSInteger pageNumber;

@end
