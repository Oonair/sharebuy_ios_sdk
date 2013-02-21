//
//  SBRoomViewController.m
//  eshop
//
//  Created by Pierluigi Cifani on 12/13/12.
//  Copyright (c) 2013 Oonair. All rights reserved.
//

#import "SBRoomViewController.h"
#import "SBRoomViewController_Private.h"

#import "NSDate+Helper.h"

#import "SBViewProtocols.h"

#import "SBCustomizer.h"

#import "SBFBContact.h"
#import "ShareBuy.h"

@interface SBRoomViewController () 
{
    BOOL mustDismissKeyboard;
    CGRect chatFullRect;
    CGRect chatNormalRect;
}
@end

@implementation SBRoomViewController

- (id)initWithRoom:(SBRoom *)room
            userID:(NSString *)userID;
{
    self = [super initWithNibName:@"SBRoomViewController" bundle:nil];
    if (self) {
        // Custom initialization
        self.room = room;
        self.userID = userID;
        
        [self.room enterRoom];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.    
    [self setChatTable];
    [self setProductPageController];
    
    [self setRightBarButton];
    [self setNavigationItemTitle];

    // Custom initialization
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onSBRoomStatus:)
                                                 name:SBRoomStatusNotification
                                               object:self.room];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onSBRoomContact:)
                                                 name:SBRoomContactNotification
                                               object:self.room];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onSBPanelClose:)
                                                 name:SBViewDidDisappear
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onSBPanelOpen:)
                                                 name:SBViewDidAppear
                                               object:nil];
    
    [self registerForContactStatusNotifications];

    //Set up notifications for keyboard events
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    //Add Tap recognizer to dimiss the keyboard when the table gets tapped
    UITapGestureRecognizer *iReco = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTableTap)];
    
    [self.chatTable addGestureRecognizer:iReco];
    
    //Placeholder
    SBFBContact *user = [[ShareBuy sharedInstance] userFacebookRepresentation];
    [self.chatTextField setPlaceholder:[NSString stringWithFormat:@"%@, chat here...", user.firstName]];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void) viewWillAppear:(BOOL)animated
{
    [self.chatTable scrollChatTableToTheBottom:NO];
    mustDismissKeyboard = YES;
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.room leaveRoom];
    mustDismissKeyboard = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

#pragma mark View Setup

- (void)setProductPageController
{
    //Configure Product Scroll
    self.productPageController = [[SBProductPageViewController alloc] initWithRoom:self.room
                                                                            userID:self.userID];
    [self.productPageController.view setFrame:CGRectMake(0, 0,
                                                         self.productView.frame.size.width,
                                                         self.productView.frame.size.height)];
    [self addChildViewController:self.productPageController];
    [self.productView addSubview:self.productPageController.view];    
}

- (void)setChatTable
{
    //Configure Chat Table
    [self.chatTable setChatTableRoom:self.room
                              userID:self.userID];
}

#pragma mark S&B API

- (void)sendMessage:(NSString *)message {
    
    [self.room sendMessage:message
           completionBlock:^(id response, NSError *error){
               NSLog(@"[sendMessage] response:%@ error:%@", response, error);
               self.chatTextField.text = @"";
               [self.chatTable addMessage:response];
           }];
}

#pragma mark S&B Notifications

- (void)onSBContactStatus:(NSNotification *)notification
{
    [self setNavigationItemTitle];
}

- (void)onSBRoomStatus:(NSNotification *)notification
{    
    [self setRightBarButton];
}

- (void)onSBRoomContact:(NSNotification *)notification
{
    [self setNavigationItemTitle];
    [self registerForContactStatusNotifications];
}

- (void) onSBPanelClose:(NSNotification *)notification
{
    [self.room leaveRoom];
    [_chatTextField resignFirstResponder];
}

- (void) onSBPanelOpen:(NSNotification *)notification
{
    [self.room enterRoom];
}

- (void) registerForContactStatusNotifications
{
    //Register for SBContactUpdates for this room's contacts
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:SBContactUpdateNotification
                                                  object:nil];
    
    for (SBContact *contact in [_room getRoomContacts])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onSBContactStatus:)
                                                     name:SBContactUpdateNotification
                                                   object:contact];
    }
}

- (void) prepareForCall:(SBCall *)call;
{
    //This ViewController doesn't support VideoCalls
}

