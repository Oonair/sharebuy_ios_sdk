//
//  ProductCategoryCell.m
//  eshop
//
//  Created by Pierluigi Cifani on 2/18/13.
//  Copyright (c) 2013 Oonair. All rights reserved.
//

#import "ProductCategoryCell.h"
#import <QuartzCore/QuartzCore.h>

@interface ProductCategoryCell ()

@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@end

@implementation ProductCategoryCell

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

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated;
{
    [super setHighlighted:highlighted animated:animated];
    if (highlighted)
    {
        [_containerView setBackgroundColor:[UIColor colorWithRed:255/255.0f
                                                         green:239/255.0f
                                                          blue:191/255.0f
                                                         alpha:1.0]];

    }
    else
    {
        [_containerView setBackgroundColor:[UIColor whiteColor]];
    }
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    _containerView.layer.cornerRadius = 8.0f;
    _containerView.layer.borderWidth = 1.0f;
    _containerView.layer.borderColor = [UIColor colorWithRed:192/255.0
                                                        green:192/255.0
                                                        blue:192/255.0
                                                       alpha:1.0].CGColor;
    
    _containerView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    _containerView.layer.shadowOffset = CGSizeMake(0, 1);
    _containerView.layer.shadowOpacity = 1;
    _containerView.layer.shadowRadius = 3.0;
    [_containerView.layer setShouldRasterize:YES];
    [_containerView.layer setRasterizationScale:[[UIScreen mainScreen] scale]];

    [_categoryLabel setTextColor:[UIColor darkGrayColor]];
    _categoryLabel.highlightedTextColor = [UIColor darkGrayColor];

    
    UIView *selectedView = [[UIView alloc] init];
    [selectedView setBackgroundColor:[UIColor clearColor]];
    [self setSelectedBackgroundView:selectedView];
    
    [self setBackgroundColor:[UIColor clearColor]];
    
}

+ (CGFloat) cellHeight;
{
    return 70.0;
}

- (void) setCategoryName:(NSString *)name;
{
    self.categoryLabel.text = name;
}

@end
