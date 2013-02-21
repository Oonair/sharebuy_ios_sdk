//
//  SBBadgeView.m
//  eshop
//
//  Created by Pierluigi Cifani on 2/11/13.
//  Copyright (c) 2013 Oonair. All rights reserved.
//

#import "SBBadgeView.h"
#import "SBCustomizer.h"

#define kBadgeImage [UIImage imageNamed:@"badge"]

@implementation SBBadgeView

- (id)initWithFrame:(CGRect)frame value:(NSInteger)value;
{
    self = [super initWithImage:kBadgeImage];
    if (self) {
        // Initialization code
        [self setFrame:frame];
        
        UILabel *badgeValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [badgeValueLabel setFont:[[SBCustomizer sharedCustomizer] defaultFontOfSize:10.0f]];
        [badgeValueLabel setTextColor:[UIColor whiteColor]];
        [badgeValueLabel setBackgroundColor:[UIColor clearColor]];
        [badgeValueLabel setTextAlignment:NSTextAlignmentCenter];
        
        NSString *badgeValueText = [NSString stringWithFormat:@"%d", value];
        [badgeValueLabel setText:badgeValueText];
        
        [self addSubview:badgeValueLabel];
        
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

@end
