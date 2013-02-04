//
//  SBRoomViewController.h
//  eshop
//
//  Created by Pierluigi Cifani on 12/13/12.
//  Copyright (c) 2012 Pierluigi Cifani. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SBRoom;
@class SBCall;

@interface SBRoomViewController : UIViewController

- (id)initWithRoom:(SBRoom *)room
            userID:(NSString *)userID;

@property (strong, nonatomic) SBRoom *room;
@property (strong, nonatomic) NSString *userID;

- (void) prepareForCall:(SBCall *)call;

@end
