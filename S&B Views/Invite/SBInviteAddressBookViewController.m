//
//  SBInviteAddressBookViewController.m
//  eshop
//
//  Created by Pierluigi Cifani on 1/14/13.
//  Copyright (c) 2013 Pierluigi Cifani. All rights reserved.
//

#import "SBInviteAddressBookViewController.h"
#import "SBAddressBookFetcher.h"

@interface SBInviteAddressBookViewController ()
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *contacts;
@property (strong, nonatomic) NSMutableArray *selectedContacts;
@end

@implementation SBInviteAddressBookViewController

- (id)initWithDelegate:(id <SBInviteMailProtocol>)delegate;
{
    self = [super initWithNibName:@"SBInviteAddressBookViewController" bundle:nil];
    if (self) {
        // Custom initialization
        self.delegate = delegate;
        self.selectedContacts = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self configureRightBarButton];
    [self getContactsFromAddressBook];
    self.title = @"Invite from AddressBook";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}

#pragma mark Configure

- (void)configureRightBarButton
{
    if (self.navigationItem.rightBarButtonItem == nil) {
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:self
                                                                       action:@selector(onDonePressed:)];
        
        [self.navigationItem setRightBarButtonItem:doneButton];
    }
    
    if ([self.selectedContacts count] == 0) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

- (void) configureCell:(UITableViewCell *)cell
            forContact:(NSDictionary *)contact
{
    NSMutableString* outputString = [NSMutableString string];
    
    if ([contact objectForKey:@"firstname"]) {
        [outputString appendFormat:@"%@", [contact objectForKey:@"firstname"]];
    }
    if ([contact objectForKey:@"lastname"]) {
        [outputString appendFormat:@" %@",[contact objectForKey:@"lastname"]];
    }

    cell.textLabel.text = outputString;

    UIImage *contactImage = [UIImage imageWithData:[contact objectForKey:@"imagedata"]];
    cell.imageView.image = contactImage;
    
    if ([self isContactSelected:contact]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}

#pragma mark AddressBook

- (void)getContactsFromAddressBook
{
    [SBAddressBookFetcher getContactsFromAddressBook:^(NSArray *array){
        self.contacts = array;
        [self.tableView reloadData];
    }];
}

- (BOOL) isContactSelected:(NSDictionary *)contact
{
    NSUInteger index = [self.selectedContacts indexOfObject:contact];
    
    if (index == NSNotFound) {
        return NO;
    } else {
        return YES;
    }
}

#pragma mark IBActions

- (void)onDonePressed:(id)sender
{
    NSMutableArray *outputArray = [NSMutableArray array];
    
    for (NSDictionary *person in self.selectedContacts) {
        [outputArray addObject:[person objectForKey:@"mail"]];
    }
    
    [self.delegate invitedMailContacts:outputArray];
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    
    return [self.contacts count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"contactCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
    NSDictionary *contact = [self.contacts objectAtIndex:indexPath.row];
    [self configureCell:cell forContact:contact];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *contact = [self.contacts objectAtIndex:indexPath.row];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];

    if ([self isContactSelected:contact]) {
        [self.selectedContacts removeObject:contact];
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        [self.selectedContacts addObject:contact];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    [self configureRightBarButton];
}

@end
