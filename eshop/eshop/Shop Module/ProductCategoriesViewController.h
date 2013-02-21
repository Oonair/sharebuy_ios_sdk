//
//  ProductCategoriesViewController.h
//  eshop
//
//  Created by Pierluigi Cifani on 2/18/13.
//  Copyright (c) 2013 Oonair. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductCategoriesViewController : UIViewController

- (void) getCategories;

@property (strong, nonatomic) NSArray *categoryArray;
@property (weak, nonatomic) UIActivityIndicatorView *indicator;
@end
