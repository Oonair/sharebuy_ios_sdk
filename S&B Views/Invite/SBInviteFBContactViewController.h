//
//  SBInviteContactViewController.h
//  eshop
//
//  Created by Pierluigi Cifani on 1/14/13.
//  Copyright (c) 2013 Oonair. All rights reserved.
//

// Design inspired by KNMultiItemSelector ( https://github.com/kentnguyen/KNMultiItemSelector )

#import <UIKit/UIKit.h>
#import "SBInvitationProtocols.h"

@interface SBInviteFBContactViewController : UIViewController

- (id)initWithDelegate:(id <SBInvitationProtocol>)delegate;

@property (nonatomic, weak) id <SBInvitationProtocol> delegate;

@end
