//
//  SBProductViewController.m
//  eshop
//
//  Created by Pierluigi Cifani on 1/2/13.
//  Copyright (c) 2013 Pierluigi Cifani. All rights reserved.
//

#import "SBProductViewController.h"

#import "SBProductView.h"

@interface SBProductViewController ()

@property (nonatomic, weak) id <SBProductViewProtocol> delegate;

@property (nonatomic, strong) SBProduct *leftProduct;
@property (nonatomic, strong) SBProduct *rightProduct;

@property (strong, nonatomic) IBOutlet UIView *leftProductViewContainer;
@property (strong, nonatomic) IBOutlet UIView *rightProductViewContainer;

@property (strong, nonatomic) SBProductView *leftProductView;
@property (strong, nonatomic) SBProductView *rightProductView;

@end

@implementation SBProductViewController

- (id)initWithDelegate:(id <SBProductViewProtocol>)delegate
            pageNumber:(NSInteger)pageNumber;
{
    self = [super initWithNibName:@"SBProductViewController" bundle:nil];
    if (self) {
        self.delegate = delegate;
        self.pageNumber = pageNumber;
    }
    return self;
}


- (void) setRightProduct:(SBProduct *)product mode:(TProductViewMode)mode;
{
    if (product == nil) return;
    
    self.rightProduct = product;

    self.rightProductView = [[SBProductView alloc] initWithFrame:CGRectMake(0, 0,
                                                                             self.rightProductViewContainer.frame.size.width,
                                                                             self.rightProductViewContainer.frame.size.height)
                                                       andProduct:self.rightProduct
                                                         delegate:self.delegate
                                                             mode:mode];

    [self.rightProductViewContainer addSubview:self.rightProductView];
}

- (void) setLeftProduct:(SBProduct *)product mode:(TProductViewMode)mode;
{
    if (product == nil) return;
        
    self.leftProduct = product;
    
    self.leftProductView = [[SBProductView alloc] initWithFrame:CGRectMake(0, 0,
                                                                            self.leftProductViewContainer.frame.size.width,
                                                                            self.leftProductViewContainer.frame.size.height)
                                                      andProduct:self.leftProduct
                                                        delegate:self.delegate
                                                            mode:mode];

    [self.leftProductViewContainer addSubview:self.leftProductView];
}

- (void)viewDidUnload {
    [self setLeftProductViewContainer:nil];
    [self setRightProductViewContainer:nil];
    [super viewDidUnload];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
}

@end