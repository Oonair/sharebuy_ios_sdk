//
//  SBRoomCell.m
//  eshop
//
//  Created by Pierluigi Cifani on 12/20/12.
//  Copyright (c) 2013 Oonair. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "SBRoomCell.h"

#import "SBRoom.h"
#import "SBContact.h"
#import "SBProduct.h"

#import "SBEvent.h"
#import "SBEventMessage.h"
#import "SBEventProduct.h"

#import "SDWebImageManager.h"
#import "SBCustomizer.h"

#import "NSDate+Helper.h"

@interface SBRoomCell ()
@property (nonatomic, strong) id<SDWebImageOperation> task;
@end

@implementation SBRoomCell

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}

+ (CGFloat)cellHeight;
{
    return 55.0f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    CALayer * layer = [_roomImageView layer];
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
    
    _roomNameLabel.highlightedTextColor = [UIColor blackColor];
    _roomLastEventLabel.highlightedTextColor = [UIColor blackColor];
    _roomLastEventDateLabel.highlightedTextColor = [UIColor darkGrayColor];

    SBCustomizer *customizer = [SBCustomizer sharedCustomizer];

    [_roomPendingEvents setBackgroundImage:[customizer badgeImage]
                                  forState:UIControlStateNormal];
}

- (void)dealloc {
    [self destroyImageDownloadTask];
}

- (void) prepareForReuse
{
    [self destroyImageDownloadTask];
    [super prepareForReuse];
}

- (void)setLoadingState
{
    self.roomLastEventDateLabel.hidden = YES;
    self.roomLastEventLabel.hidden = YES;
    self.roomPendingEvents.hidden = YES;
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
    self.roomNameLabel.text = @"Loading...";
    [self setImageForContact:nil];
}

- (void)configureForRoom:(SBRoom *)room;
{
    if ([room getRoomState] == ERoomStateReady)
    {
        self.activityIndicator.hidden = YES;
        
        NSString *roomParticipants = [room getRoomContactsStringRepresentation];
        if (roomParticipants == nil) roomParticipants = @"Empty Room";
        
        self.roomNameLabel.text = roomParticipants;
        
        [self setImageForRoom:room];
        
        [self setPendingEventsBadge:room];
        
        [self setLastEventLabel:room];
        
        [self setLastEventDateLabel:room];
    }
    else
    {
        [self setLoadingState];
    }
}

#pragma mark Internal

- (void) setImageForRoom:(SBRoom *)room
{
    SBCustomizer *customizer = [SBCustomizer sharedCustomizer];
    
    if ([[room getRoomContacts] count] == 0)
    {
        [self.roomImageView setImage:[customizer noContactPlaceholder]];
    }
    else if ([[room getRoomContacts] count] == 1)
    {
        SBContact *contact = [[room getRoomContacts] objectAtIndex:0];
        [self setImageForContact:contact];
    }
    else
    {
        [self.roomImageView setImage:[customizer groupChatPlaceholder]];
    }
}

- (void) setImageForContact:(SBContact *)contact
{
    NSURL *photoURL = [contact getThumbnailURL];
    SBCustomizer *customizer = [SBCustomizer sharedCustomizer];

    if (photoURL) {
        id loadTask = nil;
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        
        __weak SBRoomCell *blockSelf = self;
        
        [self.roomImageView setImage:[customizer noContactPlaceholder]];

        loadTask = [manager downloadWithURL:photoURL
                                    options:SDWebImageLowPriority
                                   progress:nil
                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished){
                                      
                                      [self.roomImageView setImage:image];
                                      blockSelf.task = nil;
                                  }];
        
        self.task = loadTask;
    } else {
        [self.roomImageView setImage:[customizer noContactPlaceholder]];
    }
}

- (void) setPendingEventsBadge:(SBRoom *)room
{
    if ([room pendingEvents])
    {
        self.roomPendingEvents.hidden = NO;
        [self.roomPendingEvents setTitle:[NSString stringWithFormat:@"%d", [room pendingEvents]]
                                forState:UIControlStateNormal];
    }
    else
    {
        self.roomPendingEvents.hidden = YES;
    }

}

- (void) setLastEventDateLabel:(SBRoom *)room
{
    SBEvent *event = [[room getRoomEvents] lastObject];
    NSDate *date = event.time;
    if (date) {
        NSString *output = [NSDate stringForDisplayFromDate:date
                                                   prefixed:YES
                                          alwaysDisplayTime:NO];
        
        [_roomLastEventDateLabel setText:output];
        _roomLastEventDateLabel.hidden = NO;
    }
}

- (void) setLastEventLabel:(SBRoom *)room
{
    _roomLastEventLabel.hidden = NO;
    
    SBEvent *event = [[room getRoomEvents] lastObject];
    
    if (event.kind == EEventTextMessage)
    {
        SBEventMessage *message = (SBEventMessage *) event;
        _roomLastEventLabel.text = message.body;
    }
    else if (event.kind == EEventProductShared)
    {
        SBEventProduct *productEvent = (SBEventProduct *) event;
        SBProduct *product = [room getProductForID:productEvent.productID];

        _roomLastEventLabel.text = [NSString stringWithFormat:@"Shared '%@'", product.name] ;
    }
    else if (event.kind == EEventLikeProduct)
    {
        SBEventProduct *productEvent = (SBEventProduct *) event;
        SBProduct *product = [room getProductForID:productEvent.productID];
        _roomLastEventLabel.text = [NSString stringWithFormat:@"Likes '%@'", product.name] ;
    }
    else if (event.kind == EEventLikeStopProduct)
    {
        SBEventProduct *productEvent = (SBEventProduct *) event;
        SBProduct *product = [room getProductForID:productEvent.productID];

        _roomLastEventLabel.text = [NSString stringWithFormat:@"Doesn't like '%@'", product.name] ;
    }
}

- (void) destroyImageDownloadTask
{
    [self.task cancel];
    self.task = nil;
}

@end