#pragma mark - IBActions

- (void)onInviteContact
{
    self.navigationItem.backBarButtonItem =  [[SBCustomizer sharedCustomizer] barButtonWithTitle:@"Back" target:nil action:nil];

    SBInviteFBContactViewController *invite = [[SBInviteFBContactViewController alloc] initWithDelegate:self];
    [self.navigationController pushViewController:invite animated:YES];
}

- (IBAction)onSendMessage:(id)sender
{    
    NSString *message = self.chatTextField.text;
    [self sendMessage:message];
}

#pragma mark - UITextFielDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [_room userIsWritingMessage];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField;
{
    BOOL shouldReturn = NO;
    if (self.chatTextField.text.length)
    {
        NSString *message = self.chatTextField.text;
        [self sendMessage:message];
        shouldReturn = YES;
    }
    
    return shouldReturn;
}

#pragma mark - SBInviteProtocol

- (void) invitedFacebookContacts:(NSArray *)contacts;
{
    for (SBFBContact *contact in contacts) {
        [self.room inviteContact:contact completionBlock:nil];
    }
}

- (void) invitedMailContact:(NSArray *)contacts;
{    
    for (NSString *mail in contacts) {
        [self.room inviteContactUsingMail:mail completionBlock:nil];
    }
}

#pragma mark - Keyboard

-(void)keyboardWillShow:(NSNotification *)aNotification
{
    self.keyboardState = EKeyboardShown;
    
    if (INTERFACE_IS_PHONE && mustDismissKeyboard) {
        [self hideProduct:aNotification.userInfo];
    }
}

-(void)keyboardWillHide:(NSNotification *)aNotification
{
    self.keyboardState = EKeyboardHidden;
    
    if (INTERFACE_IS_PHONE && mustDismissKeyboard) {
        [self showProduct:aNotification.userInfo];
    }
}

#pragma mark - Product Hide/Show

-(void)handleTableTap
{
    [self.chatTextField resignFirstResponder];
}

- (CGRect) correctKeyboardFrame:(CGRect)aValue
{
    CGRect keyboardFrame = aValue;
    
    UIWindow *window = [[[UIApplication sharedApplication] windows]objectAtIndex:0];
    CGRect keyboardFrameConverted = [self.view convertRect:keyboardFrame fromView:window];
    return keyboardFrameConverted;
}

- (void)calculateChatViewFramesForKeyboadWithFrame:(CGRect)keyboardFrame
{
    if (CGRectIsEmpty(chatNormalRect))
    {
        chatNormalRect = self.chatView.frame;
    }
    
    if (CGRectIsEmpty(chatFullRect))
    {
        CGRect keyboardFrameRaw = keyboardFrame;
        
        CGRect keyboardFrame =  [self correctKeyboardFrame:keyboardFrameRaw];
        
        CGFloat avaliableHeight = self.view.frame.size.height;
        
        CGFloat coveredSection = keyboardFrame.size.height + self.chatView.frame.size.height - avaliableHeight;
        
        chatFullRect = CGRectMake(0,
                                  0,
                                  self.chatView.frame.size.width,
                                  self.chatView.frame.size.height - coveredSection);
    }
}

