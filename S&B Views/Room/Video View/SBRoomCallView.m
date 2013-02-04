#import "SBRoomCallView.h"

#import "SBContact.h"
#import "SBRoomVideoView.h"

#import "UIView+CenterInSuperView.h"
#import "UIImageView+ActivityIndicator.h"
#import "UIView+Effects.h"

#define kPreviewLayer @"previewLayer"
#define kMaxCapacity 3

@interface SBRoomCallView ()
{
    CGFloat videoWidth;
    CGFloat videoHeight;
    BOOL callOngoing;
}
@property (nonatomic, strong) NSMutableDictionary *videoObjects;

@end

@implementation SBRoomCallView

+ (id)sharedCallView
{
    static dispatch_once_t onceToken;
    static SBRoomCallView *sharedMyInstance = nil;
    
    dispatch_once(&onceToken, ^{
        sharedMyInstance = [[self alloc] init];
    });
    return sharedMyInstance;
}

- (void)startCallWithFrame:(CGRect)frame;
{
    if (callOngoing) {
        return;
    }
    
    [self setFrame:frame];
    self.videoObjects = [NSMutableDictionary dictionary];
        
    videoWidth = self.frame.size.width / 3;
    videoHeight = self.frame.size.height;

    [self setPreviewLayer];
    callOngoing = YES;
}

- (void)endCall;
{
    if (callOngoing == NO) {
        return;
    }

    [self removeAllVideoViews];
    self.videoObjects = nil;
    videoHeight = 0;
    videoWidth  = 0;
    callOngoing = NO;
}

- (void) setPreviewLayer
{
    // Set up previewLayer
    SBRoomVideoView *contactLayerView = [SBRoomVideoView videoViewWithFrame:CGRectMake(0, 0,
                                                                                       videoWidth,
                                                                                       videoHeight)];
    [contactLayerView setImageMode:UIViewContentModeScaleAspectFill];

    [self.videoObjects setObject:contactLayerView forKey:kPreviewLayer];
    [self addSubview:contactLayerView];

    [self centerViewsInContainerAnimated:NO];
}

- (UIImageView *) previewLayer;
{
    return [_videoObjects objectForKey:kPreviewLayer];
}

- (void) addContact:(SBContact *)contact videoEnabled:(BOOL)videoEnabled;
{
    SBRoomVideoView *contactLayerView = [SBRoomVideoView videoViewWithFrame:CGRectMake(0, 0,
                                                                                       videoWidth,
                                                                                       videoHeight)];
    [contactLayerView setImageMode:UIViewContentModeScaleAspectFit];
    
    [self.videoObjects setObject:contactLayerView forKey:contact.ID];
    [self addSubview:contactLayerView];

    if (!videoEnabled) {
        [contactLayerView setNoVideoPlaceholder];
    } else {
        [contactLayerView setActivityIndicator];
    }
    
    [self centerViewsInContainerAnimated:YES];
}

- (void) removeAllVideoViews
{
    for (SBRoomVideoView *contactLayerView in [_videoObjects allValues]) {
        [contactLayerView removeFromSuperviewWithFadeOutEffect];
    }
    
    [_videoObjects removeAllObjects];
}

- (void) removeContact:(SBContact *)contact;
{
    SBRoomVideoView *contactLayerView = [_videoObjects objectForKey:contact.ID];
    [contactLayerView removeFromSuperview];
    [_videoObjects removeObjectForKey:contact.ID];
    
    [self centerViewsInContainerAnimated:YES];
}

- (void) contact:(SBContact *)contact decodedFrame:(UIImage *)frame;
{
    SBRoomVideoView *contactLayerView = [_videoObjects objectForKey:contact.ID];
 
    if (contactLayerView == nil) {
//        [self addContact:contact videoEnabled:YES];
        NSLog(@"Received frame for unknown contact");
        return;
    }
    
    [contactLayerView removeActivityIndicator];

    [contactLayerView setDecodedFrame:frame];
}

- (CGFloat) calculateDelta
{
    NSInteger numberOfItems = [_videoObjects count];
    CGFloat offset = 0;
    
    if (numberOfItems == 1) {
        offset = videoWidth;
    } else if (numberOfItems == 2) {
        offset = videoWidth / 3;
    } else if (numberOfItems == 3) {
        offset = 0;
    }
    return offset;
}

- (void)centerViewsInContainerAnimated:(BOOL)animated
{
    NSInteger numberOfItems = [_videoObjects count];
    
    if (numberOfItems > kMaxCapacity) {
        // This Class only supports up to 3 videos
        return;
    }
        
    void(^setItems)(void) = ^(void) {
        
        CGFloat delta = [self calculateDelta];
        CGFloat offset = delta; // This is the starting value
        
        UIImageView *previewLayer = [_videoObjects objectForKey:kPreviewLayer];
        
        for (UIImageView *imageView in [[_videoObjects allValues] reverseObjectEnumerator])
        {
            if (previewLayer == imageView) {
                continue;
            }
            
            [imageView setFrame:CGRectMake(offset, 0, videoWidth, videoHeight)];
            offset += delta + videoWidth;
        }
        
        [previewLayer setFrame:CGRectMake(offset, 0, videoWidth, videoHeight)];
    };
    
    if (animated) {
        [UIView animateWithDuration:1.0
                         animations:setItems];
    } else {
        setItems();
    }
}

@end