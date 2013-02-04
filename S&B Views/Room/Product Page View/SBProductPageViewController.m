//
//  SBProductPageViewController.m
//  eshop
//
//  Created by Pierluigi Cifani on 1/2/13.
//  Copyright (c) 2013 Pierluigi Cifani. All rights reserved.
//

#import "SBProductPageViewController.h"

//Model
#import "SBRoom.h"
#import "SBProduct.h"

#import "SBProductView.h"
#import "SBProductViewController.h"
#import "SBEmptyProductViewController.h"

#import "SBCurrentProductContainer.h"

@interface SBProductPageViewController () <UIPageViewControllerDataSource, SBCurrentProductContainerProtocol, SBProductViewProtocol>

@property (nonatomic, strong) SBRoom *room;
@property (nonatomic, strong) NSString *userID;

@property (nonatomic, strong) NSArray *products;
@property (nonatomic, strong) SBProduct *currentProduct;

@property (nonatomic, strong) NSArray *productsScrollDataSource;

@end

@implementation SBProductPageViewController

+ (id) productPageControllerForRoom:(SBRoom *)theCurrentRoom
                             userID:(NSString *)userID;
{
    return [[self alloc] initWithRoom:theCurrentRoom userID:userID];
}

- (id) initWithRoom:(SBRoom *)room userID:(NSString *)userID
{
    self = [super initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                    navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                  options:nil];
    if (self) {
        self.dataSource = self;
        self.room = room;
        self.userID = userID;
        [[SBCurrentProductContainer sharedContainer] setContainerDelegate:self];
        self.view.backgroundColor = [UIColor colorWithRed:246/255.0f green:245/255.0f blue:241/255.0f alpha:1.0];
    }
    return self;
}

- (void) dealloc
{
    [[SBCurrentProductContainer sharedContainer] setContainerDelegate:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}


- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [self setProductDataSource];
    [self createLastPage];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onSBRoomProduct:)
                                                 name:SBRoomProductNotification
                                               object:self.room];

}

- (void)onSBRoomProduct:(NSNotification *)notification
{
    [self setProductDataSource];
    [self createLastPage];
}

#pragma mark Paging

- (void)createLastPage
{
    UIViewController *startViewController = [self createViewControllerForPage:[self lastPageIndexWithCurrentProduct]];
    
    [self setViewControllers:@[startViewController]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:NO
                  completion:nil];
}

- (NSInteger)lastPageIndex
{
    NSInteger numberOfProducts = [self.products count];
    
    if (numberOfProducts == 0)
    {
        return 0;
    }
    else
    {
        NSInteger numberOfPages = numberOfProducts / 2;
        if (numberOfProducts % 2 != 0) numberOfPages++;
        return  numberOfPages - 1; // Enumaration starts at 0.
    }
}

- (NSInteger)lastPageIndexWithCurrentProduct
{
    NSInteger numberOfProducts = [self.productsScrollDataSource count];
    
    if (numberOfProducts == 0)
    {
        //No products and no ghost Product
        return 0;
    }
    else
    {
        NSInteger numberOfPages = numberOfProducts / 2;
        if (numberOfProducts % 2 != 0) numberOfPages++;
        return  numberOfPages - 1; // Enumaration starts at 0.
    }
}

- (NSInteger)numberOfProductsForPage:(NSInteger)page
{
    NSInteger numberOfProducts = 0;
    if ([self getLeftProductForPage:page]) {
        numberOfProducts++;
    }
    if ([self getRightProductForPage:page]) {
        numberOfProducts++;
    }

    return numberOfProducts;
}

- (SBProduct *)getLeftProductForPage:(NSInteger)pageNumber
{
    NSArray *products = self.productsScrollDataSource;
    if (pageNumber >= 0 && [products count] >= (pageNumber * 2) + 1)
    {
        return [products objectAtIndex:pageNumber * 2];
    }
    
    return nil;
}

- (SBProduct *)getRightProductForPage:(NSInteger)pageNumber
{
    NSArray *products = self.productsScrollDataSource;
    if (pageNumber >= 0 && [products count] >= (pageNumber * 2) + 2)
    {
        return [products objectAtIndex:pageNumber * 2 + 1];
    }
    
    return nil;
}


- (void) configureProductViewController:(SBProductViewController *)productViewController
{
    if (![productViewController isKindOfClass:[SBProductViewController class]]) {
        return;
    }
    
    //This is to force the ViewController to load the NIB and hook the IBOutlets
    [productViewController view];

    NSInteger page = productViewController.pageNumber;
    
    SBProduct *rightProduct = [self getRightProductForPage:page];
    TProductViewMode rightMode = rightProduct == self.currentProduct ? EModeGhost : EModeNormal;
    [productViewController setRightProduct:rightProduct
                                      mode:rightMode];
    
    SBProduct *leftProduct = [self getLeftProductForPage:page];
    TProductViewMode leftMode = leftProduct == self.currentProduct ? EModeGhost : EModeNormal;
    [productViewController setLeftProduct:leftProduct
                                     mode:leftMode];

}


