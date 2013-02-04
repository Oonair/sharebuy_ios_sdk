#import <UIKit/UIKit.h>

@class SBContact;

@interface SBRoomCallView : UIView

// I know that a Singleton-UIView is a weird design decision, but initializing
// it was very expensive (specially the previewLayer), so in order to only do
// it once for every call, I took this approach

+ (id)sharedCallView;

- (void)startCallWithFrame:(CGRect)frame;

- (void)endCall;

- (UIImageView *) previewLayer;

- (void) addContact:(SBContact *)contact videoEnabled:(BOOL)videoEnabled;

- (void) contact:(SBContact *)contact decodedFrame:(UIImage *)frame;

- (void) removeContact:(SBContact *)contact;

@end
