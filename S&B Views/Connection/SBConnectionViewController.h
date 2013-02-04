//
//  SBConnectionViewController.h
//  eshop
//
//  Created by Pierluigi Cifani on 12/10/12.
//  Copyright (c) 2012 Pierluigi Cifani. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum  TConnectionViewState{
    EStateConnecting = 0,
    EStateOffline,
    EStateConnectToFacebook
} TConnectionViewState;

@interface SBConnectionViewController : UIViewController

- (id)initWithState:(TConnectionViewState)state;

- (void)setCurrentState:(TConnectionViewState)aState;

@property (strong, nonatomic) IBOutlet UIView *connectingView;
@property (strong, nonatomic) IBOutlet UIView *offlineView;
@property (strong, nonatomic) IBOutlet UIView *facebookView;

@end
