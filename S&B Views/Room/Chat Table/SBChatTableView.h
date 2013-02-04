//
//  SBChatTableView.h
//  eshop
//
//  Created by Pierluigi Cifani on 12/17/12.
//  Copyright (c) 2012 Pierluigi Cifani. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SBRoom;
@class SBEventMessage;

@interface SBChatTableView : UITableView

- (void) refreshTable;

- (void) setChatTableRoom:(SBRoom *)theCurrentRoom
                  userID:(NSString *)userID;

- (void) scrollChatTableToTheBottom:(BOOL) animated;

- (void) addMessage:(SBEventMessage *)message;

@end
