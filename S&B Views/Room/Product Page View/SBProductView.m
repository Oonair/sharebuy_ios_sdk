//
//  SBProductView.m
//  eshop
//
//  Created by Pierluigi Cifani on 12/17/12.
//  Copyright (c) 2012 Pierluigi Cifani. All rights reserved.
//

#import "SBProductView.h"

#import "SBProduct.h"

#import "SDWebImageManager.h"
#import "UIView+CenterInSuperView.h"

#import "SBLikeButton.h"

#import "UIImageView+ActivityIndicator.h"

#import <QuartzCore/CALayer.h>

@interface SBProductView () <UIGestureRecognizerDelegate>

@property (nonatomic, weak) id<SBProductViewProtocol>delegate;
@property (nonatomic, strong) UIImageView *productImage;

@property (nonatomic, strong) UIImageView *spinnerView;
@property (nonatomic, strong) UIImageView *ghostView;
@property (nonatomic, strong) UIButton *plusButton;
@property (nonatomic, strong) SBLikeButton *likeButton;
@property (nonatomic, strong) id<SDWebImageOperation> task;
@property (nonatomic) TProductViewMode mode;

@property (nonatomic, strong) SBProduct *product;

@end

@implementation SBProductView

- (id)initWithFrame:(CGRect)frame
         andProduct:(SBProduct *)product
           delegate:(id<SBProductViewProtocol>)delegate
               mode:(TProductViewMode)aMode;
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.delegate = delegate;
        self.product = product;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        
        [self initialize];
        [self setViewMode:aMode];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onSBProductUpdate)
                                                     name:SBProductUpdateNotification
                                                   object:self.product];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.delegate = nil;
    
    [self.task cancel];

}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
}

- (SBProduct *)getProduct;
{
    return self.product;
}

- (void) updateProduct:(SBProduct *)product;
{
    self.product = product;
    
    NSInteger likeCount = [[self.product getLikeContactsID] count];
    TLikeState likeState = self.product.like ? ELikeOn : ELikeOff;

    [self.likeButton setState:likeState likeCount:likeCount];
}

- (void)onSBProductUpdate
{
    //This is a poorly written "Reload"
    [self updateProduct:self.product];
}

- (void)initialize
{    
    CGSize thisSize = self.frame.size;
    
    int margin = 15;
    if (INTERFACE_IS_PHONE) {
        margin = 5;
    }
    
    int imageWidth = thisSize.width - margin;
    int imageHeight = thisSize.height - margin/2;
    
    //Set up Image
    self.productImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, imageWidth, imageHeight)];
    self.productImage.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self addSubview:self.productImage];
    [self.productImage centerInSuperview];
    
    //Add Tap recognizer
    UITapGestureRecognizer *iReco = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                             action:@selector(onProductSelected)];
    iReco.delegate = self;
    [self.productImage addGestureRecognizer:iReco];
    self.productImage.userInteractionEnabled = YES;
    self.productImage.contentMode = UIViewContentModeScaleAspectFill;
    self.productImage.clipsToBounds = YES;
    [self setImage];
}


- (void) setImage
{
    id loadTask = nil;
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    NSURL *photoURL = [self.product getImageURLForSize:self.productImage.frame.size];

    [self.productImage placeActivityIndicatorViewInCenterWithStyle:UIActivityIndicatorViewStyleGray];
    
    loadTask = [manager downloadWithURL:photoURL
                                options:SDWebImageLowPriority
                               progress:nil
                              completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished){
                                  [self.productImage setImage:image];
                                  [self.productImage cancelActivityIndicatorView];
                              }];
    
    self.task = loadTask;
}

#pragma mark States

- (TProductViewMode) viewMode;
{
    return self.mode;
}
- (void) setViewMode:(TProductViewMode)aMode;
{
    self.mode = aMode;
    
    switch (self.mode) {
        case EModeNormal:
            [self setNormalMode];
            break;
        case EModeLoading:
            [self setLoadingMode];
            break;
        case EModeGhost:
            [self setGhostMode];
            break;
        case EModeOverlay:
            [self setOverlayMode];
            break;

        default:
            break;
    }
}

- (void) removeGhostView
{
    [self.ghostView removeFromSuperview];
    self.ghostView = nil;
    
    [self.plusButton removeFromSuperview];
    self.plusButton = nil;
}

