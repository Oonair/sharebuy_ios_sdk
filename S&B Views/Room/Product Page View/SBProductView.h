//
//  SBProductView.h
//  eshop
//
//  Created by Pierluigi Cifani on 12/17/12.
//  Copyright (c) 2013 Oonair. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SBProduct;
@class SBProductView;

typedef enum  TProductViewMode{
    EModeNormal = 0,
    EModeLoading,
    EModeOverlay,
    EModeGhost
} TProductViewMode;

@protocol SBProductViewProtocol

-(void) onProductSelected:(SBProductView *)product;
-(void) onProductDeleted:(SBProductView *)product;
-(void) onProductLiked:(SBProductView *)product;

@end

@interface SBProductView : UIView

- (id)initWithFrame:(CGRect)frame
         andProduct:(SBProduct *)product
           delegate:(id<SBProductViewProtocol>)delegate
               mode:(TProductViewMode)aMode;

- (void) wigglePlusButton;

- (void) setViewMode:(TProductViewMode)state;
- (TProductViewMode) viewMode;

- (SBProduct *)getProduct;
- (void) updateProduct:(SBProduct *)product;

@end
