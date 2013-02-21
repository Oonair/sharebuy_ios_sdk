//
//  ProductCategoriesViewController_Pad.m
//  eshop
//
//  Created by Pierluigi Cifani on 2/18/13.
//  Copyright (c) 2013 Oonair. All rights reserved.
//

#import "ProductCategoriesViewController_Pad.h"
#import "GMGridView.h"
#import <QuartzCore/QuartzCore.h>
#import "ProductFetcher.h"

#import "SBSessionHandler.h"
#import "ProductGridViewController.h"
#import "ProductCategoryView.h"
#import "UIView+CenterInSuperView.h"

#define kCategorySizePad     CGSizeMake(230, 293)

@interface ProductCategoriesViewController_Pad () <GMGridViewDataSource, GMGridViewActionDelegate>
{
    dispatch_queue_t photoDownloadQueue;
}
@property (nonatomic, strong) GMGridView *categoriesGrid;

@end

@implementation ProductCategoriesViewController_Pad

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        photoDownloadQueue = dispatch_queue_create("com.eshop.categoryphoto", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self createProductGrill];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) getCategories
{    
    [ProductFetcher fetchProductList:^(NSArray *response){

        [self.indicator removeFromSuperview];
        if (response == nil) return;

        self.categoryArray = response;
        [self.categoriesGrid reloadData];
    }];
}

-(void)createProductGrill
{
    NSInteger spacing = INTERFACE_IS_PHONE ? 10 : 15;
    
    self.categoriesGrid = [[GMGridView alloc] initWithFrame:self.view.bounds];
    self.categoriesGrid.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.categoriesGrid.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.categoriesGrid];
    
    self.categoriesGrid.style = GMGridViewStyleSwap;
    self.categoriesGrid.itemSpacing = spacing;
    self.categoriesGrid.minEdgeInsets = UIEdgeInsetsMake(spacing, spacing, spacing, spacing);
    self.categoriesGrid.centerGrid = YES;
    self.categoriesGrid.dataSource = self;
    self.categoriesGrid.actionDelegate = self;
}


#pragma mark GMGridViewDataSource

- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView;
{
    return [self.categoryArray count];
}
- (CGSize)sizeForItemsInGMGridView:(GMGridView *)gridView;
{
    return kCategorySizePad;
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
    NSDictionary *category = self.categoryArray[index];
    [self customizeCell:cell forCategory:category];
    return cell;
}

#pragma mark GMGridViewActionDelegate
//////////////////////////////////////////////////////////////

- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position
{
    NSDictionary *categoryInfo = self.categoryArray[position];
    ProductGridViewController *gridController = [[ProductGridViewController alloc] initWithCategory:categoryInfo];
    [self.navigationController pushViewController:gridController animated:YES];
}

- (void) customizeCell:(GMGridViewCell *)cell forCategory:(NSDictionary *)category
{
    ProductCategoryView *categoryView = (ProductCategoryView *) cell.contentView;

    categoryView.categoryNameLabel.text = [category objectForKey:@"name"];
    UIImageView *imageView = categoryView.categoryImageView;
    
    imageView.image = nil;
    imageView.contentMode = UIViewContentModeScaleAspectFit;

    UIActivityIndicatorView *aSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [imageView addSubview:aSpinner];
    [aSpinner centerInSuperview];
    [aSpinner startAnimating];
    
    NSDictionary *sampleProduct;
    
    NSArray *products = [category objectForKey:@"products"];
    if ([products count]) {
        sampleProduct = [category objectForKey:@"products"][0];
    }
    
    dispatch_async(photoDownloadQueue, ^{
        
        NSURL *url = [NSURL URLWithString:[sampleProduct objectForKey:@"large_image_a"]];
        
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

- (GMGridViewCell *) createCustomGridCell
{
    CGSize size = [self sizeForItemsInGMGridView:self.categoriesGrid];
    GMGridViewCell *cell = [[GMGridViewCell alloc] init];
    cell.deleteButtonIcon = nil;
    
    ProductCategoryView *categoryView = [[ProductCategoryView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    categoryView.backgroundColor = [UIColor whiteColor];
    categoryView.layer.cornerRadius = 8.0f;
    categoryView.layer.borderColor = [UIColor colorWithRed:192/255.0
                                                       green:192/255.0
                                                        blue:192/255.0
                                                       alpha:1.0].CGColor;
    
    categoryView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    categoryView.layer.shadowOffset = CGSizeMake(0, 1);
    categoryView.layer.shadowOpacity = 1;
    categoryView.layer.shadowRadius = 3.0;
    [categoryView.layer setShouldRasterize:YES];
    [categoryView.layer setRasterizationScale:[[UIScreen mainScreen] scale]];
    
    cell.contentView = categoryView;
    return cell;
}

@end