- (void)hideProduct:(NSDictionary *)options
{
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    
    [[options objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[options objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    CGRect keyboardFrameRaw = [[options objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];

    [self calculateChatViewFramesForKeyboadWithFrame:keyboardFrameRaw];
        
    CGRect newRect = chatFullRect;
    
    [UIView animateWithDuration:animationDuration
                          delay:0.0
                        options: animationCurve
                     animations:^{
                         self.chatView.frame = newRect;
                         [self.chatTable scrollChatTableToTheBottom:YES];
                     }
                     completion:^(BOOL finished){
                     }];
}

- (void)showProduct:(NSDictionary *)options
{
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    
    [[options objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[options objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
        
    CGRect newRect = chatNormalRect;

    [UIView animateWithDuration:animationDuration
                          delay:0.0
                        options: animationCurve
                     animations:^{
                         self.chatView.frame = newRect;
                         [self.chatTable scrollChatTableToTheBottom:YES];
                     }
                     completion:^(BOOL finished){
                     }];
}

#pragma mark - NavigationItem customization

- (void)setRightBarButton
{
    switch ([self.room getRoomState]) {
        case ERoomStateDeleting:
        case ERoomStateLoading:
        {
            [self setRightBarButtonActivityIndicator];
        }
            break;
        case ERoomStateReady:
        case ERoomStateIdle:
        {
            [self setRightBarButtonInviteContactButton];
        }
            break;

        default:
        {
            self.navigationItem.rightBarButtonItem = nil;
        }
            break;
    }
}

- (void)setRightBarButtonInviteContactButton
{
    SBCustomizer *customizer = [SBCustomizer sharedCustomizer];
    UIImage *buttonImage = [UIImage imageNamed:@"ic-add"];
    self.navigationItem.rightBarButtonItem = [customizer barButtonWithImage:buttonImage
                                                                     target:self
                                                                     action:@selector(onInviteContact)];
}

- (void)setRightBarButtonActivityIndicator
{
    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:activity];
    self.navigationItem.rightBarButtonItem = barButton;
    [activity startAnimating];
}

- (void) setNavigationItemTitle
{
    NSArray *roomContacts = [_room getRoomContacts];
    NSInteger roomParticipants = [roomContacts count];
    
    TRoomState roomState = [_room getRoomState];
    
    if (roomState == ERoomStateIdle)
    {
        // In this state, the contacts have not been invited yet, so there is no reason to
        // use the contactStatus or the lastTimeSeen
        
        // NOTE: objects returned by [SBRoom getRoomContacts] are of type SBContact OR SBFBContact
        self.title = [self.room getRoomContactsStringRepresentation];
    }
    else {
        if (roomParticipants == 1)
        {
            NSInteger viewWidht = 130;
            
            UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewWidht, 40)];
            titleView.clearsContextBeforeDrawing = NO;
            titleView.backgroundColor = [UIColor clearColor];
            
            SBContact *contact = roomContacts[0];
            
            //User name label
            UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, viewWidht, 25)];
            nameLabel.clearsContextBeforeDrawing = NO;
            nameLabel.backgroundColor = [UIColor clearColor];
            nameLabel.textAlignment = NSTextAlignmentCenter;
            nameLabel.textColor = [UIColor whiteColor];
            nameLabel.font = [UIFont boldSystemFontOfSize:18.0f];
            nameLabel.shadowColor = [UIColor darkGrayColor];
            
            nameLabel.text = contact.firstName;
            [titleView addSubview:nameLabel];
            
            // User conection state label
            UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 24, viewWidht - 6, 14)];
            // Italic fonts make geometrical alligment (used by iOS) different from the optic alligment.
            // This 6pts offset makes it look ok
            
            subtitleLabel.clearsContextBeforeDrawing = NO;
            subtitleLabel.backgroundColor = [UIColor clearColor];
            subtitleLabel.textAlignment = NSTextAlignmentCenter;
            subtitleLabel.textColor = [UIColor whiteColor];
            subtitleLabel.font = [UIFont italicSystemFontOfSize:12.0f];
            subtitleLabel.minimumScaleFactor = 0.8;
            subtitleLabel.adjustsFontSizeToFitWidth = YES;
            
            nameLabel.shadowColor = [UIColor darkGrayColor];
            
            subtitleLabel.text = [self subtitleForContact:contact];
            [titleView addSubview:subtitleLabel];
            
            self.navigationItem.titleView = titleView;
            self.title = nil;
        }
        else
        {
            self.navigationItem.titleView = nil;
            NSString *roomTitle = [self.room getRoomContactsStringRepresentation];
            if (roomTitle == nil)
            {
                roomTitle = @"Empty Room";
            }
            
            self.title = roomTitle;
        }
    }
}

- (NSString *) subtitleForContact:(SBContact *)contact
{
    NSString *aStateString;
    TContactStatus contactStatus = contact.contactStatus;
    
    switch (contactStatus)
    {
        case EContactPending: aStateString = @"Pending"; break;
        case EContactOnline:
        {
            if (contact.writingStatus == EWritingComposing)
            {
                // Special case
                aStateString = @"Typing...";
            }
            else
            {
                aStateString = @"Online";
            }
        }
            break;
            
        case EContactOffline:  aStateString = [contact.lastTimeSeen lastTimeConnected];
            break;
        default: aStateString = @"Offline"; break;
    }
    
    return aStateString;

}

@end