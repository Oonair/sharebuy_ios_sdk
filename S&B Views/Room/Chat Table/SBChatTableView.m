//
//  SBChatTableView.m
//  eshop
//
//  Created by Pierluigi Cifani on 12/17/12.
//  Copyright (c) 2013 Oonair. All rights reserved.
//

#import "SBChatTableView.h"

//Model
#import "SBContact.h"
#import "SBRoom.h"
#import "SBEvent.h"
#import "SBEventMessage.h"
#import "SBEventProduct.h"
#import "SBEventContactStatus.h"

//Custom cells
#import "UIBubbleTableViewCell.h" //Component available at: https://github.com/piercifani/UIBubbleTableView

//Categories
#import "NSDate+Helper.h"

#import "SBCustomizer.h"

@interface SBChatTableView() <UITableViewDataSource, UITableViewDelegate>


@property (nonatomic, strong) SBRoom *room;
@property (nonatomic, strong) NSArray *messages;
@property (nonatomic, strong) NSString *userID;

@property (nonatomic) NSTimeInterval snapInterval;
@property (nonatomic, strong) UIImage *bubbleMine;
@property (nonatomic, strong) UIImage *bubbleSomeoneElse;
@property (nonatomic, strong) UIFont *bubbleFont;
@property (nonatomic, strong) UIColor *bubbleFontColorMine;
@property (nonatomic, strong) UIColor *bubbleFontColorOther;

@end

@implementation SBChatTableView

- (void)initializator
{
    // UITableView properties
    
    self.backgroundColor = [UIColor whiteColor];
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
    assert(self.style == UITableViewStylePlain);
    
    self.delegate = self;
    self.dataSource = self;
    
    // UIBubbleTableView default properties
    SBCustomizer *customizer = [SBCustomizer sharedCustomizer];
    
    self.bubbleMine = [customizer selfChatBubbleImage];
    self.bubbleSomeoneElse = [customizer otherChatBubbleImage];
    self.bubbleFont = [customizer chatBubbleFont];
    self.bubbleFontColorMine = [customizer selfChatBubbleFontColor];
    self.bubbleFontColorOther = [customizer otherChatBubbleFontColor];

    self.snapInterval = 60*10; //ten minutes
}

- (id)init
{
    self = [super init];
    if (self) [self initializator];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) [self initializator];
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) [self initializator];
    return self;
}

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:UITableViewStylePlain];
    if (self) [self initializator];
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark Public API

-(void) setChatTableRoom:(SBRoom *)theCurrentRoom
                  userID:(NSString *)userID;
{
    self.room = theCurrentRoom;
    self.messages = [self.room getRoomMessages];
    self.userID = userID;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onNewMessage:)
                                                 name:SBRoomMessageNotification
                                               object:self.room];
}

-(void) scrollChatTableToTheBottom:(BOOL) animated;
{
    //Scroll to the bottom
    if ([self numberOfRowsInSection:0] != 0) {
        NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:([self numberOfRowsInSection:0] - 1) inSection:0];
        [self scrollToRowAtIndexPath:scrollIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}

- (void) refreshTable;
{
    self.messages = [self.room getRoomMessages];
    [self reloadData];
    [self scrollChatTableToTheBottom:YES];
}

- (void) addMessage:(SBEventMessage *)message;
{
    self.messages = [self.messages arrayByAddingObject:message];
    [self reloadData];
    [self scrollChatTableToTheBottom:YES];
}

#pragma mark - Notifications

- (void) onNewMessage:(NSNotification *)noti
{
    SBEventMessage *message = [self.room lastMessage];
    [self addMessage:message];
}

#pragma mark - UITableViewDelegate implementation

#pragma mark - UITableViewDataSource implementation

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.messages count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SBEventMessage *msg = [self.messages objectAtIndex:indexPath.row];
    SBEventMessage *previousMsg = nil;
    
    if (indexPath.row > 0) {
        previousMsg = [self.messages objectAtIndex:(indexPath.row - 1)];
    }
    
    CGFloat height = 44.0f;
    
    if (msg.kind == EEventTextMessage)
    {
        NSBubbleType type = ([msg.contactID isEqualToString:self.userID] ?  BubbleTypeMine : BubbleTypeSomeoneElse);
        
        height = [self getHeightForMessage:msg forType:type];
        height += [self getDateHeaderSizeForDate:msg.time
                                 andPreviousDate:(previousMsg.time ?  previousMsg.time : [NSDate dateWithTimeIntervalSince1970:0])];
        return height;
        
    }
    
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    SBEventMessage *msg = [self.messages objectAtIndex:indexPath.row];

    if (msg.kind == EEventTextMessage)
    {
        cell = [self getCellforTextMessageAtIndex:indexPath];
    }
    
    return cell;
}

