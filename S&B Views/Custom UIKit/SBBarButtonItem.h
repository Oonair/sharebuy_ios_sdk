//
//  SBBarButtonItem.h
//  eshop
//
//  Created by Pierluigi Cifani on 2/12/13.
//  Copyright (c) 2013 Oonair. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SBBarButtonItem : UIBarButtonItem

+ (instancetype) buttonWithTarget:(id)target action:(SEL)action image:(UIImage *)image;

- (void) setBadgeValue:(NSInteger)badgeValue;

@end
