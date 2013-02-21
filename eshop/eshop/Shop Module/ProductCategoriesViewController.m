//
//  ProductCategoriesViewController.m
//  eshop
//
//  Created by Pierluigi Cifani on 2/18/13.
//  Copyright (c) 2013 Oonair. All rights reserved.
//

#import "ProductCategoriesViewController.h"
#import "ProductCategoryCell.h"
#import "ProductGridViewController.h"
#import "ProductDetailViewController.h"

#import "ProductFetcher.h"
#import "UIView+CenterInSuperView.h"
#import "SBSessionHandler.h"
#import "IIViewDeckController.h"
#import "SBProduct+NSDictionary.h"
#import "SBViewProtocols.h"
#import "SBProductContainer.h"

#define kCategoryCellID @"categoryCell"

@interface ProductCategoriesViewController () <SBProductNavigationProtocol, NavigateToProductProtocol>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ProductCategoriesViewController

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
    self.title = @"eShop";
    
    self.navigationItem.rightBarButtonItem = [[SBSessionHandler sharedHandler] getShareBuyButton];

    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg-diagonalines"]];

    [[SBProductContainer sharedContainer] setNavigationDelegate:self];

    //Category Cell
    UINib *categoryNib = [UINib nibWithNibName:@"ProductCategoryCell"
                                    bundle:[NSBundle mainBundle]];
    [self.tableView registerNib:categoryNib
         forCellReuseIdentifier:kCategoryCellID];

    dispatch_async(dispatch_get_main_queue(), ^(void){
        self.indicator = [self startActivityIndicator];
        
        [self getCategories];
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) getCategories
{
    self.tableView.hidden = YES;

    [ProductFetcher fetchProductList:^(NSArray *response){
        
        [self.indicator removeFromSuperview];
        if (response == nil) return;
        
        self.categoryArray = response;
        [self.tableView reloadData];
        self.tableView.hidden = NO;
    }];
}

#pragma mark SBProductNavigationProtocol

- (void) onNavigateToProduct:(SBProduct *)product;
{
    [self createProductDetailViewOfProduct:[SBProduct dictionaryFromProduct:product]];
    self.viewDeckController.panningMode = IIViewDeckNoPanning;
}

#pragma mark NavigateToProductProtocol

- (void)userTappedOnDoneButton;
{
    [self.viewDeckController rightViewPopViewController];
    self.viewDeckController.panningMode = IIViewDeckFullViewPanning;
}


#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_categoryArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return [ProductCategoryCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    ProductCategoryCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kCategoryCellID];
    
    NSDictionary *categoryInfo = _categoryArray[indexPath.row];
    
    [cell setCategoryName:[categoryInfo objectForKey:@"name"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    NSDictionary *categoryInfo = _categoryArray[indexPath.row];
    ProductGridViewController *gridController = [[ProductGridViewController alloc] initWithCategory:categoryInfo];
    [self.navigationController pushViewController:gridController animated:YES];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark Internal

- (void) createProductDetailViewOfProduct:(NSDictionary *)product
{
    ProductDetailViewController *aDetailView = [[ProductDetailViewController alloc] initWithProduct:product forIndex:0];
    [aDetailView setNavigateToProductDelegate:self];
    aDetailView.navigationItem.title = [product objectForKey:@"name"];

    if (INTERFACE_IS_PHONE) {
        
        [self.viewDeckController rightViewPushViewControllerOverCenterController:aDetailView];
    } else {
        [self.navigationController pushViewController:aDetailView animated:YES];
    }
}

- (UIActivityIndicatorView *)startActivityIndicator
{
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicator.color = [UIColor darkGrayColor];
    [self.view addSubview:indicator];
    [indicator centerInSuperview];
    [indicator startAnimating];
    return indicator;
}


@end
