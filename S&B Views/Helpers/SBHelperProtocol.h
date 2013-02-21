//
//  SBHelperProtocol.h
//  eshop
//
//  Created by Pierluigi Cifani on 2/18/13.
//  Copyright (c) 2013 Oonair. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SBHelperProtocol <NSObject>

@optional
- (void) onHelperTapped;
- (void) onHelperWithProductTapped;

@end