- (UIViewController *) createViewControllerForPage:(NSInteger)page
{
    UIViewController *viewController = nil;
        
    if ([self.productsScrollDataSource count] == 0)
    {
        SBEmptyProductViewController *emtpyProductViewController = [[SBEmptyProductViewController alloc] init];
        
        //This is to disable paging and scrolling in this view
        self.view.userInteractionEnabled = NO;

        viewController = emtpyProductViewController;
    }
    else
    {
        SBProductViewController *productViewController = [[SBProductViewController alloc] initWithDelegate:self
                                                                                                 pageNumber:page];
        
        //This is to enable back paging and scrolling in this view
        self.view.userInteractionEnabled = YES;

        [self configureProductViewController:productViewController];
        
        viewController = productViewController;
    }


    return viewController;
}

-(void) processResponse:(SBProduct *)response forProductView:(SBProductView *)productView;
{
    if ([self.productsScrollDataSource indexOfObject:response] != NSNotFound)
    {
        // This product already existed,
        // now only need to reset the model in order to show it in the right order
        [self setProductDataSource];
        [self createLastPage];
    }
    else
    {
        // This product was shared from the "currentProduct",
        // put the view in a normal state and update its product 
        self.currentProduct = nil;
        [productView updateProduct:response];
        [productView setViewMode:EModeNormal];
    }
}

#pragma mark - Model

- (void)setProductDataSource
{
    //Set Model
    self.currentProduct = [[SBCurrentProductContainer sharedContainer] getCurrentProduct];
    self.products = [self.room getRoomProducts];
    [self createProductArray];
}

- (void) createProductArray
{
    self.productsScrollDataSource = self.products;
    
    if (self.currentProduct && ![self currentProductIsVisibleInLastPage]) {
        self.productsScrollDataSource = [self.productsScrollDataSource arrayByAddingObject:self.currentProduct];
    }
}

- (BOOL) currentProductIsVisibleInLastPage
{
    SBProduct *ghostProduct = self.currentProduct;
    NSInteger lastPageNumber = [self lastPageIndex];
    
    SBProduct *lastRightProduct = [self getRightProductForPage:lastPageNumber];
    SBProduct *lastLeftProduct = [self getLeftProductForPage:lastPageNumber];
    
    if ([lastLeftProduct.ID isEqualToString:ghostProduct.ID] ||
        [lastRightProduct.ID isEqualToString:ghostProduct.ID])
        return YES;
    else
        return NO;
}


#pragma mark - SBProductViewProtocol

-(void) onProductSelected:(SBProductView *)productView;
{
    SBProduct *product = [productView getProduct];
    TProductViewMode viewMode = [productView viewMode];
    switch (viewMode) {
        
        case EModeGhost:
        case EModeOverlay:
        {
            [productView setViewMode:EModeLoading];
            
            __block typeof(self) blockSelf = self;
            
            [self.room shareProduct:product
                    completionBlock:^(id response, NSError *error){
             
                        if (error) {
                            [productView setViewMode:viewMode];
                            return;
                        }
                    
                        [blockSelf processResponse:(SBProduct *)response
                                    forProductView:productView];
                        
                    }];
        }
            break;
            
        case EModeNormal:
            
            break;

        case EModeLoading:
            
            break;

        default:
            break;
    }
}

-(void) onProductDeleted:(SBProductView *)productView;
{
    
}
-(void) onProductLiked:(SBProductView *)productView;
{
    SBProduct *product = [productView getProduct];
    
    SBRequestCompletionBlock block = ^(id response, NSError *error) {
        if (error) {
            NSLog(@"[ERROR] %@:%d", error.domain, error.code);
        } else {
            [productView updateProduct:response];
        }
        
//        [productView setViewMode:EModeNormal];
    };
    
    if (product.like) {
        [self.room stopLikeProduct:product completionBlock:block];
    } else {
        [self.room likeProduct:product completionBlock:block];
    }
}


#pragma mark - SBCurrentProductContainerProtocol

- (void) onNewCurrentProduct:(SBProduct *)product;
{
    [self setProductDataSource];

    [self createLastPage];
}

#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController;
{
    SBProductViewController *productViewController = (SBProductViewController *)viewController;
    NSInteger newPageNumber = productViewController.pageNumber - 1;
    
    if (newPageNumber >= 0 && newPageNumber <= [self lastPageIndexWithCurrentProduct]) {
        return [self createViewControllerForPage:newPageNumber];
    }
    
    return nil;
}
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController;
{
    SBProductViewController *productViewController = (SBProductViewController *)viewController;
    NSInteger newPageNumber = productViewController.pageNumber + 1;
    
    if (newPageNumber >= 0 && newPageNumber <= [self lastPageIndexWithCurrentProduct]) {
        return [self createViewControllerForPage:newPageNumber];
    }
    return nil;
}

@end