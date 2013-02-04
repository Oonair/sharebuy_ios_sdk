//
//  SBRoomViewController_Pad.m
//  eshop
//
//  Created by Pierluigi Cifani on 1/16/13.
//  Copyright (c) 2013 Pierluigi Cifani. All rights reserved.
//

#import "SBRoomViewController_Pad.h"
#import "SBRoomViewController_Private.h"

#import "SBRoomCallView.h"

#define kVideoHeight 100.0f

typedef enum  TRoomViewState {
    ECallIdle = 0,
    ECallOngoing
} TRoomViewState;

@interface SBRoomViewController_Pad () <SBCallObserverProtocol>
{
    BOOL streamingAudio;
    BOOL streamingVideo;
    TRoomViewState viewState;
}

@property (nonatomic, strong) SBCall *call;
@property (nonatomic, strong) SBRoomCallView *callView;

@end

@implementation SBRoomViewController_Pad

- (id)initWithRoom:(SBRoom *)room
            userID:(NSString *)userID;
{
    self = [super initWithNibName:@"SBRoomViewController_Pad" bundle:nil];
    if (self) {
        // Custom initialization
        self.room = room;
        self.userID = userID;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self customizeButtons];
    
    SBCall *currentCall = [self.room currentCall];
    [self setCurrentCall:currentCall setViewStateAnimated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setStartCallButtons:nil];
    [self setDuringCallButtons:nil];
    [self setStartCallButton:nil];
    [self setEndCallButton:nil];
    [self setMuteCallButton:nil];
    [self setToggleCameraButton:nil];
    [self setVideoView:nil];
    [super viewDidUnload];
}

#pragma mark API

- (void) prepareForCall:(SBCall *)call;
{
    [self setCurrentCall:call setViewStateAnimated:YES];
}

#pragma mark IBActions

- (IBAction)onToggleMute:(id)sender
{
    if (streamingAudio) {
        [self.call setAudioEnabled:NO];
    } else {
        [self.call setAudioEnabled:YES];
    }
}
- (IBAction)onToggleCamera:(id)sender
{
    [self.call toggleCameraPosition];
}

- (IBAction)onEndCall:(id)sender
{
    [self setViewState:ECallIdle animated:YES];
    
    [_call hangCall];
}

- (IBAction)onStartCall:(id)sender
{    
    [self.room startCallWithVideoEnabled:YES
                            audioEnabled:YES
                         completionBlock:^(id response, NSError *error){
                             
                             if (error) {
                                 [self presentAlertViewForError:error];
                                 return;
                             }
                             
                             [self setCurrentCall:response setViewStateAnimated:YES];
                         }];
}

#pragma mark SBCallObserverProtocol

- (void) contactHasAnsweredCall:(SBContact *)contact;
{
    NSLog(@"contactHasAnsweredCall %@", contact);
}

- (void) contactHasLeftCall:(SBContact *)contact withReason:(TRejectReason)reason
{
    NSLog(@"contactHasLeftCall %@", contact);
    [_callView removeContact:contact];
}

- (void) contactJoinedCall:(SBContact *)contact
          withAudioEnabled:(BOOL)audio
           andVideoEnabled:(BOOL)video;
{
    NSLog(@"contactJoinedCall %@", contact);
    
    [_callView addContact:contact videoEnabled:video];
}

- (void) callTerminated;
{
    [self setCurrentCall:nil setViewStateAnimated:YES];
}

- (void) callWillTerminateWithError:(NSError *)error
{
    [self presentAlertViewForError:error];
}

- (void) contact:(SBContact *)contact decodedFrame:(UIImage *)frame
{
    [self.callView contact:contact decodedFrame:frame];
}

- (void) userIsStreamingAudio:(BOOL)audio;
{
    streamingAudio = audio;
    
    if (streamingAudio) {
        [_muteCallButton setImage:[UIImage imageNamed:@"ic-call-micro-on@2x"]
                         forState:UIControlStateNormal];
    } else {
        [_muteCallButton setImage:[UIImage imageNamed:@"ic-call-micro-off@2x"]
                         forState:UIControlStateNormal];
    }
}

- (void) userIsStreamingVideo:(BOOL)video;
{
    streamingVideo = video;
}

#pragma mark Internal

- (void)presentAlertViewForError:(NSError *)error
{
    TSBCallError callError = [error code];
    NSString *callErrorMessage = nil;
    
    switch (callError) {
        case ESBErrorCallOngoing:
            callErrorMessage = @"Call already ongoing";
            break;
        case ESBErrorNoParticipants:
            callErrorMessage = @"Can't call on empty room";
            break;
        case ESBErrorMaxParticipants:
            callErrorMessage = @"Can't call on room with more than 3 participants";
            break;

        case ESBErrorCallAuthentication:
            callErrorMessage = @"Can't Authenticate with Video Server";
            break;

        case ESBErrorCallHardwareInitialization:
            callErrorMessage = @"Can't Init Hardware";
            break;

        case ESBErrorCallServerUnreachable:
            callErrorMessage = @"Video Server unreacheable";
            break;
            
        default:
            callErrorMessage = @"Unkown Error";

            break;
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Call Error"
                                                        message:callErrorMessage
                                                       delegate:nil
                                              cancelButtonTitle:@"Dismiss"
                                              otherButtonTitles:nil];
    [alertView show];
}

- (void) setupCallView
{
    if (_callView == nil)
    {
        CGRect videoRect = CGRectMake(0, 0, self.videoView.frame.size.width, kVideoHeight);
        self.callView = [SBRoomCallView sharedCallView];
        [_callView startCallWithFrame:videoRect];
        [_videoView addSubview:self.callView];
        
        [self.call setPreviewLayer:[self.callView previewLayer]];
    }
}

