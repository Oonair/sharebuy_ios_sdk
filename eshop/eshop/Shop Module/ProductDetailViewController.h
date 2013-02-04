//
//  ProductDetailViewController.h
//  eshop
//
//  Created by Pierluigi Cifani on 12/10/12.
//  Copyright (c) 2012 Pierluigi Cifani. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductDetailViewController : UIViewController

- (id)initWithProduct:(NSDictionary *)aProduct;

@property (strong, nonatomic) IBOutlet UIImageView *productImageView;

@end
