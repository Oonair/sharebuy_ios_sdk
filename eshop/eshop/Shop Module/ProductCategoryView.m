//
//  ProductCategoryView.m
//  eshop
//
//  Created by Pierluigi Cifani on 2/18/13.
//  Copyright (c) 2013 Oonair. All rights reserved.
//

#import "ProductCategoryView.h"
@interface ProductCategoryView ()


@end

@implementation ProductCategoryView

- (id)initWithFrame:(CGRect)frame
{
    UINib *aXib = [UINib nibWithNibName:@"ProductCategoryView" bundle:[NSBundle mainBundle]];
    ProductCategoryView *aView = [[aXib instantiateWithOwner:self options:nil] lastObject];
    
    if (aView) {
        self = aView;
        aView.frame = frame;
    }
    
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
