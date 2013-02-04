//
//  SBMailViewController.h
//  eshop
//
//  Created by Pierluigi Cifani on 1/14/13.
//  Copyright (c) 2013 Pierluigi Cifani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBInvitationProtocols.h"

@class SBFBContact;


@interface SBInviteMailViewController : UIViewController

- (id)initWithDelegate:(id <SBInviteMailProtocol>)delegate
              userInfo:(SBFBContact *)contact;

@property (weak, nonatomic) id <SBInviteMailProtocol> delegate;

@end
