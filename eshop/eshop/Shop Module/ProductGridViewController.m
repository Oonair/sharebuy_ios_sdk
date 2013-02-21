//
//  ProductGridViewController.m
//  eshop
//
//  Created by Pierluigi Cifani on 12/10/12.
//  Copyright (c) 2013 Oonair. All rights reserved.
//

#import "ProductGridViewController.h"

#import <QuartzCore/QuartzCore.h>
#import "GMGridView.h"
#import "SBJsonParser.h"

#import "ProductPageViewController.h"
#import "ProductDetailViewController.h"

#import "SBSessionHandler.h"

#import "SBProductContainer.h"
#import "SBProduct+NSDictionary.h"
#import "SBNavigationController.h"
#import "IIViewDeckController.h"

#define kProductSizePhone   CGSizeMake(130, 180)
#define kProductSizePad     CGSizeMake(272, 350)

@interface ProductGridViewController () <GMGridViewDataSource, GMGridViewActionDelegate>
{
    dispatch_queue_t photoDownloadQueue ;
}

@property (nonatomic, strong) GMGridView *productGrid;
@property (nonatomic, strong) NSArray *products;
@property (nonatomic, strong) NSDictionary *category;

@end

@implementation ProductGridViewController

- (id)initWithCategory:(NSDictionary *)category
{
    if (INTERFACE_IS_PHONE) {
        self = [super initWithNibName:@"ProductGridViewController_Phone" bundle:nil];
    } else {
        self = [super initWithNibName:@"ProductGridViewController" bundle:nil];
    }

    if (self) {
        // Custom initialization
        
        self.category = category;
        self.products = [_category objectForKey:@"products"];
        
        self.title = [_category objectForKey:@"name"];

        photoDownloadQueue = dispatch_queue_create("com.eshop.photo", DISPATCH_QUEUE_SERIAL);

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //Create the grid
    [self createProductGrill];
        
    self.navigationItem.rightBarButtonItem = [[SBSessionHandler sharedHandler] getShareBuyButton];
            
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg-diagonalines"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    NSLog(@"[DEBUG] dealloc %@", self);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

#pragma mark GMGridViewDataSource

- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView;
{
    return [self.products count];
}
- (CGSize)sizeForItemsInGMGridView:(GMGridView *)gridView;
{
    if (INTERFACE_IS_PHONE)
    {
        return kProductSizePhone;
    }
    else
    {
        return kProductSizePad;
    }
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index;
{
    GMGridViewCell *cell = [gridView dequeueReusableCell];
    UIImageView *imageView = (UIImageView *) cell.contentView;
    imageView.image = nil;

    if (!cell)
    {
        cell = [self createCustomGridCell];
    }
    
    [self downloadImageOfProduct:[self.products objectAtIndex:index]
                         forCell:cell];
    return cell;
}

#pragma mark GMGridViewActionDelegate
//////////////////////////////////////////////////////////////

- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position
{    
    [self createProductPageViewWithIndex:position];
}

#pragma mark Internal

- (void) createProductPageViewWithIndex:(NSInteger)index
{    
    ProductPageViewController *aPageController = [[ProductPageViewController alloc] initWithProductArray:_products startIndex:index];
    [self.navigationController pushViewController:aPageController animated:YES];
}

-(void)createProductGrill
{
    NSInteger spacing = INTERFACE_IS_PHONE ? 10 : 15;
    
    self.productGrid = [[GMGridView alloc] initWithFrame:self.view.bounds];
    self.productGrid.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.productGrid.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.productGrid];
    
    self.productGrid.style = GMGridViewStyleSwap;
    self.productGrid.itemSpacing = spacing;
    self.productGrid.minEdgeInsets = UIEdgeInsetsMake(spacing, spacing, spacing, spacing);
    self.productGrid.centerGrid = YES;
    self.productGrid.dataSource = self;
    self.productGrid.actionDelegate = self;
}

- (GMGridViewCell *) createCustomGridCell
{
    CGSize size = [self sizeForItemsInGMGridView:self.productGrid];
    GMGridViewCell *cell = [[GMGridViewCell alloc] init];
    cell.deleteButtonIcon = nil;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    imageView.clipsToBounds = YES;
    imageView.backgroundColor = [UIColor lightGrayColor];
    imageView.layer.masksToBounds = YES;
    imageView.layer.cornerRadius = 3.0f;
    imageView.layer.shadowColor = [UIColor grayColor].CGColor;
    imageView.layer.shadowOffset = CGSizeMake(5, 5);
    imageView.layer.shadowPath = [UIBezierPath bezierPathWithRect:imageView.bounds].CGPath;
    imageView.layer.shadowRadius = 8;
    [imageView.layer setShouldRasterize:YES];
    [imageView.layer setRasterizationScale:[[UIScreen mainScreen] scale]];

    cell.contentView = imageView;
    return cell;
}

- (void) downloadImageOfProduct:(NSDictionary *)product
                        forCell:(GMGridViewCell *)cell
{
    UIImageView *imageView = (UIImageView *) cell.contentView;
    
    imageView.image = nil;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    UIActivityIndicatorView *aSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [imageView addSubview:aSpinner];
    [aSpinner setCenter:imageView.center];
    [aSpinner startAnimating];
        
    dispatch_async(photoDownloadQueue, ^{

        NSURL *url = [NSURL URLWithString:[product objectForKey:@"large_image_a"]];
        
        NSData *imageData = [NSData dataWithContentsOfURL:url];
        UIImage *aImage = [UIImage imageWithData:imageData];
        
        dispatch_queue_t mainqueue = dispatch_get_main_queue();
        dispatch_async(mainqueue, ^{
            
            [imageView setImage:aImage];
            [aSpinner stopAnimating];
            [aSpinner removeFromSuperview];
        });
    });
}

@end
