//
//  ProductDetailViewController.m
//  eshop
//
//  Created by Pierluigi Cifani on 12/10/12.
//  Copyright (c) 2012 Pierluigi Cifani. All rights reserved.
//

#import "ProductDetailViewController.h"

#import "SBProduct+NSDictionary.h"
#import "SBSessionHandler.h"

extern NSString *SBCurrentProduct;

@interface ProductDetailViewController ()
@property (nonatomic, strong) NSDictionary *product;
@end

@implementation ProductDetailViewController

- (id)initWithProduct:(NSDictionary *)aProduct
{
    if (INTERFACE_IS_PHONE) {
        self = [super initWithNibName:@"ProductDetailViewController_Phone" bundle:nil];
    } else {
        self = [super initWithNibName:@"ProductDetailViewController" bundle:nil];
    }

    if (self) {
        // Custom initialization
        self.product = aProduct;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.rightBarButtonItem = [[SBSessionHandler sharedHandler] getShareBuyButton];

    self.navigationItem.title = [self.product objectForKey:@"p_name"];
    [self loadProductImage];
    
    SBProduct *product = [SBProduct productFromDictionary:self.product];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SBCurrentProduct
                                                        object:product];
    
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:SBCurrentProduct
                                                        object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark Internal

- (void) loadProductImage
{
    self.productImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    //Place activity indicator when downloading the image
    UIActivityIndicatorView *aSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.view addSubview:aSpinner];
    [aSpinner setCenter:self.productImageView.center];
    [aSpinner startAnimating];
    
    NSString *productURL = [self.product objectForKey:@"large_image"];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(queue, ^{
        
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:productURL]];
        UIImage *aImage = [UIImage imageWithData:imageData];
        
        dispatch_queue_t mainqueue = dispatch_get_main_queue();
        dispatch_async(mainqueue, ^{
            
            //Set the image
            self.productImageView.image = aImage;
            
            //Set the spinner
            [aSpinner stopAnimating];
            [aSpinner removeFromSuperview];
            
        });
    });
}

@end
