//
//  SBTextField.m
//  eshop
//
//  Created by Pierluigi Cifani on 2/7/13.
//  Copyright (c) 2013 Oonair. All rights reserved.
//

#import "SBTextField.h"

@implementation SBTextField

- (CGRect)textRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, 10, 0);
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, 10, 0);
}

@end
