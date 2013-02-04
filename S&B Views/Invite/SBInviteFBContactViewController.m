//
//  SBInviteContactViewController.m
//  eshop
//
//  Created by Pierluigi Cifani on 1/14/13.
//  Copyright (c) 2013 Pierluigi Cifani. All rights reserved.
//

#import "SBInviteFBContactViewController.h"
#import "SBFBContactCell.h"
#import "SBFBContact.h"
#import "SBInviteMailViewController.h"

#import "ShareBuy.h"

#define kAddMailCellHeight 44

typedef enum {
    KNSelectorModeNormal,
    KNSelectorModeSelected
} KNSelectorMode;

@interface SBInviteFBContactViewController () <SBInviteMailProtocol>
{
    BOOL searching;
}
//Logic Objects
@property (nonatomic, strong) NSArray *contacts;
@property (nonatomic, strong) NSMutableArray *selectedContacts;
@property (nonatomic, setter = setMode:) KNSelectorMode mode;

//UI Objects
@property (strong, nonatomic) IBOutlet UIButton *allButton;
@property (strong, nonatomic) IBOutlet UIButton *selectedButton;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIImageView * modeIndicatorImageView;

@end

@implementation SBInviteFBContactViewController

- (id)initWithDelegate:(id <SBInvitationProtocol>)delegate
{
    self = [super initWithNibName:@"SBInviteFBContactViewController" bundle:nil];
    if (self) {
        // Custom initialization
        self.delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.contacts = [[ShareBuy sharedInstance] getFacebookContactsSorted:YES];
    self.selectedContacts = [NSMutableArray array];
    [self configureSelectionButtons];
    [self configureModeIndicator];
    [self configureRightBarButton];
    
    [self setMode:KNSelectorModeNormal];
    
    UINib *contactNib = [UINib nibWithNibName:@"SBFBContactCell" bundle:[NSBundle mainBundle]];
    [self.tableView registerNib:contactNib
         forCellReuseIdentifier:@"SBFBContactCell"];
    
    self.title = @"Invite Friend";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidUnload {
    [self setAllButton:nil];
    [self setSelectedButton:nil];
    [self setTableView:nil];
    [super viewDidUnload];
}

#pragma mark Configuration

- (void) configureSelectionButtons
{
    [self.allButton setBackgroundColor:[UIColor clearColor]];
    [self.selectedButton setBackgroundColor:[UIColor clearColor]];
    
    [self.allButton setTitle:@"All"
                forState:UIControlStateNormal];
    
    [self.selectedButton setTitle:[NSString stringWithFormat:@"Selected (%d)", [self.selectedContacts count]]
                         forState:UIControlStateNormal];
    
    [self.allButton setTitleColor:[UIColor blackColor]
                         forState:UIControlStateNormal];
    
    [self.selectedButton setTitleColor:[UIColor blackColor]
                              forState:UIControlStateNormal];
    
    [self.allButton setTitleColor:[UIColor blackColor]
                         forState:UIControlStateSelected];
    
    [self.selectedButton setTitleColor:[UIColor blackColor]
                              forState:UIControlStateSelected];
    
    [self.allButton setTitleColor:[UIColor darkGrayColor]
                         forState:UIControlStateHighlighted];
    
    [self.selectedButton setTitleColor:[UIColor darkGrayColor]
                              forState:UIControlStateHighlighted];
}

- (void) configureModeIndicator
{
    // Image indicator
    self.modeIndicatorImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"KNSelectorTip"]];
    self.modeIndicatorImageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    self.modeIndicatorImageView.contentMode = UIViewContentModeCenter;
    CGRect frame = self.view.frame;
    [self.view insertSubview:self.modeIndicatorImageView belowSubview:self.allButton];
    self.modeIndicatorImageView.center = CGPointMake(self.allButton.center.x,
                                                     frame.size.height-44 + self.modeIndicatorImageView.frame.size.height/2);
}

- (void) configureRightBarButton
{
    if (self.navigationItem.rightBarButtonItem == nil) {
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:self
                                                                       action:@selector(onDonePressed:)];
        
        [self.navigationItem setRightBarButtonItem:doneButton];
    }
    
    if ([self.selectedContacts count] == NO) {
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
    } else {
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
    }
}

- (void) setMode:(KNSelectorMode)mode
{
    _mode = mode;
    
    __block void(^animationBlock)(void) = ^(void) { };
    
    if (self.mode == KNSelectorModeNormal)
    {
        self.allButton.selected = YES;
        self.selectedButton.selected = NO;
        animationBlock = ^(void) {
            self.modeIndicatorImageView.center = CGPointMake(self.allButton.center.x, self.modeIndicatorImageView.center.y);
        };
    } else if (self.mode == KNSelectorModeSelected)
    {
        self.allButton.selected = NO;
        self.selectedButton.selected = YES;
        
        animationBlock = ^(void) {
            self.modeIndicatorImageView.center = CGPointMake(self.selectedButton.center.x, self.modeIndicatorImageView.center.y);
        };
    }
    
    [self.tableView setContentOffset:CGPointZero];
    [self.tableView reloadData];
    
    [UIView animateWithDuration:0.3 animations:animationBlock];
}

