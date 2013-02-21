//
//  SBProductPageViewController.h
//  eshop
//
//  Created by Pierluigi Cifani on 1/2/13.
//  Copyright (c) 2013 Oonair. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SBRoom;

@interface SBProductPageViewController : UIPageViewController

- (id) initWithRoom:(SBRoom *)room
             userID:(NSString *)userID;

@end
