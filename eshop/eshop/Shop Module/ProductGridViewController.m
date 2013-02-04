//
//  ProductGridViewController.m
//  eshop
//
//  Created by Pierluigi Cifani on 12/10/12.
//  Copyright (c) 2012 Pierluigi Cifani. All rights reserved.
//

#import "ProductGridViewController.h"

#import <QuartzCore/QuartzCore.h>
#import "GMGridView.h"
#import "SBJsonParser.h"

#import "ProductDetailViewController.h"

#import "SBSessionHandler.h"

#define kProductSizePhone   CGSizeMake(85, 110)
#define kProductSizePad     CGSizeMake(200, 250)

@interface ProductGridViewController () <GMGridViewDataSource, GMGridViewActionDelegate>
{
    dispatch_queue_t photoDownloadQueue ;
}

@property (nonatomic, strong) GMGridView *productGrid;
@property (nonatomic, strong) NSArray *products;

@end

@implementation ProductGridViewController

- (id)init
{
    if (INTERFACE_IS_PHONE) {
        self = [super initWithNibName:@"ProductGridViewController_Phone" bundle:nil];
    } else {
        self = [super initWithNibName:@"ProductGridViewController" bundle:nil];
    }

    if (self) {
        // Custom initialization
        self.title = @"eShop";
        
        [self loadProductsFromJSON];
        
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc
{

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
    NSLog(@"GRID: user tapped on index %d", position);
    
    ProductDetailViewController *aDetailView = [[ProductDetailViewController alloc] initWithProduct:[self.products objectAtIndex:position]];
    [self.navigationController pushViewController:aDetailView animated:YES];
}

#pragma mark Internal

- (void) loadProductsFromJSON
{
    //Load Products from JSON
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"products" ofType:@"json"];
    NSError *requestError = nil;
    NSString *productsJsonStr = [NSString stringWithContentsOfFile:filePath encoding:NSASCIIStringEncoding error:&requestError];
    
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    self.products = [jsonParser objectWithString:productsJsonStr];
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
    imageView.backgroundColor = [UIColor lightGrayColor];
    imageView.layer.masksToBounds = NO;
    imageView.layer.cornerRadius = 8;
    imageView.layer.shadowColor = [UIColor grayColor].CGColor;
    imageView.layer.shadowOffset = CGSizeMake(5, 5);
    imageView.layer.shadowPath = [UIBezierPath bezierPathWithRect:imageView.bounds].CGPath;
    imageView.layer.shadowRadius = 8;
    
    cell.contentView = imageView;
    return cell;
}

- (void) downloadImageOfProduct:(NSDictionary *)product
                        forCell:(GMGridViewCell *)cell
{
    UIImageView *imageView = (UIImageView *) cell.contentView;
    
    imageView.image = nil;
    
    UIActivityIndicatorView *aSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [imageView addSubview:aSpinner];
    [aSpinner setCenter:imageView.center];
    [aSpinner startAnimating];
        
    dispatch_async(photoDownloadQueue, ^{
        
        NSURL *url;
        if (INTERFACE_IS_PAD) {
            url = [NSURL URLWithString:[product objectForKey:@"large_image"]];
        } else {
            url = [NSURL URLWithString:[product objectForKey:@"snapshot"]];
        }
        
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
