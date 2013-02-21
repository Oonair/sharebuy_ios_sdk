//
//  ProductPageViewController.m
//  eshop
//
//  Created by Pierluigi Cifani on 2/6/13.
//  Copyright (c) 2013 Oonair. All rights reserved.
//

#import "ProductPageViewController.h"
#import "ProductDetailViewController.h"
#import "SBSessionHandler.h"

@interface ProductPageViewController () <UIPageViewControllerDataSource>
{
    NSInteger startIndex;
}
@property (nonatomic, strong) NSArray *products;

@end

@implementation ProductPageViewController 

- (id)initWithProductArray:(NSArray *)productArray
                startIndex:(NSInteger)index;
{
    self = [super initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                    navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                  options:nil];
    if (self) {
        // Custom initialization
        self.products = productArray;
        startIndex = index;
        self.dataSource = self;
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
	// Do any additional setup after loading the view.
    
    self.navigationItem.rightBarButtonItem = [[SBSessionHandler sharedHandler] getShareBuyButton];

    //Let's kick things off
    NSLog(@"PageController: starting with index %d", startIndex);

    UIViewController *startViewController = [self createViewControllerForPage:startIndex];
    
    [self setViewControllers:@[startViewController]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:NO
                  completion:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerBeforeViewController:(UIViewController *)viewController;
{
    
    ProductDetailViewController *newController;
    ProductDetailViewController *previousController = (ProductDetailViewController *)viewController;
    
    if ([self validIndex:(previousController.index - 1)]) {
        newController = [self createViewControllerForPage:(previousController.index - 1)];
    }
    return newController;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
       viewControllerAfterViewController:(UIViewController *)viewController;
{
    ProductDetailViewController *newController;
    ProductDetailViewController *previousController = (ProductDetailViewController *)viewController;
    
    if ([self validIndex:(previousController.index + 1)]) {
        newController = [self createViewControllerForPage:previousController.index + 1];
    }
    return newController;
}

#pragma mark Internal

- (BOOL)validIndex:(NSInteger)index
{
    if (index >= 0 && index <= ([_products count] - 1))
        return YES;
    else
        return NO;
}

- (ProductDetailViewController *)createViewControllerForPage:(NSInteger)pageIndex
{
    NSDictionary *product = [self.products objectAtIndex:pageIndex];
    ProductDetailViewController *aDetailView = [[ProductDetailViewController alloc] initWithProduct:product forIndex:pageIndex];
    
    NSLog(@"PageController: creating with index %d", pageIndex);

    self.navigationItem.title = [product objectForKey:@"name"];

    return aDetailView;
}

@end
