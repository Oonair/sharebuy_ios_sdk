//
//  SBConnectionViewController.m
//  eshop
//
//  Created by Pierluigi Cifani on 12/10/12.
//  Copyright (c) 2012 Pierluigi Cifani. All rights reserved.
//

#import "SBConnectionViewController.h"
#import "ShareBuy.h"

@interface SBConnectionViewController ()
{
    TConnectionViewState state;
}

@property (strong, nonatomic) IBOutlet UIButton *facebookButton;

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
            self.facebookView.hidden = YES;
        }
            break;
        case EStateOffline:
        {
            self.connectingView.hidden = YES;
            self.offlineView.hidden = NO;
            self.facebookView.hidden = YES;
        }
            break;
        case EStateConnectToFacebook:
        {
            self.connectingView.hidden = YES;
            self.offlineView.hidden = YES;
            self.facebookView.hidden = NO;
        }
            break;

        default:
            break;
    }
}

- (IBAction)onFacebookLogin:(id)sender
{
    [[ShareBuy sharedInstance] loginFacebook];
}
- (IBAction)onReconnect:(id)sender {
    [[ShareBuy sharedInstance] attemptReconnection];
}

@end
