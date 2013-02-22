//
//  SBConnectionViewController.h
//  eshop
//
//  Created by Pierluigi Cifani on 12/10/12.
//  Copyright (c) 2013 Oonair. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum  TConnectionViewState{
    EStateConnecting = 0,
    EStateConnectedFromAnotherDevice,
    EStateOffline
} TConnectionViewState;

@interface SBConnectionViewController : UIViewController

- (id)initWithState:(TConnectionViewState)state;

- (void)setCurrentState:(TConnectionViewState)aState;

@property (strong, nonatomic) IBOutlet UIView *connectingView;
@property (strong, nonatomic) IBOutlet UIView *offlineView;

@end
