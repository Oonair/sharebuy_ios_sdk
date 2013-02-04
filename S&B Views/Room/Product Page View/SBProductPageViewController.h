//
//  SBProductPageViewController.h
//  eshop
//
//  Created by Pierluigi Cifani on 1/2/13.
//  Copyright (c) 2013 Pierluigi Cifani. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SBRoom;

@interface SBProductPageViewController : UIPageViewController

+ (id) productPageControllerForRoom:(SBRoom *)theCurrentRoom
                             userID:(NSString *)userID;

- (id) initWithRoom:(SBRoom *)room
             userID:(NSString *)userID;

@end
