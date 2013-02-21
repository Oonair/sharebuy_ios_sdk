//
//  SBAddressBookFetcher.h
//  eshop
//
//  Created by Pierluigi Cifani on 1/14/13.
//  Copyright (c) 2013 Oonair. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^SBAddressBookCompletion)(NSArray *);

@interface SBAddressBookFetcher : NSObject

// The returned array will be an array of
// dictionaries with the following keys:
/* {
firstname = Meliza;
lastname = Hidalgo;
imagedata = NSData representation;
mail = "hidalgo_meliza@hotmail.com";
}
*/

+ (void) getContactsFromAddressBook:(SBAddressBookCompletion)completionBlock;

@end