#pragma mark - Internal

- (CGSize) getBubbleSizeForMessage:(SBEventMessage *)aMessage
                           forType:(NSBubbleType)aType;
{
    CGSize aSize;
    
    aSize = [(aMessage.body ? aMessage.body : @"") sizeWithFont:self.bubbleFont constrainedToSize:CGSizeMake(self.frame.size.width - kInsetMargin, 9999) lineBreakMode:NSLineBreakByWordWrapping];
    
    return aSize;
}


-(CGFloat)getDateHeaderSizeForDate:(NSDate *)messageDate
                   andPreviousDate:(NSDate *)previousMessageDate
{
    CGFloat dateHeaderSize = 0;
    
    if ([messageDate timeIntervalSinceDate:previousMessageDate] > self.snapInterval)
        
    {
        dateHeaderSize = 30;
    }
    
 	return dateHeaderSize;
}

-(NSString *)getDateHeaderTitleForDate:(NSDate *)messageDate
                       andPreviousDate:(NSDate *)previousMessageDate
{
    NSString *output = nil;
    
    if ([self getDateHeaderSizeForDate:messageDate andPreviousDate:previousMessageDate]) {
        output = [NSDate stringForDisplayFromDate:messageDate
                                         prefixed:YES
                                alwaysDisplayTime:YES];
    }
    return output;
}

- (CGFloat) getHeightForMessage:(SBEventMessage *)aMessage
                        forType:(NSBubbleType)aType;
{
    CGFloat cellHeight = 0.0f;
    CGSize aSize = [self getBubbleSizeForMessage:aMessage
                                         forType:aType];
    cellHeight = aSize.height + 5 + 11;
    
    return cellHeight;
}


- (UITableViewCell *)getCellforTextMessageAtIndex:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"bubbleCell";
    
    SBEventMessage *msg = [self.messages objectAtIndex:indexPath.row];
    SBEventMessage *previousMsg = nil;
    
    if (indexPath.row > 0) {
        previousMsg = [self.messages objectAtIndex:(indexPath.row - 1)];
    }

    UIBubbleTableViewCell *cell = [self dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UIBubbleTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                             reuseIdentifier:CellIdentifier];
        
        //Customize at will
        [cell setBubbleImageMine:self.bubbleMine
                     someoneElse:self.bubbleSomeoneElse];
        [cell setWidth:self.frame.size.width];
        [cell setCustomBubbleFont:self.bubbleFont];
        [cell setCustomBubbleColorMine:_bubbleFontColorMine
                            colorOther:_bubbleFontColorOther];

    }

    NSBubbleType type = ([msg.contactID isEqualToString:self.userID] ?  BubbleTypeMine : BubbleTypeSomeoneElse);

    NSURL *avatarURL = nil;
    if (type == BubbleTypeSomeoneElse) {
        SBContact *contact = [self.room getContactForUserID:msg.contactID];
        avatarURL = [contact getThumbnailURL];
    }
    
    [cell configureForMessage:msg.body
                   bubbleSize:[self getBubbleSizeForMessage:msg forType:type]
                   dateHeader:[self getDateHeaderTitleForDate:msg.time
                                              andPreviousDate:(previousMsg.time ?  previousMsg.time : [NSDate dateWithTimeIntervalSince1970:0])]
                  avatarImage:avatarURL
                      forType:type];

    return cell;
}

@end
