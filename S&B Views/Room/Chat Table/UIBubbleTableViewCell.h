//
//  UIBubbleTableViewCell.h
//
//  Created by Alex Barinov
//  StexGroup, LLC
//  http://www.stexgroup.com
//
//  Project home page: http://alexbarinov.github.com/UIBubbleTableView/
//
//  This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/
//


#import <UIKit/UIKit.h>

#define kInsetMargin 75

typedef enum _NSBubbleType
{
    BubbleTypeMine = 0,
    BubbleTypeSomeoneElse = 1
} NSBubbleType;


@interface UIBubbleTableViewCell : UITableViewCell
{
}

- (void) configureForMessage:(NSString *)aMessage
                  bubbleSize:(CGSize)aBubbleSize
                  dateHeader:(NSString *)aDateHeader
                 avatarImage:(NSURL *)aAvatar
                     forType:(NSBubbleType)aType;


-(void) setWidth:(NSInteger)aWidth;
-(void) setCustomBubbleFont:(UIFont *)aFont;
-(void) setBubbleImageMine:(UIImage *)mine someoneElse:(UIImage *)someoneelse;

@property (strong, nonatomic) IBOutlet UILabel *headerLabel;
@property (strong, nonatomic) IBOutlet UIImageView *avatarImage;
@property (strong, nonatomic) IBOutlet UILabel *contentLabel;
@property (strong, nonatomic) IBOutlet UIImageView *bubbleImage;

@end
