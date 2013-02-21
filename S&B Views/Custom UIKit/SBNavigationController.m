//
//  SBNavigationController.m
//  eshop
//
//  Created by Pierluigi Cifani on 1/15/13.
//  Copyright (c) 2013 Oonair. All rights reserved.
//

#import "SBNavigationController.h"
#import "SBNavigationBar.h"

#import "SBRemoteEventHandler.h"
#import "SBRoomViewController.h"
#import "SBMainViewController.h"

#import "SBCustomizer.h"

#define kFullSizePopover CGSizeMake(270, 600)

@interface SBNavigationController ()
{
    SBRemoteEventHandler *eventHandler;
}
@end

@implementation SBNavigationController

- (id)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        [self setValue:[[SBNavigationBar alloc] init] forKeyPath:@"navigationBar"];
        eventHandler = [SBRemoteEventHandler sharedHandler];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setValue:[[SBNavigationBar alloc] init] forKeyPath:@"navigationBar"];
        eventHandler = [SBRemoteEventHandler sharedHandler];
    }
    return self;
}

- (void)dealloc
{

}
- (SBRoom *) currentRoom;
{
    SBRoom *room = nil;
    UIViewController *topViewController = [self topViewController];
    if ([topViewController isKindOfClass:[SBRoomViewController class]])
    {
        SBRoomViewController *roomViewController = (SBRoomViewController *) topViewController;
        room = roomViewController.room;
    }
    
    return room;
}

#pragma mark Push/Pop

- (void) pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([viewController isKindOfClass:[SBRoomViewController class]]) {
        [self placeDefaultBadgeInBackButtonWithValue:[eventHandler roomsWithPendingEvents]];
    }

    [viewController setContentSizeForViewInPopover:kFullSizePopover];
    [super pushViewController:viewController animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated; // Returns the popped controller.
{
    return [super popViewControllerAnimated:animated];
}

#pragma mark Present/Dismiss

- (void) presentViewController:(UIViewController *)viewControllerToPresent
                      animated:(BOOL)flag
                    completion:(void (^)(void))completion
{
    if ([viewControllerToPresent isKindOfClass:[UINavigationController class]])
    {
        UINavigationController *nav = (UINavigationController *) viewControllerToPresent;
        [nav.topViewController setContentSizeForViewInPopover:kFullSizePopover];
        
    }
    else
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

#pragma mark internal

-(void) placeDefaultBadgeInBackButtonWithValue:(NSInteger)value
{
    NSString *newTitle = @"Chats";
    if (value > 0) {
        newTitle = [NSString stringWithFormat:@"Chats (%d)", value];
    }
        
    UIViewController *rootViewController = [[self viewControllers] objectAtIndex:0];
    
    UIBarButtonItem *button = [[SBCustomizer sharedCustomizer] barButtonWithTitle:newTitle
                                                                           target:self
                                                                           action:@selector(popViewControllerAnimated:)];
    
    rootViewController.navigationItem.backBarButtonItem = button;
}

@end
