//
//  SBRoomCell.h
//  eshop
//
//  Created by Pierluigi Cifani on 12/20/12.
//  Copyright (c) 2013 Oonair. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SBRoom;

@interface SBRoomCell : UITableViewCell

+ (CGFloat)cellHeight;

- (void)configureForRoom:(SBRoom *)room;
- (void)setLoadingState;

@property (strong, nonatomic) IBOutlet UILabel *roomNameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *roomImageView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UIButton *roomPendingEvents;
@property (strong, nonatomic) IBOutlet UILabel *roomLastEventLabel;
@property (weak, nonatomic) IBOutlet UILabel *roomLastEventDateLabel;

@end
