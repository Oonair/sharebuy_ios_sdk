//
//  SBMainViewController.m
//  eshop
//
//  Created by Pierluigi Cifani on 12/10/12.
//  Copyright (c) 2013 Oonair. All rights reserved.
//

#import "SBMainViewController.h"

#import "SBRoomViewController.h"
#import "SBRoomViewController_Pad.h"

#import "SBInviteMailViewController.h"

#import "SBSessionHandler.h"
#import "SBCustomizer.h"
#import "SBViewProtocols.h"
#import "SBProductContainer.h"

//From S&B
#import "ShareBuy.h"
#import "SBRoom.h"
#import "SBFBContact.h"

//Cells
#import "SBRoomCell.h"
#import "SBFBContactCell.h"

#import "UIView+Effects.h"
#import "SBHelper.h"
#import "SBProductHelper.h"
#import "PSPDFAlertView.h"

#define kRoomSection                0
#define kFacebookContactsSection    1

//Helper
#define kUserHasShared @"userHasShared"
static BOOL userHasTappedOnNormalHelper;
static BOOL userHasTappedOnProductHelper;

@interface SBMainViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, SBInviteMailProtocol, SBHelperProtocol>
{
    ShareBuy *shareBuy;
    BOOL searchBarHidden;
    BOOL searching;
}
@property (nonatomic, strong) NSArray *rooms;
@property (nonatomic, strong) NSArray *facebookContacts;

@property (nonatomic, strong) NSArray *matchedSearchRooms;
@property (nonatomic, strong) NSArray *matchedSearchFacebookContacts;

@property (nonatomic, retain) UIView *helper;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UITableView *mainTableView;

@end

@implementation SBMainViewController

