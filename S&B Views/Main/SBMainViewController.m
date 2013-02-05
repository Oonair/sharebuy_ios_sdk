//
//  SBMainViewController.m
//  eshop
//
//  Created by Pierluigi Cifani on 12/10/12.
//  Copyright (c) 2012 Pierluigi Cifani. All rights reserved.
//

#import "SBMainViewController.h"

#import "SBRoomViewController.h"
#import "SBRoomViewController_Pad.h"

//From S&B
#import "ShareBuy.h"
#import "SBRoom.h"
#import "SBFBContact.h"

//Cells
#import "SBRoomCell.h"
#import "SBFBContactCell.h"

#define kRoomSection                0
#define kFacebookContactsSection    1

@interface SBMainViewController () <UITableViewDataSource, UITableViewDelegate>
{
    ShareBuy *shareBuy;
}
@property (nonatomic, strong) NSArray *rooms;
@property (nonatomic, strong) NSArray *facebookContacts;

@end

@implementation SBMainViewController

- (id)init
{
    self = [super initWithNibName:@"SBMainViewController" bundle:nil];
    if (self) {
        
        self.title = @"Chats";
        
        [self setContentSizeForViewInPopover:CGSizeMake(270, 600)]; // size of view in popover

        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onSBInvitation:)
                                                     name:SBInvitation
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

        shareBuy = [ShareBuy sharedInstance];
        
        [self refreshTableDataSource];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UINib *roomNib = [UINib nibWithNibName:@"SBRoomCell" bundle:[NSBundle mainBundle]];
    [self.mainTableView registerNib:roomNib
             forCellReuseIdentifier:@"SBRoomCell"];

    UINib *contactNib = [UINib nibWithNibName:@"SBFBContactCell" bundle:[NSBundle mainBundle]];
    [self.mainTableView registerNib:contactNib
             forCellReuseIdentifier:@"SBFBContactCell"];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)viewWillAppear:(BOOL)animated
{
    [self refreshTableDataSource];
    [self.mainTableView reloadData];
}


#pragma mark S&B Notifications

- (void)onSBInvitation:(NSNotification *)notification
{
//    SBRoom *newRoom = (SBRoom *)notification.object;
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
//    SBRoom *updatedRoom = (SBRoom *)notification.object;
    
    self.rooms = [shareBuy getRooms];
    [self.mainTableView reloadData];
}

- (void)onFBFriendsUpdate:(NSNotification *)notification
{
    [self refreshTableDataSource];
    [self.mainTableView reloadData];
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == kRoomSection) {
        return @"Chats";
    } else if (section == kFacebookContactsSection)
    {
        return @"Contacts";
    } else {
        return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == kRoomSection)
    {
        return [self.rooms count];
    }
    else if (section == kFacebookContactsSection)
    {
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
        SBRoom *room = [self.rooms objectAtIndex:indexPath.row];
        cell = [self getCellForRoom:room];
    }
    else if (indexPath.section == kFacebookContactsSection)
    {
        SBFBContact *contact = [self.facebookContacts objectAtIndex:indexPath.row];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    [self.mainTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == kRoomSection)
    {
        SBRoom *room = [self.rooms objectAtIndex:indexPath.row];
        
        if ([room isRoomReady]) {
            [self openRoom:room];
        }
    }
    else if (indexPath.section == kFacebookContactsSection)
    {
        SBFBContactCell *cell = (SBFBContactCell *) [self.mainTableView cellForRowAtIndexPath:indexPath];

        [cell setLoadingMode];
        
        __weak SBMainViewController *blockSelf = self;
        SBFBContact *contact = [self.facebookContacts objectAtIndex:indexPath.row];

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

#pragma mark - SB Support

- (void) openRoom:(SBRoom *)aRoom
{
    SBRoomViewController *roomController;
    
    if (([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)) {
        roomController = [[SBRoomViewController_Pad alloc] initWithRoom:aRoom
                                                              userID:[shareBuy userID]];
    } else {
        roomController = [[SBRoomViewController alloc] initWithRoom:aRoom
                                                              userID:[shareBuy userID]];
    }
    
    [self.navigationController pushViewController:roomController animated:YES];
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

@end
