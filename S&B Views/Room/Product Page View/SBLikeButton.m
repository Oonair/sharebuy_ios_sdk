//
//  UILikeButton.m
//  ShareBuy
//
//  Created by Pierluigi Cifani on 7/3/12.
//  Copyright (c) 2012 Oonair. All rights reserved.
//

#import "SBLikeButton.h"
#import "UIView+CenterInSuperView.h"

#define kButtonWidth 40
#define kButtonHeight 40

@interface SBLikeButton ()
@property (nonatomic, strong) UIActivityIndicatorView *activity;
@end

@implementation SBLikeButton

- (id)initWithTarget:(id)target 
              action:(SEL)action 
               state:(TLikeState)state
        andLikeCount:(NSInteger)aLikeCount
{
    
    self = [super initWithFrame:CGRectMake(0, 0, kButtonWidth, kButtonHeight)];
    if (self) {
        // Initialization code
        [super addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];

        //Set up custom title
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.backgroundColor = [UIColor clearColor];

        //Set up State
        iButtonState = state;
        likeCount = aLikeCount;
        
        [self configureTitleAndImage];
        [self configureState];
        
        self.enabled = YES;
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


- (void)configureState
{
    switch (iButtonState) {
        case ELikeOn:
        {
            [self setBackgroundImage:[UIImage imageNamed:@"gr-like_on_bg"]
                            forState:UIControlStateNormal];
            [self setBackgroundImage:[UIImage imageNamed:@"gr-like_on_bg-over"]
                            forState:UIControlStateHighlighted];
            [self removeActivityIndicator];
        }
            break;
            
        case ELikeOff:
        {
            [self setBackgroundImage:[UIImage imageNamed:@"gr-like_off_bg"]
                            forState:UIControlStateNormal];
            [self setBackgroundImage:[UIImage imageNamed:@"gr-like_off_bg-over"]
                            forState:UIControlStateHighlighted];
            [self removeActivityIndicator];
        }
            break;

        case ELikeWaiting:
        {
            [self setImage:nil forState:UIControlStateNormal];
            [self setImage:nil forState:UIControlStateHighlighted];
            [self setTitle:nil forState:UIControlStateNormal];
            [self setTitle:nil forState:UIControlStateHighlighted];
            
            [self addActivityIndicator];
        }
            break;

        default:
            break;
    }
}

- (void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
}

-(void)configureTitleAndImage
{
    if (likeCount) {
        NSString *aTitle = [NSString stringWithFormat:@"%d", likeCount];
        
        [self setTitle:aTitle forState:UIControlStateNormal];
        [self setTitle:aTitle forState:UIControlStateHighlighted];

        [self setImage:[UIImage imageNamed:@"bt-like-active"]
              forState:UIControlStateNormal];
        [self setImage:[UIImage imageNamed:@"bt-like-active-over"]
              forState:UIControlStateHighlighted];
        
        [self setImageEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 1.0)];
        [self setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 2.0)];

        
    } else {
        [self setImage:[UIImage imageNamed:@"bt-like"]
              forState:UIControlStateNormal];
        [self setImage:[UIImage imageNamed:@"bt-like-over"]
              forState:UIControlStateHighlighted];
        
        [self setTitle:nil
              forState:UIControlStateNormal];
        [self setTitle:nil
              forState:UIControlStateHighlighted];

        [self setImageEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0)];
        [self setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
    }
}

- (void) setState:(TLikeState)state likeCount:(NSInteger)aNumber;
{
    iButtonState = state;
    likeCount = aNumber;
    
    [self configureTitleAndImage];
    [self configureState];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (iButtonState != ELikeWaiting) {
        iButtonState = ELikeWaiting;
        [self configureState];
        [super touchesBegan:touches withEvent:event];
    }
}

#pragma mark Activity Indicator

- (void)addActivityIndicator
{
    self.activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhite];

    [self addSubview:self.activity];
    [self.activity centerInSuperview];
    [self.activity startAnimating];
}

- (void)removeActivityIndicator
{
    [self.activity stopAnimating];
    [self.activity removeFromSuperview];
    self.activity = nil;
}


@end
