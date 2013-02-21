//
//  ProductDetailViewController.m
//  eshop
//
//  Created by Pierluigi Cifani on 12/10/12.
//  Copyright (c) 2013 Oonair. All rights reserved.
//

#import "ProductDetailViewController.h"

#import "SBProduct+NSDictionary.h"
#import "SBSessionHandler.h"

#import "SBProductContainer.h"

#import "SBCustomizer.h"

#import "UIView+CenterInSuperView.h"
#import "UIImageView+ActivityIndicator.h"

#import <MessageUI/MessageUI.h>
#import <QuartzCore/QuartzCore.h>

@interface ProductDetailViewController () <MFMailComposeViewControllerDelegate>


@property (nonatomic, weak) id <NavigateToProductProtocol> navigateDelegate;
@property (nonatomic) BOOL navigateToProductMode;


@property (strong, nonatomic) IBOutlet UIImageView *productImageView;

@property (weak, nonatomic) IBOutlet UIButton *sizeButton;
@property (weak, nonatomic) IBOutlet UIButton *addToCartButton;
@property (weak, nonatomic) IBOutlet UIButton *priceButton;


//iPad Layout
@property (weak, nonatomic) IBOutlet UIView *productContainerView;
@property (weak, nonatomic) IBOutlet UIView *productDetailContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *detail1ImageView;
@property (weak, nonatomic) IBOutlet UIImageView *detail2ImageView;
@property (weak, nonatomic) IBOutlet UIImageView *detail3ImageView;

@end

@implementation ProductDetailViewController

- (id)initWithProduct:(NSDictionary *)aProduct forIndex:(NSInteger)index;
{
    if (INTERFACE_IS_PHONE) {
        self = [super initWithNibName:@"ProductDetailViewController_Phone" bundle:nil];
    } else {
        self = [super initWithNibName:@"ProductDetailViewController" bundle:nil];
    }

    if (self) {
        // Custom initialization
        self.product = aProduct;
        self.index = index;
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"[DEBUG] dealloc %@", self);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self loadImages];
    
    [_addToCartButton setTitleColor:[UIColor whiteColor]
                           forState:UIControlStateNormal];
        
    UIImage *addToCartImage = [[UIImage imageNamed:@"bt-black"] resizableImageWithCapInsets:UIEdgeInsetsMake(17, 5, 17, 5)];
    UIImage *addToCartHighImage = [[UIImage imageNamed:@"bt-black-over"] resizableImageWithCapInsets:UIEdgeInsetsMake(17, 5, 17, 5)];

    [_addToCartButton setBackgroundImage:addToCartImage
                                forState:UIControlStateNormal];
    [_addToCartButton setBackgroundImage:addToCartHighImage
                                forState:UIControlStateHighlighted];

    
    UIImage *sizeImage = [[UIImage imageNamed:@"bt-outline"] resizableImageWithCapInsets:UIEdgeInsetsMake(17, 5, 17, 5)];
    UIImage *sizeHighImage = [[UIImage imageNamed:@"bt-outline-over"] resizableImageWithCapInsets:UIEdgeInsetsMake(17, 5, 17, 5)];
    
    [_sizeButton setBackgroundImage:sizeImage
                           forState:UIControlStateNormal];
    
    [_sizeButton setBackgroundImage:sizeHighImage
                           forState:UIControlStateHighlighted];

    
    [_priceButton setTitleColor:[UIColor colorWithRed:83/255.0 green:83/255.0 blue:83/255.0 alpha:1.0]
                       forState:UIControlStateNormal];
    [_priceButton setTitle:[_product objectForKey:@"price"]
                  forState:UIControlStateNormal];
    
    self.productDetailContainerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg-diagonalines"]];
    self.productContainerView.backgroundColor = [UIColor whiteColor];

    _detail1ImageView.layer.cornerRadius = 8.0f;
    _detail1ImageView.layer.borderColor = [UIColor colorWithRed:192/255.0
                                                       green:192/255.0
                                                        blue:192/255.0
                                                       alpha:1.0].CGColor;

    _detail2ImageView.layer.cornerRadius = 8.0f;
    _detail2ImageView.layer.borderColor = [UIColor colorWithRed:192/255.0
                                                          green:192/255.0
                                                           blue:192/255.0
                                                          alpha:1.0].CGColor;

    _detail3ImageView.layer.cornerRadius = 8.0f;
    _detail3ImageView.layer.borderColor = [UIColor colorWithRed:192/255.0
                                                          green:192/255.0
                                                           blue:192/255.0
                                                          alpha:1.0].CGColor;

    _detail1ImageView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    _detail1ImageView.layer.shadowOffset = CGSizeMake(0, 1);
    _detail1ImageView.layer.shadowOpacity = 1;
    _detail1ImageView.layer.shadowRadius = 3.0;
    [_detail1ImageView.layer setShouldRasterize:YES];
    [_detail1ImageView.layer setRasterizationScale:[[UIScreen mainScreen] scale]];

    _detail2ImageView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    _detail2ImageView.layer.shadowOffset = CGSizeMake(0, 1);
    _detail2ImageView.layer.shadowOpacity = 1;
    _detail2ImageView.layer.shadowRadius = 3.0;
    [_detail2ImageView.layer setShouldRasterize:YES];
    [_detail2ImageView.layer setRasterizationScale:[[UIScreen mainScreen] scale]];

    _detail3ImageView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    _detail3ImageView.layer.shadowOffset = CGSizeMake(0, 1);
    _detail3ImageView.layer.shadowOpacity = 1;
    _detail3ImageView.layer.shadowRadius = 3.0;
    [_detail3ImageView.layer setShouldRasterize:YES];
    [_detail3ImageView.layer setRasterizationScale:[[UIScreen mainScreen] scale]];
    
    if (_navigateToProductMode)
    {
        [self configureForNavigateToProductMode];
    }
    
}

