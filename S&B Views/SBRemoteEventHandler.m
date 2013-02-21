//
//  SBEventHandler.m
//  eshop
//
//  Created by Pierluigi Cifani on 1/29/13.
//  Copyright (c) 2013 Oonair. All rights reserved.
//

#import "SBRemoteEventHandler.h"
#import "SBRoomViewController.h"

#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>
#import "PSPDFAlertView.h"

#import "SBCustomizer.h"

#import "SBBarButtonItem.h"
#import "SBNavigationController.h"

//Model
#import "SBRoom.h"
#import "SBCall.h"
#import "SBContact.h"
#import "SBProduct.h"
#import "SBEventMessage.h"
#import "SBEventProduct.h"
#import "SBInvitation.h"
#import "ShareBuy.h"


@interface SBRemoteEventHandler () <SBCallObserverProtocol>
{
    BOOL panelOpen;
}

@property (nonatomic, strong) SBCall *call;
@property (nonatomic, strong) SBRoom *callRoom;
@property (nonatomic, strong) UIAlertView *callAlert;

@property (nonatomic, weak) id <SBRoomNavigationProtocol> roomDelegate;
@property (nonatomic, weak) id <SBViewContainerProtocol> containerDelegate;
@property (nonatomic, weak) id <SBViewProviderProtocol> providerDelegate;

@end

@implementation SBRemoteEventHandler

+ (id)sharedHandler
{
    static dispatch_once_t onceToken;
    static SBRemoteEventHandler *sharedMyInstance = nil;
    
    dispatch_once(&onceToken, ^{
        sharedMyInstance = [[self alloc] init];
    });
    return sharedMyInstance;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onSBInvitation:)
                                                     name:SBInvitationNotification
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onSBEvent:)
                                                     name:SBRoomEventNotification
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onSBCall:)
                                                     name:SBRoomCallNotification
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onSBRoomStatus:)
                                                     name:SBRoomStatusNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onSBPanelClose:)
                                                     name:SBViewDidDisappear
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onSBPanelOpen:)
                                                     name:SBViewDidAppear
                                                   object:nil];
    }
    
    return self;
}


- (void) setRoomNavigationDelegate:(id <SBRoomNavigationProtocol>)delegate;
{
    self.roomDelegate = delegate;
}

- (void) setViewProviderDelegate:(id <SBViewProviderProtocol>)delegate;
{
    self.providerDelegate = delegate;
}

- (void) setViewContainerDelegate:(id <SBViewContainerProtocol>)delegate;
{
    self.containerDelegate = delegate;
}

+ (void) vibrate;
{
    AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
}

#pragma mark Notifications

- (void) onSBInvitation:(NSNotification *)noti
{
    SBInvitation *invitation = noti.object;
    NSLog(@"%@", invitation);
    
    TShareBuyState state = [[ShareBuy sharedInstance] getShareBuyState];

    switch (state) {
        case ESBStateWaitingFBLogin:
        {
            [self.containerDelegate showShareBuy];
        }
            break;
        
        case ESBStateOnline:
        {
            NSString *invitationString = [NSString stringWithFormat:@"Do you want to accept the invitation from %@", invitation.fromName];
            
            PSPDFAlertView *alert = [[PSPDFAlertView alloc] initWithTitle:@"Invitation" message:invitationString];
            [alert addButtonWithTitle:@"YES" block:^{
                __block SBRoom *room;
                room = [[ShareBuy sharedInstance] joinRoom:invitation.roomName
                                           invitationToken:invitation.invitationToken
                                           completionBlock:^(id response, NSError *error){
                                               if (error) return;
                                        
                                               [_roomDelegate navigateToRoom:room];
                                           }];
            }];
            
            [alert setCancelButtonWithTitle:@"NO" block:nil];
            
            UIColor *tintColor = [[SBCustomizer sharedCustomizer] tableHeaderColor];
            [alert setTintColor:tintColor];
            [alert show];
        }
            break;
 
        default:
            break;
    }
}

- (void) onSBRoomStatus:(NSNotification *)noti
{
    SBRoom *room = noti.object;
    
    if (([room getRoomState] == ERoomStateReady) && (panelOpen == NO))
    {
        [self updateBarButtonBadgeValue];
    }
}

- (void) onSBEvent:(NSNotification *)noti
{
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive)
    {
        SBRoom *room = noti.object;
        SBEvent *event = [[room getRoomEvents] lastObject];
        [self configureLocalPushForEvent:event inRoom:room];
        [SBRemoteEventHandler vibrate];
    }
    
    SBRoom *eventRoom = noti.object;
    SBRoom *currentRoom = nil;
    BOOL isDisplayingARoom = NO;
    
    SBNavigationController *navigationController = (SBNavigationController *)[_providerDelegate getShareBuyViewController];
    
    UIViewController *topViewController = [navigationController topViewController];
    
    if ([topViewController isKindOfClass:[SBRoomViewController class]]) {
        currentRoom = [(SBRoomViewController *)topViewController room];
        isDisplayingARoom = YES;
    }
    
    if (panelOpen == NO)
    {
        [self updateBarButtonBadgeValue];
        [SBRemoteEventHandler vibrate];
    }
    else if ((currentRoom != eventRoom) && isDisplayingARoom)
    {
        [navigationController placeDefaultBadgeInBackButtonWithValue:[self roomsWithPendingEvents]];
        [SBRemoteEventHandler vibrate];
    }
}

