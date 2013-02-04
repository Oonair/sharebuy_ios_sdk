//
//  SBNavigationController.m
//  eshop
//
//  Created by Pierluigi Cifani on 1/15/13.
//  Copyright (c) 2013 Pierluigi Cifani. All rights reserved.
//

#import "SBNavigationController.h"

#define kFullSizePopover CGSizeMake(270, 600)

@interface SBNavigationController ()

@end

@implementation SBNavigationController

#pragma mark Push/Pop

- (void) pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [viewController setContentSizeForViewInPopover:kFullSizePopover];
    [super pushViewController:viewController animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated; // Returns the popped controller.
{
    return [super popViewControllerAnimated:animated];
}

#pragma mark Present/Dismiss

- (void) presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion
{
    if ([viewControllerToPresent isKindOfClass:[UINavigationController class]])
    {
        UINavigationController *nav = (UINavigationController *) viewControllerToPresent;
        [nav.topViewController setContentSizeForViewInPopover:kFullSizePopover];
        
    } else
    {
        [viewControllerToPresent setContentSizeForViewInPopover:kFullSizePopover];
    }
    
    viewControllerToPresent.modalPresentationStyle = UIModalPresentationCurrentContext;
    
    [super presentViewController:viewControllerToPresent animated:flag completion:completion];
}

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion ;
{
    [super dismissViewControllerAnimated:flag completion:completion];
}

@end
