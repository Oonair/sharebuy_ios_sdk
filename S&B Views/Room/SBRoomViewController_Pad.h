//
//  SBRoomViewController_Pad.h
//  eshop
//
//  Created by Pierluigi Cifani on 1/16/13.
//  Copyright (c) 2013 Pierluigi Cifani. All rights reserved.
//

#import "SBRoomViewController.h"

@interface SBRoomViewController_Pad : SBRoomViewController

@property (strong, nonatomic) IBOutlet UIView *startCallButtons;
@property (strong, nonatomic) IBOutlet UIView *duringCallButtons;
@property (strong, nonatomic) IBOutlet UIButton *startCallButton;
@property (strong, nonatomic) IBOutlet UIButton *endCallButton;
@property (strong, nonatomic) IBOutlet UIButton *muteCallButton;
@property (strong, nonatomic) IBOutlet UIButton *toggleCameraButton;
@property (strong, nonatomic) IBOutlet UIView *videoView;

@end
