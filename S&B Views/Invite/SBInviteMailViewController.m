//
//  SBMailViewController.m
//  eshop
//
//  Created by Pierluigi Cifani on 1/14/13.
//  Copyright (c) 2013 Oonair. All rights reserved.
//

#import "SBInviteMailViewController.h"
#import "SBFBContact.h"
#import "SBInviteAddressBookViewController.h"
#import "SBCustomizer.h"

@interface SBInviteMailViewController ()
@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *userMailLabel;
@property (strong, nonatomic) IBOutlet UITextField *friendMailTextField;
@property (strong, nonatomic) IBOutlet UIButton *addressBookButton;
@property (strong, nonatomic) SBFBContact *user;

@property (nonatomic, strong) NSMutableArray *selectedContacts;
@end

@implementation SBInviteMailViewController

+ (BOOL) isMailValid:(NSString*)mail{
    BOOL stricterFilter = YES; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:mail];
}

- (id)initWithDelegate:(id <SBInviteMailProtocol>)delegate
              userInfo:(SBFBContact *)contact
{
    self = [super initWithNibName:@"SBInviteMailViewController" bundle:nil];
    if (self) {
        // Custom initialization
        self.delegate = delegate;
        self.user = contact;
        self.selectedContacts = [NSMutableArray array];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self configureTextFieldsWithUserInfo];
    [self configureRightBarButton];
    [self configureLeftBarButton];
    [self setRightBarButtonEnabled];
    
    [self.friendMailTextField becomeFirstResponder];
    
    self.title = @"Invite by Mail";
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg-diagonalines"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setUserNameLabel:nil];
    [self setUserMailLabel:nil];
    [self setFriendMailTextField:nil];
    [self setAddressBookButton:nil];
    [super viewDidUnload];
}

#pragma mark Configuration

- (void)configureLeftBarButton
{
    UIBarButtonItem *cancelButton = [[SBCustomizer sharedCustomizer] barButtonWithTitle:@"Cancel"
                                                                            target:self
                                                                            action:@selector(onCancelPressed:)];

    [self.navigationItem setLeftBarButtonItem:cancelButton];
}

- (void)configureRightBarButton
{        
    UIBarButtonItem *barButton = [[SBCustomizer sharedCustomizer] doneBarButtonWithTitle:@"Done" target:self action:@selector(onDonePressed:)];
    [self.navigationItem setRightBarButtonItem:barButton];
}

- (void)configureTextFieldsWithUserInfo
{
    self.userNameLabel.text = [self.user getFullName];
    self.userMailLabel.text = [self.user getMail];
}

- (void)setRightBarButtonEnabled
{
    if ([self.selectedContacts count] == 0) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

#pragma mark IBActions

- (void)onDonePressed:(id)sender
{
    [self.delegate invitedMailContacts:self.selectedContacts];
}

- (void)onCancelPressed:(id)sender
{
    [self.delegate invitedMailContacts:nil];
}

- (IBAction)onAddressBookTapped:(id)sender
{
    SBInviteAddressBookViewController *addressBook = [[SBInviteAddressBookViewController alloc] initWithDelegate:self.delegate];
    [self.navigationController pushViewController:addressBook animated:YES];
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if ([SBInviteMailViewController isMailValid:self.friendMailTextField.text]) {
        [self storeMail:self.friendMailTextField.text];
    } else {
        [self presentErrorForWrongMailFormat];
    }
    
    return NO;
}

-(void)textFieldDidBeginEditing:(UITextField *)sender
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textDidChange)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:self.friendMailTextField];

}

-(void)textFieldDidEndEditing:(UITextField *)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextFieldTextDidChangeNotification
                                                  object:self.friendMailTextField];

}

-(void)textDidChange
{
    NSString *mail = self.friendMailTextField.text;
    if ([SBInviteMailViewController isMailValid:mail])
    {
        [self storeMail:self.friendMailTextField.text];
    }
    else
    {
        [self storeMail:nil];
    }
    
    [self setRightBarButtonEnabled];
}

#pragma mark Private

- (void) presentErrorForWrongMailFormat
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR"
                                                    message:@"Please insert a valid email address"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

-(void)storeMail:(NSString *)mail
{
    [self.selectedContacts removeAllObjects];
    
    if (mail) {
        [self.selectedContacts addObject:mail];
    }
}

@end
