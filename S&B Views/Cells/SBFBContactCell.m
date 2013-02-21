//
//  SBFBContactCell.m
//  eshop
//
//  Created by Pierluigi Cifani on 12/21/12.
//  Copyright (c) 2013 Oonair. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "SBFBContactCell.h"
#import "SBFBContact.h"

#import "SBCustomizer.h"

#import "SDWebImageManager.h"

@interface SBFBContactCell ()
@property (nonatomic, strong) id<SDWebImageOperation> task;
@end

@implementation SBFBContactCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void) prepareForReuse
{
    [self destroyImageDownloadTask];
    [super prepareForReuse];
}

+ (CGFloat) cellHeight;
{
    return 44.0f;
}

- (void) awakeFromNib
{
    CALayer * layer = [_contactImageView layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:3.0f];
    [layer setShouldRasterize: YES];
    [layer setRasterizationScale:[[UIScreen mainScreen] scale]];

    UIView *selectedView = [[UIView alloc] init];
    [selectedView setBackgroundColor:[UIColor colorWithRed:255/255.0f
                                                     green:239/255.0f
                                                      blue:191/255.0f
                                                     alpha:1.0]];
    [self setSelectedBackgroundView:selectedView];
    
    _contactNameLabel.highlightedTextColor = [UIColor blackColor];
}

-(void)configureForContact:(SBFBContact *)contact;
{
    self.contactNameLabel.text = [contact getFullName];
    [self setImageForContact:contact];
    [self setNormalMode];
    self.contactOnlineIndicator.hidden = !contact.isOnline;
}

- (void) setNormalMode;
{
    self.activityIndicator.hidden = YES;
}

- (void) setLoadingMode;
{
    self.activityIndicator.hidden = NO;
    self.contactOnlineIndicator.hidden = YES;
    [self.activityIndicator startAnimating];
}

#pragma mark Internal

- (void) setImageForContact:(SBFBContact *)contact
{
    NSURL *photoURL = [contact getThumbnailURL];
    SBCustomizer *customizer = [SBCustomizer sharedCustomizer];
    
    if (photoURL) {
        id loadTask = nil;
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        
        __weak SBFBContactCell *blockSelf = self;
        
        [self.contactImageView setImage:[customizer noContactPlaceholder]];
        
        loadTask = [manager downloadWithURL:photoURL
                                    options:SDWebImageLowPriority
                                   progress:nil
                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished){
                                      
                                      [self.contactImageView setImage:image];
                                      blockSelf.task = nil;
                                  }];
        
        self.task = loadTask;
    } else {
        [self.contactImageView setImage:[customizer noContactPlaceholder]];
    }
}


- (void) destroyImageDownloadTask
{
    if (self.task)
    {
        [self.task cancel];
        self.task = nil;
    }
}

@end
