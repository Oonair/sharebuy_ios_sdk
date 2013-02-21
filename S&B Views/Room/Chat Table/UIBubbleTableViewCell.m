//
//  UIBubbleTableViewCell.m
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


#import "UIBubbleTableViewCell.h"
#import "SDWebImageManager.h"

@interface UIBubbleTableViewCell ()

@property (nonatomic, strong) UIImage *bubbleMine;
@property (nonatomic, strong) UIImage *bubbleSomeOneElse;
@property (nonatomic, strong) id<SDWebImageOperation> task;

@property (nonatomic, strong) UIColor *colorMine;
@property (nonatomic, strong) UIColor *colorOther;


@end

@implementation UIBubbleTableViewCell

@synthesize avatarImage;
@synthesize bubbleSomeOneElse;
@synthesize bubbleMine;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        UINib *aXib = [UINib nibWithNibName:@"UIBubbleTableViewCell" bundle:[NSBundle mainBundle]];
        UIView *aView = [[aXib instantiateWithOwner:self options:nil] lastObject];
        aView.frame = self.frame;
        [self addSubview:aView];
    }

    return self;
}

-(void) setWidth:(NSInteger)aWidth
{
    [self setFrame:CGRectMake(self.frame.origin.x,
                              self.frame.origin.y,
                              aWidth,
                              self.frame.size.height)];
}

-(void) setCustomBubbleFont:(UIFont *)aFont;
{
    self.contentLabel.font = aFont;
    
    CGFloat headerSize = [aFont pointSize] - 2;
    
    self.headerLabel.font = [aFont fontWithSize:headerSize];
}

-(void) setBubbleImageMine:(UIImage *)mine someoneElse:(UIImage *)someoneelse;
{
    self.bubbleSomeOneElse = someoneelse;
    self.bubbleMine = mine;
}

-(void) setCustomBubbleColorMine:(UIColor *)colorMine
                      colorOther:(UIColor *)colorOther;
{
    self.colorMine = colorMine;
    self.colorOther = colorOther;
}

-(void) awakeFromNib
{
    [super awakeFromNib];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
}

- (void) dealloc
{
    [self.task cancel];
}

-(void) prepareForReuse
{
    [self.task cancel];
    self.task = nil;
}

- (void) configureForMessage:(NSString *)aMessage
                  bubbleSize:(CGSize)aBubbleSize
                  dateHeader:(NSString *)aDateHeader
                 avatarImage:(NSURL *)aAvatar
                     forType:(NSBubbleType)aType;
{
    if (aDateHeader)
    {
        self.headerLabel.hidden = NO;
        self.headerLabel.text = aDateHeader;
    }
    else
    {
        self.headerLabel.hidden = YES;
    }
        
    NSBubbleType type = aType;
    
    float x = (type == BubbleTypeSomeoneElse) ? 20 : self.frame.size.width - 20 - aBubbleSize.width;
    float y = 5 + (aDateHeader ? 30 : 0);
    
    if (aAvatar && type == BubbleTypeSomeoneElse) {

        [self setImageFromURL:aAvatar];
        x += avatarImage.frame.size.width + 5;
    } else {
        [avatarImage setImage:nil];
    }

    self.contentLabel.frame = CGRectMake(x, y, aBubbleSize.width, aBubbleSize.height);
    self.contentLabel.text = aMessage;
    
    if (type == BubbleTypeSomeoneElse)
    {
        self.bubbleImage.image = self.bubbleSomeOneElse;
        
        self.bubbleImage.frame = CGRectMake(x - 18, y - 4, aBubbleSize.width + 30, aBubbleSize.height + 15);
        self.contentLabel.textColor = _colorOther;
    }
    else {
        self.bubbleImage.image = self.bubbleMine;

        self.bubbleImage.frame = CGRectMake(x - 9, y - 4, aBubbleSize.width + 26, aBubbleSize.height + 15);
        self.contentLabel.textColor = _colorMine;
    }
}

-(void)setImageFromURL:(NSURL *)url
{
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    __weak UIBubbleTableViewCell *blockSelf = self;
    self.task = [manager downloadWithURL:url
                                 options:SDWebImageLowPriority
                                progress:nil
                               completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished){
                                   if (image)
                                   {
                                       [blockSelf.avatarImage setImage:image];
                                       blockSelf.task = nil;
                                   }
                               }];
}

@end
