//
//  SBRoomViewController_Private.h
//  eshop
//
//  Created by Pierluigi Cifani on 1/16/13.
//  Copyright (c) 2013 Pierluigi Cifani. All rights reserved.
//

#import "SBRoomViewController.h"

#import "SBChatTableView.h"
#import "SBProductPageViewController.h"
#import "SBInviteFBContactViewController.h"

//Model
#import "SBRoom.h"
#import "SBCall.h"
#import "SBContact.h"

typedef enum  TKeyboardState{
    EKeyboardHidden = 0,
    EKeyboardShown
} TKeyboardState;

@interface SBRoomViewController () <SBInvitationProtocol>

-(void)keyboardWillShow:(NSNotification *)aNotification;
-(void)keyboardWillHide:(NSNotification *)aNotification;

@property (strong, nonatomic) IBOutlet UIView *productView;
@property (strong, nonatomic) IBOutlet UIView *chatView;
@property (strong, nonatomic) IBOutlet UIView *bottomChatView;
@property (strong, nonatomic) IBOutlet UITextField *chatTextField;

@property (strong, nonatomic) IBOutlet SBChatTableView *chatTable;
@property (strong, nonatomic) SBProductPageViewController *productPageController;

@property (nonatomic) TKeyboardState keyboardState;

@end
