//
//  SBEventHandler.m
//  eshop
//
//  Created by Pierluigi Cifani on 1/29/13.
//  Copyright (c) 2013 Pierluigi Cifani. All rights reserved.
//

#import "SBRemoteEventHandler.h"
#import "SBRoomViewController.h"

//Model
#import "SBRoom.h"
#import "SBCall.h"
#import "SBContact.h"
#import "SBProduct.h"
#import "SBEventMessage.h"
#import "SBEventProduct.h"

@interface SBRemoteEventHandler () <SBCallObserverProtocol>

@property (nonatomic, strong) SBCall *call;
@property (nonatomic, strong) SBRoom *callRoom;
@property (nonatomic, strong) UIAlertView *callAlert;

@property (nonatomic, weak) id <SBRoomNavigationProtocol> roomDelegate;
@property (nonatomic, weak) id <SBViewContainerProtocol> containerDelegate;

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
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onSBEvent:)
                                                     name:SBRoomEventNotification
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onSBCall:)
                                                     name:SBRoomCallNotification
                                                   object:nil];

    }
    
    return self;
}

- (void) setRoomNavigationDelegate:(id <SBRoomNavigationProtocol>)delegate;
{
    self.roomDelegate = delegate;
}

- (void) setViewContainerDelegate:(id <SBViewContainerProtocol>)delegate;
{
    self.containerDelegate = delegate;
}

- (void) onSBEvent:(NSNotification *)noti
{
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive)
    {
        SBRoom *room = noti.object;
        SBEvent *event = [[room getRoomEvents] lastObject];
        [self configureLocalPushForEvent:event inRoom:room];
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

#pragma mark SBCallObserverProtocol

- (void) callTerminated;
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
    
    if (autoBadge) {
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

@end
