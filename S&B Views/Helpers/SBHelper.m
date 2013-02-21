//
//  SBHelper.m
//  eshop
//
//  Created by Pierluigi Cifani on 2/18/13.
//  Copyright (c) 2013 Oonair. All rights reserved.
//

#import "SBHelper.h"

@interface SBHelper ()

@property (weak, nonatomic) IBOutlet UIButton *okButton;
@property (weak, nonatomic) id <SBHelperProtocol> delegate;

@end

@implementation SBHelper

- (id)initWithFrame:(CGRect)frame
{
    UINib *aXib = [UINib nibWithNibName:@"SBHelper" bundle:[NSBundle mainBundle]];
    SBHelper *aView = [[aXib instantiateWithOwner:self options:nil] lastObject];
    
    if (aView)
    {
        self = aView;
        aView.frame = frame;
        [self initialize];
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
}

- (IBAction)onOKPressed:(id)sender
{
    if ([_delegate respondsToSelector:@selector(onHelperTapped)])
    {
        [self.delegate onHelperTapped];
    }
}

@end
