//
//  SBNavigationController.h
//  eshop
//
//  Created by Pierluigi Cifani on 1/15/13.
//  Copyright (c) 2013 Oonair. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SBRoom;

@interface SBNavigationController : UINavigationController

- (void) placeDefaultBadgeInBackButtonWithValue:(NSInteger)value;

- (SBRoom *) currentRoom;

@end
