//
//  ProductCategoryCell.h
//  eshop
//
//  Created by Pierluigi Cifani on 2/18/13.
//  Copyright (c) 2013 Oonair. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductCategoryCell : UITableViewCell

+ (CGFloat) cellHeight;

- (void) setCategoryName:(NSString *)name;

@end
