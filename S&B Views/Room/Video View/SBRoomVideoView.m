//
//  SBRoomVideoView.m
//  eshop
//
//  Created by Pierluigi Cifani on 1/28/13.
//  Copyright (c) 2013 Pierluigi Cifani. All rights reserved.
//

#import "SBRoomVideoView.h"

#import "UIView+CenterInSuperView.h"
#import "UIImageView+ActivityIndicator.h"

@interface SBRoomVideoView ()

@property (nonatomic, strong) UIImageView *videoImage;

@end


@implementation SBRoomVideoView

+ (id)videoViewWithFrame:(CGRect)frame;
{
    return [[self alloc] initWithFrame:frame];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        CGFloat videoWidth = frame.size.width;
        CGFloat videoHeight = frame.size.height;
        NSInteger margin = 5;
        UIImageView *contactLayerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, videoWidth - margin, videoHeight - margin)];

        [self addSubview:contactLayerView];
        [contactLayerView centerInSuperview];
        
        self.videoImage = contactLayerView;
        
    }
    return self;
}


- (void) setImageMode:(UIViewContentMode)mode;
{
    self.videoImage.contentMode = mode;
}

- (void) setDecodedFrame:(UIImage *)image;
{
    [self.videoImage setImage:image];
}

- (void) setActivityIndicator;
{
    [self.videoImage placeActivityIndicatorViewInCenterWithStyle:UIActivityIndicatorViewStyleGray];
}

- (void) removeActivityIndicator;
{
    [self.videoImage cancelActivityIndicatorView];
}

- (void) setNoVideoPlaceholder;
{
    [self.videoImage setImage:[UIImage imageNamed:@"ic-nocamera"]];
}

@end