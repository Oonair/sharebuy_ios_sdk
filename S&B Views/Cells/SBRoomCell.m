//
//  SBRoomCell.m
//  eshop
//
//  Created by Pierluigi Cifani on 12/20/12.
//  Copyright (c) 2012 Pierluigi Cifani. All rights reserved.
//

#import "SBRoomCell.h"

#import "SBRoom.h"
#import "SBContact.h"

#import "SBEvent.h"
#import "SBEventMessage.h"
#import "SBEventProduct.h"

#import "SDWebImageManager.h"

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
        self.roomNameLabel.text = [room getRoomContactsStringRepresentation];
        
        [self setImageForRoom:room];
        
        [self setPendingEventsBadge:room];
        
        [self setLastEventLabel:room];
    }
    else
    {
        [self setLoadingState];
    }
}

#pragma mark Internal

- (void) setImageForRoom:(SBRoom *)room
{
    if ([[room getRoomContacts] count] == 0)
    {
        [self.roomImageView setImage:nil];
    }
    else if ([[room getRoomContacts] count] == 1)
    {
        SBContact *contact = [[room getRoomContacts] objectAtIndex:0];
        [self setImageForContact:contact];
    }
    else
    {
        [self.roomImageView setImage:[UIImage imageNamed:@"group-chat"]];
    }
}

- (void) setImageForContact:(SBContact *)contact
{
    NSURL *photoURL = [contact getThumbnailURL];
    
    if (photoURL) {
        id loadTask = nil;
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        
        __weak SBRoomCell *blockSelf = self;
        
        [self.roomImageView setImage:[UIImage imageNamed:@"no-contact"]];

        loadTask = [manager downloadWithURL:photoURL
                                    options:SDWebImageLowPriority
                                   progress:nil
                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished){
                                      
                                      [self.roomImageView setImage:image];
                                      blockSelf.task = nil;
                                  }];
        
        self.task = loadTask;
    } else {
        [self.roomImageView setImage:[UIImage imageNamed:@"no-contact"]];
    }
}

- (void) setPendingEventsBadge:(SBRoom *)room
{
    if ([room pendingEvents])
    {
        self.roomPendingEvents.hidden = NO;
        self.roomPendingEvents.text = [NSString stringWithFormat:@"%d", [room pendingEvents]];
    }
    else
    {
        self.roomPendingEvents.hidden = YES;
    }

}
- (void) setLastEventLabel:(SBRoom *)room
{
    self.roomLastEventLabel.hidden = NO;
    
    SBEvent *event = [[room getRoomEvents] lastObject];
    
    if (event.kind == EEventTextMessage) {
        SBEventMessage *message = (SBEventMessage *) event;
        self.roomLastEventLabel.text = message.body;
    } else if (event.kind == EEventProductShared) {
        self.roomLastEventLabel.text =  @"Shared a Product";
    } else if (event.kind == EEventLikeProduct) {
        self.roomLastEventLabel.text =  @"Like a Product";
    } else if (event.kind == EEventLikeStopProduct) {
        self.roomLastEventLabel.text =  @"Don't Like a Product";
    }
}

- (void) destroyImageDownloadTask
{
    [self.task cancel];
    self.task = nil;
}

@end
