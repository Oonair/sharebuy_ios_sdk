//
//  ProductPageViewController.h
//  eshop
//
//  Created by Pierluigi Cifani on 2/6/13.
//  Copyright (c) 2013 Oonair. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductPageViewController : UIPageViewController

- (id)initWithProductArray:(NSArray *)productArray
                startIndex:(NSInteger)index;

@end
