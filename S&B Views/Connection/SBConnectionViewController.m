//
//  SBConnectionViewController.m
//  eshop
//
//  Created by Pierluigi Cifani on 12/10/12.
//  Copyright (c) 2013 Oonair. All rights reserved.
//

#import "SBConnectionViewController.h"
#import "ShareBuy.h"

#import <QuartzCore/QuartzCore.h>

@interface SBConnectionViewController ()
{
    TConnectionViewState state;
}
@property (weak, nonatomic) IBOutlet UIButton *reconnectButton;

@end

@implementation SBConnectionViewController

- (id)initWithState:(TConnectionViewState)aState;
{
    self = [super initWithNibName:@"SBConnectionViewController"
                           bundle:nil];
    if (self) {
        // Custom initialization
        state = aState;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setCurrentState:state];
    
    UIImage *reconnectImage = [[UIImage imageNamed:@"bt-black"] resizableImageWithCapInsets:UIEdgeInsetsMake(17, 5, 17, 5)];
    UIImage *reconnectImageHigh = [[UIImage imageNamed:@"bt-black-over"] resizableImageWithCapInsets:UIEdgeInsetsMake(17, 5, 17, 5)];
    
    [_reconnectButton setBackgroundImage:reconnectImage
                                forState:UIControlStateNormal];
    
    [_reconnectButton setBackgroundImage:reconnectImageHigh
                                forState:UIControlStateHighlighted];
    
    [_reconnectButton setTitleColor:[UIColor whiteColor]
                           forState:UIControlStateNormal];
    
    [_reconnectButton setTitleColor:[UIColor whiteColor]
                           forState:UIControlStateHighlighted];
 
    [self setBorderAndShadowToView:_offlineView];
    [self setBorderAndShadowToView:_connectingView];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)setCurrentState:(TConnectionViewState)aState;
{
    state = aState;
    
    switch (state) {
        case EStateConnecting:
        {
            self.connectingView.hidden = NO;
            self.offlineView.hidden = YES;
        }
            break;
        case EStateOffline:
        {
            self.connectingView.hidden = YES;
            self.offlineView.hidden = NO;
        }
            break;
        default:
            break;
    }
}

- (IBAction)onReconnect:(id)sender {
    [[ShareBuy sharedInstance] attemptReconnection];
}

@end