- (void) removeCallView
{
    [self.callView endCall];
    [self.callView removeFromSuperview];
    self.callView = nil;
}

- (void) setCurrentCall:(SBCall *)call setViewStateAnimated:(BOOL)animated
{
    self.call = call;
    [call setObserver:self];
 
    if (self.call)
    {
        switch (call.stage) {
            case ECallStagePreparing:
            case ECallStageConnecting:
                break;
            case ECallStageTalking:
            {
                [self setViewState:ECallOngoing animated:animated];
            }
                break;
            default:
                break;
        }
    }
    else
    {
        [self setViewState:ECallIdle animated:animated];
    }
}

- (void)setViewState:(TRoomViewState)state animated:(BOOL)animated
{
    if (viewState == state) {
        return;
    }
    
    viewState = state;
    
    __block CGRect newVideoRect, newProductRect, newChatRect;
    CGRect videoRect = self.videoView.frame;
    CGRect productRect = self.productView.frame;
    CGRect chatRect = self.chatView.frame;

    CGFloat videoAlpha = 0.0;
    if (viewState == ECallOngoing)
    {
        newVideoRect = CGRectMake(videoRect.origin.x,
                                  videoRect.origin.y,
                                  videoRect.size.width,
                                  kVideoHeight);
        
        newProductRect = CGRectMake(productRect.origin.x,
                                    productRect.origin.y + kVideoHeight,
                                    productRect.size.width,
                                    productRect.size.height);
        
        newChatRect = CGRectMake(chatRect.origin.x,
                                 chatRect.origin.y + kVideoHeight,
                                 chatRect.size.width,
                                 chatRect.size.height - kVideoHeight);
        
        
        [self setupCallView];
        
        videoAlpha = 1.0f;
    } else
    {
        newVideoRect = CGRectMake(videoRect.origin.x,
                                  videoRect.origin.y,
                                  videoRect.size.width,
                                  0);
        
        newProductRect = CGRectMake(productRect.origin.x,
                                    productRect.origin.y - kVideoHeight,
                                    productRect.size.width,
                                    productRect.size.height);
        
        newChatRect = CGRectMake(chatRect.origin.x,
                                 chatRect.origin.y - kVideoHeight,
                                 chatRect.size.width,
                                 chatRect.size.height + kVideoHeight);
        [self removeCallView];
    }
    
    void (^setItems)(void) = ^(void) {
        //Set Frames
        self.videoView.frame = newVideoRect;
        self.chatView.frame = newChatRect;
        self.productView.frame = newProductRect;
        
        //Set Transparencys
        if (videoAlpha) {
            self.videoView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
        } else {
            self.videoView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.0];
        }

        self.startCallButton.hidden = state == ECallOngoing;
        self.duringCallButtons.hidden = state == ECallIdle;

        return;
    };
    
    if (animated) {
        [UIView animateWithDuration:1.0
                              delay:0.1
                            options: UIViewAnimationCurveEaseOut
                         animations:^{setItems();}
                         completion:^(BOOL finished){

                         }];
    } else {
        setItems();
    }
}

- (void) customizeButtons
{
    //Start Video Call button
    [_startCallButton setBackgroundImage:[[UIImage imageNamed:@"bt-start-videocall" ] resizableImageWithCapInsets:UIEdgeInsetsMake(6.0, 5.0, 6.0, 5.0)]
                            forState:UIControlStateNormal];
    [_startCallButton setBackgroundImage:[[UIImage imageNamed:@"bt-start-videocall-disabled" ] resizableImageWithCapInsets:UIEdgeInsetsMake(6.0, 5.0, 6.0, 5.0)]
                            forState:UIControlStateDisabled];
    [_startCallButton setBackgroundImage:[[UIImage imageNamed:@"bt-start-videocall-over"] resizableImageWithCapInsets:UIEdgeInsetsMake(6.0, 5.0, 6.0, 5.0)]
                            forState:UIControlStateHighlighted];

    [_startCallButton setImage:[UIImage imageNamed:@"ic-start-videocall"]
                      forState:UIControlStateNormal];

    [_startCallButton setTitleColor:[UIColor whiteColor]
                           forState:UIControlStateNormal];

    [_startCallButton setTitle:@"Start Call" forState:UIControlStateNormal];
    
    [_startCallButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 5.0)];

    //End Call button
    [_endCallButton setBackgroundImage:[[UIImage imageNamed:@"bt-endcall" ] resizableImageWithCapInsets:UIEdgeInsetsMake(6.0, 5.0, 6.0, 5.0)]
                             forState:UIControlStateNormal];
    [_endCallButton setBackgroundImage:[[UIImage imageNamed:@"bt-endcall" ] resizableImageWithCapInsets:UIEdgeInsetsMake(6.0, 5.0, 6.0, 5.0)]
                             forState:UIControlStateDisabled];
    [_endCallButton setBackgroundImage:[[UIImage imageNamed:@"bt-endcall-over"] resizableImageWithCapInsets:UIEdgeInsetsMake(6.0, 5.0, 6.0, 5.0)]
                             forState:UIControlStateHighlighted];

    [_endCallButton setImage:[UIImage imageNamed:@"ic-endcall"]
                    forState:UIControlStateNormal];

    [_endCallButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [_endCallButton setTitle:@"End Call" forState:UIControlStateNormal];
    [_endCallButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 5.0)];

    [_muteCallButton setImage:[UIImage imageNamed:@"ic-call-micro-on@2x"]
                     forState:UIControlStateNormal];
    [_toggleCameraButton setImage:[UIImage imageNamed:@"ic-call-turncamera@2x"]
                         forState:UIControlStateNormal];
}

@end