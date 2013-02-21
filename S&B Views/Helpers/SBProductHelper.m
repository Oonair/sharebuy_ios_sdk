//
//  SBProductHelper.m
//  eshop
//
//  Created by Pierluigi Cifani on 2/18/13.
//  Copyright (c) 2013 Oonair. All rights reserved.
//

#import "SBProductHelper.h"
#import "SDWebImageManager.h"
#import "UIView+CenterInSuperView.h"
#import "SBProduct.h"
#import <QuartzCore/QuartzCore.h>

@interface SBProductHelper ()

@property (weak, nonatomic) IBOutlet UIButton *okButton;
@property (weak, nonatomic) IBOutlet UIImageView *productImage;
@property (weak, nonatomic) id <SBHelperProtocol> delegate;

@property (nonatomic, strong) id<SDWebImageOperation> task;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@end

@implementation SBProductHelper

- (id)initWithFrame:(CGRect)frame
{
    UINib *aXib = [UINib nibWithNibName:@"SBProductHelper" bundle:[NSBundle mainBundle]];
    SBProductHelper *aView = [[aXib instantiateWithOwner:self options:nil] lastObject];
    
    if (aView)
    {
        self = aView;
        aView.frame = frame;
        [self initialize];
    }
    
    return self;
}

- (void) dealloc
{
    [self.task cancel];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void) setHelperDelegate:(id <SBHelperProtocol>)delegate;
{
    self.delegate = delegate;
}

- (void)initialize
{
    UIColor *backGroundColor = [UIColor colorWithWhite:1.0f alpha:0.9];
    self.backgroundColor = backGroundColor;
    
    UIImage *reconnectImage = [[UIImage imageNamed:@"bt-black"] resizableImageWithCapInsets:UIEdgeInsetsMake(17, 5, 17, 5)];
    UIImage *reconnectImageHigh = [[UIImage imageNamed:@"bt-black-over"] resizableImageWithCapInsets:UIEdgeInsetsMake(17, 5, 17, 5)];
    
    [_okButton setBackgroundImage:reconnectImage
                         forState:UIControlStateNormal];
    
    [_okButton setBackgroundImage:reconnectImageHigh
                         forState:UIControlStateHighlighted];
    
    [_okButton setTitleColor:[UIColor whiteColor]
                    forState:UIControlStateNormal];
    
    [self setBorderAndShadowToView:_containerView];
}

- (void)setBorderAndShadowToView:(UIView *)view
{
    view.layer.cornerRadius = 8.0f;
    view.layer.borderColor = [UIColor colorWithRed:192/255.0
                                             green:192/255.0
                                              blue:192/255.0
                                             alpha:1.0].CGColor;
    
    view.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    view.layer.shadowOffset = CGSizeMake(0, 1);
    view.layer.shadowOpacity = 1;
    view.layer.shadowRadius = 3.0;
    [view.layer setShouldRasterize:YES];
    [view.layer setRasterizationScale:[[UIScreen mainScreen] scale]];
}

- (void)configureForProduct:(SBProduct *)product;
{
    NSURL *imageURL = [product getImageURLForSize:_productImage.frame.size];
    [self setProductImageFromURL:imageURL];
}

- (void)setProductImageFromURL:(NSURL *)url;
{
    __block id loadTask = nil;
    SDWebImageManager *manager = [SDWebImageManager sharedManager];

    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.productImage addSubview:indicator];
    [indicator startAnimating];
    [indicator centerInSuperview];
    
    __weak typeof(self) weakSelf = self;

    loadTask = [manager downloadWithURL:url
                                options:SDWebImageLowPriority
                               progress:nil
                              completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished){
                                  [weakSelf.productImage setImage:image];
                                  weakSelf.task = nil;
                                  [indicator removeFromSuperview];
                              }];

    self.task = loadTask;
}

- (IBAction)onOKPressed:(id)sender
{
    if ([_delegate respondsToSelector:@selector(onHelperWithProductTapped)]) {
        [self.delegate onHelperWithProductTapped];
    }
}

@end