- (id)init
{
    self = [super initWithNibName:@"SBMainViewController" bundle:nil];
    if (self) {
        
        self.title = @"Chats";

        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onSBRoomInvitation:)
                                                     name:SBRoomInvitationNotification
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onSBRoomStatus:)
                                                     name:SBRoomStatusNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onSBRoomEvent:)
                                                     name:SBRoomEventNotification
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onSBRoomContact:)
                                                     name:SBRoomContactNotification
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onFBFriendsUpdate:)
                                                     name:SBFBFriendsUpdateNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onSBPanelClose:)
                                                     name:SBViewDidDisappear
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onSBPanelOpen:)
                                                     name:SBViewDidAppear
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onCurrentProduct:)
                                                     name:SBCurrentProduct
                                                   object:nil];

        shareBuy = [ShareBuy sharedInstance];
        
        [self refreshTableDataSource];
    }
    return self;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void) dealloc
{
    if (self.presentedViewController) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UINib *roomNib = [UINib nibWithNibName:@"SBRoomCell"
                                    bundle:[NSBundle mainBundle]];
    [self.mainTableView registerNib:roomNib
             forCellReuseIdentifier:@"SBRoomCell"];

    UINib *contactNib = [UINib nibWithNibName:@"SBFBContactCell"
                                       bundle:[NSBundle mainBundle]];
    [self.mainTableView registerNib:contactNib
             forCellReuseIdentifier:@"SBFBContactCell"];
    
    SBCustomizer *customizer = [SBCustomizer sharedCustomizer];
    
    _searchBar.tintColor = [customizer tableHeaderColor];
    _searchBar.placeholder = @"Friends or chats...";
    
    self.navigationItem.rightBarButtonItem = [customizer barButtonWithImage:[UIImage imageNamed:@"bt-mail"] target:self action:@selector(onStartByMail)];
    
    self.navigationItem.leftBarButtonItem = [customizer barButtonWithImage:[UIImage imageNamed:@"bt-logout"] target:self action:@selector(onLogout)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [self hideSearchBar];
    [self addHelper];
    [self.mainTableView reloadData];
}

#pragma mark S&B Notifications

- (void) onSBPanelClose:(NSNotification *)notification
{
    [_searchBar resignFirstResponder];
}

- (void) onSBPanelOpen:(NSNotification *)notification
{

}

- (void)onSBRoomInvitation:(NSNotification *)notification
{
    //SBRoom *newRoom = (SBRoom *)notification.object;
    
    self.rooms = [shareBuy getRooms];
    [self.mainTableView reloadData];
}

- (void)onSBRoomEvent:(NSNotification *)notification
{
    //SBRoom *updatedRoom = (SBRoom *)notification.object;

    self.rooms = [shareBuy getRooms];
    [self.mainTableView reloadData];
}

- (void)onSBRoomStatus:(NSNotification *)notification
{
    //SBRoom *updatedRoom = (SBRoom *)notification.object;
    
    self.rooms = [shareBuy getRooms];
    [self.mainTableView reloadData];
}

- (void)onSBRoomContact:(NSNotification *)notification
{
    //SBRoom *updatedRoom = (SBRoom *)notification.object;
    
    self.rooms = [shareBuy getRooms];
    [self.mainTableView reloadData];
}

- (void)onFBFriendsUpdate:(NSNotification *)notification
{
    [self refreshTableDataSource];
    [self.mainTableView reloadData];
}

- (void) onLogout
{
    PSPDFAlertView *alert = [[PSPDFAlertView alloc] initWithTitle:@"Logout" message:@"Are you sure you want to logout from Ask a Friend?"];
    [alert addButtonWithTitle:@"YES" block:^{
        
        [shareBuy logoutFacebook];
    }];
    
    [alert setCancelButtonWithTitle:@"NO" block:nil];
    
    UIColor *tintColor = [[SBCustomizer sharedCustomizer] tableHeaderColor];
    [alert setTintColor:tintColor];
    [alert show];
}

- (void) onStartByMail
{
    SBInviteMailViewController *mailInvite = [[SBInviteMailViewController alloc] initWithDelegate:self userInfo:[[ShareBuy sharedInstance] userFacebookRepresentation]];
    
    UINavigationController *navController = [[SBCustomizer sharedCustomizer] navigationControllerWithRootViewController:mailInvite];
    
    [self.navigationController presentViewController:navController
                                            animated:YES
                                          completion:^{
                        
                                              NSLog(@"presentedVC %@", self.presentedViewController);
                                          }];

}

- (void)onCurrentProduct:(NSNotification *)notification
{
    [self removeHelper];
    
    if ([self isVisible]) {
        [self addHelper];
    }
}

#pragma mark SBInviteMailProtocol

- (void) invitedMailContacts:(NSArray *)contacts;
{
    void(^inviteLogic)(void) = ^(void) {
        if (contacts == nil) return;
        
        NSString *mail = contacts[0];
        
        __weak typeof(self) weakSelf = self;
        __block SBRoom *newRoom;
        newRoom = [shareBuy createRoomInviteUserWithMail:mail
                                         completionBlock:^(id response, NSError *error){
                                             
                                             [weakSelf openRoom:newRoom];
                                             
                                             for (int i = 1; i < [contacts count] - 1; i++)
                                             {
                                                 [newRoom inviteContactUsingMail:contacts[i]
                                                                 completionBlock:nil];
                                             }
                                         }];
    };

    [self dismissViewControllerAnimated:YES
                             completion:nil];

    //This block really belongs in the completionBlock of the dismissViewController:
    //However, for some weird reason it is not being executed when viewControllerToPresent.modalPresentationStyle = UIModalPresentationCurrentContext;
    //Discussion here: http://stackoverflow.com/questions/14343480/uinavigationcontroller-not-executing-completionblocks-when-presenting-viewcontro
    inviteLogic();
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *sectionName = [self tableView:tableView titleForHeaderInSection:section];
    
    UIView *headerView = [[SBCustomizer sharedCustomizer] tableHeaderWithName:sectionName
                                                                   tableWidth:tableView.bounds.size.width];
    return headerView;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == kRoomSection)
    {
        return @"Chats";
    }
    else if (section == kFacebookContactsSection)
    {
        return @"Contacts";
    }
    else
    {
        return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == kRoomSection)
    {
        if (searching)
            return [self.matchedSearchRooms count];
        else
            return [self.rooms count];
    }
    else if (section == kFacebookContactsSection)
    {
        if (searching)
            return [self.matchedSearchFacebookContacts count];
        else
            return [self.facebookContacts count];
    }
    else
    {
        return 0;
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Detemine if it's in editing mode
    if (indexPath.section == kRoomSection) {
        return UITableViewCellEditingStyleDelete;
    }
    else return UITableViewCellEditingStyleNone;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (indexPath.section == kRoomSection)
    {
        return [SBRoomCell cellHeight];
    }
    else if (indexPath.section == kFacebookContactsSection)
    {
        return [SBFBContactCell cellHeight];
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    UITableViewCell *cell = nil;
    
    if (indexPath.section == kRoomSection)
    {
        SBRoom *room;
        
        if (searching)
            room = [self.matchedSearchRooms objectAtIndex:indexPath.row];
        else
            room = [self.rooms objectAtIndex:indexPath.row];

        cell = [self getCellForRoom:room];
    }
    else if (indexPath.section == kFacebookContactsSection)
    {
        SBFBContact *contact;
        
        if (searching)
            contact = [self.matchedSearchFacebookContacts objectAtIndex:indexPath.row];
        else
            contact = [self.facebookContacts objectAtIndex:indexPath.row];

        cell = [self getFacebookCellForContact:contact];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        if (indexPath.section == kRoomSection) {
            int position = indexPath.row;
            if (position<0 || position >= [self.rooms count]) return;
            
            SBRoom *room = [self.rooms objectAtIndex:position];
            SBRoomCell *cell = (SBRoomCell *)[self.mainTableView cellForRowAtIndexPath:indexPath];
            [self leaveRoom:room cell:cell];
        }
    }
}


#pragma mark - UITableViewDelegate

- (NSIndexPath *)tableView:(UITableView *)tableView
  willSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if ([_searchBar isFirstResponder]) {
        [_searchBar resignFirstResponder];
    }
    
    return indexPath;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    [self.mainTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == kRoomSection)
    {
        SBRoom *room;
        
        if (searching)
            room = [self.matchedSearchRooms objectAtIndex:indexPath.row];
        else
            room = [self.rooms objectAtIndex:indexPath.row];
        
        if ([room isRoomReady]) {
            [self openRoom:room];
        }
    }
    else if (indexPath.section == kFacebookContactsSection)
    {
        SBFBContactCell *cell = (SBFBContactCell *) [self.mainTableView cellForRowAtIndexPath:indexPath];

        [cell setLoadingMode];
        
        SBFBContact *contact;
        
        if (searching)
            contact = [self.matchedSearchFacebookContacts objectAtIndex:indexPath.row];
        else
            contact = [self.facebookContacts objectAtIndex:indexPath.row];

        __weak SBMainViewController *blockSelf = self;

        [shareBuy getRoomWithUser:contact
                  completionBlock:^(id response, NSError *error){
                      
                      NSArray *roomsWithUser = response;
                      
                      SBRoom *room;
                      
                      if ([roomsWithUser count] > 1) {
                          // Do some fancy math to chose which one to open
                      }
                      
                      room = [roomsWithUser objectAtIndex:0];
                      
                      [blockSelf openRoom:room];
                      
                      [cell setNormalMode];
                  }];
    }    
}


#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)activeSearchBar
{
    [_searchBar resignFirstResponder];
    return YES;
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)theSearchBar
{
    [_searchBar resignFirstResponder];
}

- (void) searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar
{
    [self showSearchBar];
    if (INTERFACE_IS_PHONE) [_searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar;
{
    [_searchBar setText:nil];
    [_searchBar resignFirstResponder];
    [_searchBar setShowsCancelButton:NO animated:YES];
    
    searching = NO;
    [self.mainTableView reloadData];
}

- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText
{
    if ([searchText length]) {
        self.matchedSearchFacebookContacts = [self searchContacts:searchText];
        self.matchedSearchRooms = [self searchRooms:searchText];
        
        searching = YES;
    } else {
        searching = NO;
    }
    
    [self.mainTableView reloadData];
}

- (NSArray *) searchRooms:(NSString *)userInput
{
    NSString *searchText = userInput;

    NSMutableArray *roomsArray = [NSMutableArray array];

    for (SBRoom *room in _rooms)
    {
        NSString *auxRoom = [room getRoomContactsStringRepresentation];
        NSRange titleResultsRange = [auxRoom rangeOfString:searchText options:NSCaseInsensitiveSearch];
        
        if (titleResultsRange.length > 0)
            [roomsArray addObject:room];
    }
    
    return roomsArray;
}

- (NSArray *) searchContacts:(NSString *)userInput
{
    NSString *searchText = userInput;
    
    NSMutableArray *contactsArray = [NSMutableArray array];

    for (SBFBContact *contact in _facebookContacts)
    {
        NSString *auxContact = [contact getFullName];
        NSRange titleResultsRange = [auxContact rangeOfString:searchText options:NSCaseInsensitiveSearch];
        
        if (titleResultsRange.length > 0)
            [contactsArray addObject:contact];
    }
    
    return contactsArray;
}

#pragma mark - SB Support

- (void) openRoom:(SBRoom *)aRoom
{
    [[SBSessionHandler sharedHandler] navigateToRoom:aRoom];
}

- (void) leaveRoom:(SBRoom *)aRoom cell:(SBRoomCell *)cell
{
    __weak SBMainViewController *blockSelf = self;
    
    [cell setLoadingState];
    
    [aRoom exitRoomPermanently:^(id response, NSError *error){
        
        if (error) {
            NSLog(@"Error exiting room");
            [cell configureForRoom:aRoom];
            return;
        }
        
        [blockSelf refreshTableDataSource];
        [blockSelf.mainTableView reloadSections:[NSIndexSet indexSetWithIndex:0]
                               withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
}


#pragma mark - Internal

-(void)refreshTableDataSource
{
    self.rooms = [shareBuy getRooms];
    self.facebookContacts = [shareBuy getFacebookContactsSorted:YES];
}

- (UITableViewCell *)getCellForRoom:(SBRoom *)aRoom;
{
    SBRoomCell *cell = [self.mainTableView dequeueReusableCellWithIdentifier:@"SBRoomCell"];

    [cell configureForRoom:aRoom];
    
    return cell;
}

- (UITableViewCell *)getFacebookCellForContact:(SBFBContact *)aContact;
{
    SBFBContactCell *cell = [self.mainTableView dequeueReusableCellWithIdentifier:@"SBFBContactCell"];
    
    [cell configureForContact:aContact];

    return cell;
}

- (void) updateCellForRoom:(SBRoom *)room
{
    NSUInteger index = [self.rooms indexOfObject:room];
    
    SBRoomCell *cell = (SBRoomCell *) [self.mainTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:kRoomSection]];
    
    [cell configureForRoom:room];
}

-(void) reorderRoomCells
{
    NSArray *copyRooms = [self.rooms copy];
    self.rooms = [shareBuy getRooms];
    
    for (SBRoom *room in self.rooms) {
        
        NSInteger indexBeforeUpdate = [copyRooms indexOfObject:room];
        NSInteger indexAfterUpdate = [self.rooms indexOfObject:room];
        
        [self.mainTableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:indexBeforeUpdate
                                                                  inSection:0]
                                   toIndexPath:[NSIndexPath indexPathForRow:indexAfterUpdate
                                                                  inSection:0]];
        
    }
    
}

- (void)showSearchBar
{
    CGPoint tableOffset = CGPointMake(0, 0);
    [self.mainTableView setContentOffset:tableOffset animated:YES];
}

- (void)hideSearchBar
{
    if (searchBarHidden == NO) {
        CGPoint tableOffset = CGPointMake(0, _searchBar.bounds.size.height);
        [self.mainTableView setContentOffset:tableOffset animated:NO];
        searchBarHidden = YES;
    }
}

#pragma mark Helper

- (void) onHelperTapped;
{
    userHasTappedOnNormalHelper = YES;
    [self removeHelper];
}
- (void) onHelperWithProductTapped;
{
    userHasTappedOnProductHelper = YES;
    [self removeHelper];
}

- (void)addHelper
{
    if ([self.navigationController topViewController] != self) {
        return;
    }
    
    if ([[SBProductContainer sharedContainer] getCurrentProduct]) {
        [self addHelperProduct];
    } else {
        [self addHelperNormal];
    }
}

- (void)addHelperProduct
{
    if (self.helper)
        return;
    
    
    BOOL userHasShared = [[NSUserDefaults standardUserDefaults] boolForKey:kUserHasShared];
    if (userHasShared == NO && userHasTappedOnProductHelper == NO)
    {
        CGRect fullRect = CGRectMake(0, 0, self.navigationController.view.frame.size.width, self.navigationController.view.frame.size.height);
        SBProductHelper *helper = [[SBProductHelper alloc] initWithFrame:fullRect];
        [helper setHelperDelegate:self];
        SBProduct *product = [[SBProductContainer sharedContainer] getCurrentProduct];
        [helper configureForProduct:product];
        [self.navigationController.view addSubviewWithFadeInEffect:helper];
        self.helper = helper;
    }
}
- (void)addHelperNormal
{
    if (self.helper)
        return;
    
    BOOL userHasShared = [[NSUserDefaults standardUserDefaults] boolForKey:kUserHasShared];
    if (userHasShared == NO && userHasTappedOnNormalHelper == NO)
    {
        CGRect fullRect = CGRectMake(0, 0, self.navigationController.view.frame.size.width, self.navigationController.view.frame.size.height);
        SBHelper *helper = [[SBHelper alloc] initWithFrame:fullRect];
        [helper setHelperDelegate:self];
        [self.navigationController.view addSubviewWithFadeInEffect:helper];
        self.helper = helper;
    }
}

- (void)removeHelper
{
    [self.helper removeFromSuperviewWithFadeOutEffect];
    self.helper = nil;
}

- (BOOL)isVisible
{
    return self.view.window != NULL;
}

@end
