//
//  SBFBContactCell.h
//  eshop
//
//  Created by Pierluigi Cifani on 12/21/12.
//  Copyright (c) 2013 Oonair. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SBFBContact;

@interface SBFBContactCell : UITableViewCell

- (void) configureForContact:(SBFBContact *)contact;

- (void) setNormalMode;
- (void) setLoadingMode;

+ (CGFloat) cellHeight;

@property (strong, nonatomic) IBOutlet UILabel *contactNameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *contactImageView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UIImageView *contactOnlineIndicator;

@end
