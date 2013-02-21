//
//  SBInviteAddressBookViewController.h
//  eshop
//
//  Created by Pierluigi Cifani on 1/14/13.
//  Copyright (c) 2013 Oonair. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBInvitationProtocols.h"

@interface SBInviteAddressBookViewController : UIViewController

- (id)initWithDelegate:(id <SBInviteMailProtocol>)delegate;

@property (weak, nonatomic) id <SBInviteMailProtocol> delegate;

@end
