//
//  SBHelper.h
//  eshop
//
//  Created by Pierluigi Cifani on 2/18/13.
//  Copyright (c) 2013 Oonair. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SBHelperProtocol.h"

@interface SBHelper : UIView

- (void) setHelperDelegate:(id <SBHelperProtocol>)delegate;

@end
