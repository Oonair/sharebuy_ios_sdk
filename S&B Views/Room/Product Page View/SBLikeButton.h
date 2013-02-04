//
//  UILikeButton.h
//  ShareBuy
//
//  Created by Pierluigi Cifani on 7/3/12.
//  Copyright (c) 2012 Oonair. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum  TLikeState{
    ELikeOn = 0,
    ELikeOff,
    ELikeWaiting
} TLikeState;

@interface SBLikeButton : UIButton
{
    NSInteger likeCount;
    TLikeState iButtonState;
}

- (id)initWithTarget:(id)target 
              action:(SEL)action 
               state:(TLikeState)state
        andLikeCount:(NSInteger)aLikeCount;

- (void) setState:(TLikeState)state likeCount:(NSInteger)aNumber;

@end