- (void) onSBCall:(NSNotification *)noti
{
    self.call = noti.object;
    self.callRoom = _call.room;
    [self.call setObserver:self];
    
    if ([self isVideoCallSupportedOnCurrentDevice] == NO)
    {
        [self destroyCallWithReason:EReasonFeatureNotSupported];
        return;
    }
    
    NSString *callMessage = [NSString stringWithFormat:@"%@ has started a Videocall", _call.caller.firstName];

    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive)
    {
        [self scheduleLocalPushWithMessage:callMessage autoBadge:NO];
    }
    else
    {
        if ([_containerDelegate isShareBuyAvailable])
        {
            self.callAlert = [[UIAlertView alloc] initWithTitle:@"New Call"
                                                                message:callMessage
                                                               delegate:self
                                                      cancelButtonTitle:@"Reject"
                                                      otherButtonTitles:@"Answer", nil];
            [_callAlert show];
        }
    }
}

- (void) onSBPanelClose:(NSNotification *)notification
{
    panelOpen = NO;
    [self updateBarButtonBadgeValue];
}

- (void) onSBPanelOpen:(NSNotification *)notification
{
    panelOpen = YES;
    [self removeBarButtonBadgeValue];
}

#pragma mark SBCallObserverProtocol

- (void) callDidTerminate;
{
    if (_callAlert) {
        [_callAlert dismissWithClickedButtonIndex:0 animated:YES];
        self.callAlert = nil;
    }
}
- (void) callWillTerminateWithError:(NSError *)error;
{
    if (_callAlert) {
        [_callAlert dismissWithClickedButtonIndex:0 animated:YES];
        self.callAlert = nil;
    }
}

#pragma mark UIAlertView

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    NSLog(@"CallAlert clicked at index %d", buttonIndex);
    
    if (buttonIndex == 0)
    {
        [self destroyCallWithReason:EReasonUserReject];
    }
    else if (buttonIndex == 1)
    {
        [self answerCall];
    }
}

#pragma mark Internal

- (void)configureLocalPushForEvent:(SBEvent *)event inRoom:(SBRoom *)room
{
    NSString *pushMessage = nil;
    
    switch (event.kind) {
        case EEventTextMessage:
        {
            SBEventMessage *messageEvent = (SBEventMessage *) event;
            SBContact *contact = [room getContactForUserID:messageEvent.contactID];
            pushMessage = [NSString stringWithFormat:@"%@ says: %@", contact.firstName, messageEvent.body];
        }
            break;

        case EEventProductShared:
        {
            SBEventProduct *productEvent = (SBEventProduct *) event;
            SBContact *contact = [room getContactForUserID:productEvent.contactID];
            SBProduct *product = [room getProductForID:productEvent.productID];

            pushMessage = [NSString stringWithFormat:@"%@ shared: %@", contact.firstName, product.name];
        }
            break;
        case EEventLikeProduct:
        {
            SBEventProduct *productEvent = (SBEventProduct *) event;
            SBContact *contact = [room getContactForUserID:productEvent.contactID];
            SBProduct *product = [room getProductForID:productEvent.productID];
            
            pushMessage = [NSString stringWithFormat:@"%@ likes: %@", contact.firstName, product.name];
        }
            break;
        default:
            break;
    }
    
    if (pushMessage)
    {
        [self scheduleLocalPushWithMessage:pushMessage autoBadge:YES];
    }
}

- (void) scheduleLocalPushWithMessage:(NSString *)message autoBadge:(BOOL)autoBadge
{
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    localNotif.fireDate = [NSDate date];
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    
    // Notification details
    localNotif.alertBody = message;
    localNotif.alertAction = @"View";
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    
    if (autoBadge)
    {
        localNotif.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
    }
    
    // Schedule the notification
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
}

- (void) answerCall
{
    __weak typeof(self) weakSelf = self;

    [weakSelf.call answerCallWithVideoEnabled:YES
                                 audioEnabled:YES
                              completionBlock:^(id response, NSError *error){
                                 
                                  SBRoom *callRoom = _callRoom;
                                  SBCall *call = _call;

                                  [weakSelf releaseCall];
                                  SBRoomViewController *roomController = [_roomDelegate navigateToRoom:callRoom];
                                  [roomController prepareForCall:call];
                              }];
}

- (void) destroyCallWithReason:(TRejectReason)reason
{
    [self.call rejectCallWithReason:reason];
    [self releaseCall];
}

- (void) releaseCall
{
    [self.call setObserver:nil];
    self.call = nil;
    self.callRoom = nil;
}

- (BOOL) isVideoCallSupportedOnCurrentDevice
{
    return INTERFACE_IS_PAD;
}

#pragma mark Badge Support

- (void) updateBarButtonBadgeValue
{
    NSInteger roomsWithPendingEvents = [self roomsWithPendingEvents];
    SBBarButtonItem *currentButton = (SBBarButtonItem *) [self.providerDelegate getShareBuyButton];
    [currentButton setBadgeValue:roomsWithPendingEvents];
}

- (void) removeBarButtonBadgeValue
{
    SBBarButtonItem *currentButton = (SBBarButtonItem *) [self.providerDelegate getShareBuyButton];
    [currentButton setBadgeValue:0];
}

- (NSInteger)roomsWithPendingEvents
{
    NSInteger pendingRoomsWithEvents = 0;
    NSArray *rooms = [[ShareBuy sharedInstance] getRooms];
    for (SBRoom *room in rooms) {
        if ([room pendingEvents]) {
            ++pendingRoomsWithEvents;
        }
    }
    
    return pendingRoomsWithEvents;
}
@end