- (void) removeSpinnerView
{
    [self.spinnerView removeFromSuperview];
    self.spinnerView = nil;
}

- (void) removeLikeButtonView
{
    [self.likeButton removeFromSuperview];
    self.likeButton = nil;
}

-(void) resetView
{
    [self removeGhostView];
    [self removeSpinnerView];
    [self removeLikeButtonView];
}

- (void)setupLikeButton
{
    NSInteger likeCount = [[self.product getLikeContactsID] count];
    TLikeState likeState = self.product.like ? ELikeOn : ELikeOff;

    if (self.likeButton == nil) {
        self.likeButton = [[SBLikeButton alloc] initWithTarget:self
                                                         action:@selector(onLikePressed)
                                                          state:likeState
                                                   andLikeCount:likeCount];
        self.likeButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
        
        [self.productImage addSubview:self.likeButton];
        
        CGRect likeRect = self.likeButton.frame;
        CGRect productRect = self.frame;
        CGFloat margin = 10.0f;
        [self.likeButton setFrame:CGRectMake(margin,
                                             productRect.size.height - margin - likeRect.size.height,
                                             likeRect.size.width,
                                             likeRect.size.height)];
    } else {
        [self.likeButton setState:likeState likeCount:likeCount];
    }
}

-(void)setNormalMode;
{
    [self removeGhostView];
    [self removeSpinnerView];
    [self setupLikeButton];
}

-(void)setLoadingMode
{
    [self resetView];
    
    UIImage *backGround = [[UIImage imageNamed:@"bt-addproduct-bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    self.spinnerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [self.spinnerView setImage:backGround];
    [self addSubview:self.spinnerView];
    [self.spinnerView centerInSuperview];
    
    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [self.spinnerView addSubview:activity];
    [activity centerInSuperview];
    [activity startAnimating];
    
}

-(void)setGhostMode
{
    [self removeSpinnerView];
    [self removeLikeButtonView];
    
    //Set ghost look
    CGRect productImageRect = self.productImage.frame;
    self.ghostView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, productImageRect.size.width, productImageRect.size.height)];
    [self.ghostView setImage:[UIImage imageNamed:@"gr-product-ghost"]];
    [self.productImage addSubview:self.ghostView];
    
    //Plus button set up    
    UIImage *backGround = [[UIImage imageNamed:@"bt-addproduct-bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    UIImage *backGroundOver = [[UIImage imageNamed:@"bt-addproduct-bg-over"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    
    UIImage *plusImage = [UIImage imageNamed:@"ic-addproduct"];
    
    self.plusButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    
    [_plusButton setBackgroundImage:backGround
                          forState:UIControlStateNormal];
    [_plusButton setBackgroundImage:backGroundOver
                          forState:UIControlStateHighlighted];
    [_plusButton setImage:plusImage
                forState:UIControlStateNormal];
    [_plusButton setImage:plusImage
                forState:UIControlStateHighlighted];
        
    [_plusButton addTarget:self
                   action:@selector(onProductSelected)
         forControlEvents:UIControlEventTouchDown];

    _plusButton.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
    
    [self addSubview:self.plusButton];
    [self.plusButton centerInSuperview];
}

-(void)setOverlayMode;
{
    [self resetView];
    
    //set a cute shadow
    self.layer.shadowColor = [UIColor grayColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(0, 1);
    self.layer.shadowOpacity = 1;
    self.layer.shadowRadius = 1.0;
    self.clipsToBounds = NO;
    self.userInteractionEnabled = YES;
    
    //Add (+) Image
    UIImage *plusImage = [UIImage imageNamed:@"ic-plus"];
    
    UIButton *plusButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, plusImage.size.width, plusImage.size.height)];
    
    [plusButton setImage:plusImage forState:UIControlStateNormal];
    [plusButton setImage:plusImage forState:UIControlStateHighlighted];
    
    [plusButton addTarget:self
                   action:@selector(onProductSelected)
         forControlEvents:UIControlEventTouchDown];
    
    [self addSubview:plusButton];
    [plusButton centerInSuperview];
}

#pragma mark IBActions

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
       shouldReceiveTouch:(UITouch *)touch
{
    return YES;
}

- (void)onProductSelected
{
    [self.delegate onProductSelected:self];
}

-(void)onLikePressed
{
    [self.delegate onProductLiked:self];
}

@end
