//
//  SBWelcomeViewController.m
//  eshop
//
//  Created by Pierluigi Cifani on 2/13/13.
//  Copyright (c) 2013 Oonair. All rights reserved.
//

#import "SBWelcomeViewController.h"
#import "ShareBuy.h"
#import "UIButton+ActivityIndicator.h"
#import <QuartzCore/QuartzCore.h>

@interface SBWelcomeViewController ()
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;

@end

@implementation SBWelcomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIImage *blueButton = [[UIImage imageNamed:@"bt-facebook"] resizableImageWithCapInsets:UIEdgeInsetsMake(17, 5, 17, 5)];
    UIImage *blueButtonHighlighted = [[UIImage imageNamed:@"bt-facebook-over" ] resizableImageWithCapInsets:UIEdgeInsetsMake(17, 5, 17, 5)];
    
    [_facebookButton setBackgroundImage:blueButton
                               forState:UIControlStateNormal];
    [_facebookButton setBackgroundImage:blueButtonHighlighted
                               forState:UIControlStateHighlighted];
    
    [_facebookButton setImage:[UIImage imageNamed:@"ic-facebook"]
                     forState:UIControlStateNormal];
    
    _containerView.layer.cornerRadius = 8.0f;
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

    self.title = @"Ask a Friend";
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg-diagonalines"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onFacebookPressed:(id)sender
{
    [_facebookButton startActivityIndicator];
    [[ShareBuy sharedInstance] loginFacebook];
}

@end