- (void) configureForNavigateToProductMode
{
    if (INTERFACE_IS_PHONE)
    {
        self.navigationItem.title = [_product objectForKey:@"name"];
        
        UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
        [backButton setBackgroundImage:[UIImage imageNamed:@"bt-back"]
                              forState:UIControlStateNormal];
        [backButton setBackgroundImage:[UIImage imageNamed:@"bt-back-over"]
                              forState:UIControlStateHighlighted];
        
        [backButton setTitle:@"Back"
                    forState:UIControlStateNormal];
        
        [backButton.titleLabel setFont:[[SBCustomizer sharedCustomizer] defaultFontOfSize:12.0f]];
        [backButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 5.0f, 0.0f, 0.0f)];
        
        [backButton addTarget:self
                       action:@selector(handleBack:)
             forControlEvents:UIControlEventTouchDown];
        
        UIBarButtonItem *barBackButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        
        self.navigationItem.leftBarButtonItem = barBackButton;
    }
    else
    {
        self.navigationItem.rightBarButtonItem = [[SBSessionHandler sharedHandler] getShareBuyButton];
    }
}

- (void)setNavigateToProductDelegate:(id <NavigateToProductProtocol>)delegate;
{
    if (delegate) {
        self.navigateToProductMode = YES;
        self.navigateDelegate = delegate;
    }
}

- (void) handleBack:(id)sender
{
    // pop to root view controller
    [self.navigateDelegate userTappedOnDoneButton];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (_navigateToProductMode) {
        return;
    }
    
    SBProduct *product = [SBProduct productFromDictionary:self.product];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SBCurrentProduct
                                                        object:product];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_navigateToProductMode) {
        return;
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:SBCurrentProduct
                                                        object:nil];
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{

}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onSelectSize:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Feature not available in your country" message:nil delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [alertView show];
}

- (IBAction)onAddToCart:(id)sender
{
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;
        [mailer setSubject:@"I'm interested in a product"];
        NSArray *toRecipients = [NSArray arrayWithObjects:@"mobiledev@oonair.com", nil];
        [mailer setToRecipients:toRecipients];

        NSString *productURL = [self.product objectForKey:@"large_image"];

        NSString *emailBody = [NSString stringWithFormat:@"I am interested in this product: %@, please get in touch with me", productURL];
        [mailer setMessageBody:emailBody isHTML:YES];
        mailer.modalPresentationStyle = UIModalPresentationPageSheet;
        [self.navigationController presentViewController:mailer
                                                animated:YES
                                              completion:nil];
    }
    else
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:
                                                    @"mailto:mobiledev@oonair.com"]];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{

    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Internal

- (void) loadProductImageForURL:(NSURL *)url inView:(UIImageView *)imageView
{
    UIActivityIndicatorView *aSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [imageView addSubview:aSpinner];
    [aSpinner centerInSuperview];
    [aSpinner startAnimating];

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        NSData *imageData = [NSData dataWithContentsOfURL:url];
        UIImage *aImage = [UIImage imageWithData:imageData];
        
        dispatch_queue_t mainqueue = dispatch_get_main_queue();
        dispatch_async(mainqueue, ^{
            
            //Set the image
            imageView.image = aImage;

            //Set the spinner
            [aSpinner stopAnimating];
            [aSpinner removeFromSuperview];
            
        });
    });

}

- (void) loadImages
{
    self.productImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.productImageView.clipsToBounds = YES;
    
    self.detail1ImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.detail1ImageView.clipsToBounds = NO;

    self.detail2ImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.detail2ImageView.clipsToBounds = NO;

    self.detail3ImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.detail3ImageView.clipsToBounds = NO;
    
    NSURL *productURL = [NSURL URLWithString:[_product objectForKey:@"large_image_a"]];

    [self loadProductImageForURL:productURL inView:self.productImageView];
    
    NSURL *productDetail1URL = [NSURL URLWithString:[_product objectForKey:@"large_image_a"]];

    [self loadProductImageForURL:productDetail1URL inView:self.detail1ImageView];

    NSURL *productDetail2URL = [NSURL URLWithString:[_product objectForKey:@"large_image_b"]];

    [self loadProductImageForURL:productDetail2URL inView:self.detail2ImageView];

    NSURL *productDetail3URL = [NSURL URLWithString:[_product objectForKey:@"large_image_c"]];
    
    [self loadProductImageForURL:productDetail3URL inView:self.detail3ImageView];


}

@end