#pragma mark - IBActions

- (void)onDonePressed:(id)sender
{
    [self.delegate invitedFacebookContacts:self.selectedContacts];
    [self popViewControllerAnimated:YES];
}

- (IBAction)onAllPressed:(id)sender {
    [self setMode:KNSelectorModeNormal];
}

- (IBAction)onSelectedPressed:(id)sender {
    [self setMode:KNSelectorModeSelected];
}

- (void)popViewControllerAnimated:(BOOL)animated
{
    [self.navigationController popViewControllerAnimated:animated];
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.mode == KNSelectorModeNormal) {
        return 2;
    } else {
        return 1;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.mode == KNSelectorModeNormal) {
        if (indexPath.section == 0) {
            return kAddMailCellHeight;
        } else {
            return [SBFBContactCell cellHeight];
        }
    } else {
        return [SBFBContactCell cellHeight];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    if (self.mode == KNSelectorModeNormal) {
        // Return the number of rows in the section.
        if (sectionIndex == 0)
        {
            return 1;
        }
        else if (sectionIndex == 1)
        {
            return [self.contacts count];
        }
    }
    else {
        return [self.selectedContacts count];
    }
    
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.mode == KNSelectorModeNormal) {
        if (indexPath.section == 0) {
            return [self getAddMailCell];
        }
        else if (indexPath.section == 1) {
            
            SBFBContact *contact = [self.contacts objectAtIndex:indexPath.row];
            return [self getCellForContact:contact];
        }
    } else {
        
        SBFBContact *contact = [self.selectedContacts objectAtIndex:indexPath.row];
        return [self getCellForContact:contact];
    }
    
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.mode == KNSelectorModeSelected) {
        return;
    }
    
    if (indexPath.section == 0) {
        
        [self createInviteByMailViewController];
        
    } else if (indexPath.section == 1) {
     
        SBFBContact *contact = [self.contacts objectAtIndex:indexPath.row];
        SBFBContactCell *cell = (SBFBContactCell *) [self.tableView cellForRowAtIndexPath:indexPath];
        [self contactSelected:contact forCell:cell];
        
    }
}

#pragma mark SBInviteMailProtocol

- (void) invitedMailContacts:(NSArray *)contacts;
{
    [self.navigationController dismissViewControllerAnimated:YES
                                                  completion:^{
                                                      if (contacts) {
                                                          [self.delegate invitedMailContact:contacts];
                                                          [self popViewControllerAnimated:YES];
                                                      }
                                                  }];
}

#pragma mark Private

- (BOOL) isContactSelected:(SBFBContact *)contact
{
    NSUInteger index = [self.selectedContacts indexOfObject:contact];
    
    if (index == NSNotFound) {
        return NO;
    } else {
        return YES;
    }
}

- (void) contactSelected:(SBFBContact *)contact forCell:(SBFBContactCell *)cell
{
    if ([self isContactSelected:contact]) {
        [self.selectedContacts removeObject:contact];
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        [self.selectedContacts addObject:contact];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    [self configureSelectionButtons];
    [self configureRightBarButton];
}

- (void) createInviteByMailViewController
{
    SBInviteMailViewController *mailInvite = [[SBInviteMailViewController alloc] initWithDelegate:self userInfo:[[ShareBuy sharedInstance] userFacebookRepresentation]];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:mailInvite];
    
    [self.navigationController presentViewController:navController
                                            animated:YES
                                          completion:^{
    
                                              NSLog(@"presentViewController:");
    
                                          }];
    
}

- (UITableViewCell *) getCellForContact:(SBFBContact *)contact
{
    SBFBContactCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"SBFBContactCell"];
    
    [cell configureForContact:contact];
    
    if ([self isContactSelected:contact]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    return cell;
}
- (UITableViewCell *) getAddMailCell
{
    //Create cell    
    static NSString *MailCellIdentifier = @"MailCell";
    UITableViewCell *cell = (UITableViewCell*)[self.tableView dequeueReusableCellWithIdentifier:MailCellIdentifier];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MailCellIdentifier];
    }

    //Create a LayoutView
    UIView *cellContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,
                                                                        self.tableView.frame.size.width, kAddMailCellHeight)];
    
    //And the thumbnail
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 20, 20)];
    imageView.image = [UIImage imageNamed:@"ic-mail"];
    
    //And the label
    UILabel *aLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, 5, self.tableView.frame.size.width, 30)];
    aLabel.text = @"Add by Mail";
    aLabel.textColor = [UIColor darkGrayColor];
    
    [cellContentView addSubview:imageView];
    [cellContentView addSubview:aLabel];
    [cell.contentView addSubview:cellContentView];
    
    return cell;
}


@end
