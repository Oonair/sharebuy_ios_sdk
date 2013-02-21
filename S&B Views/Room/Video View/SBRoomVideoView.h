//
//  SBRoomVideoView.h
//  eshop
//
//  Created by Pierluigi Cifani on 1/28/13.
//  Copyright (c) 2013 Oonair. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SBRoomVideoView : UIView

+ (id)videoViewWithFrame:(CGRect)frame;

- (void) setImageMode:(UIViewContentMode)mode;
- (void) setDecodedFrame:(UIImage *)image;

- (void) setActivityIndicator;
- (void) removeActivityIndicator;

- (void) setNoVideoPlaceholder;

@end
