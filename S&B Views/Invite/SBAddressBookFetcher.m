//
//  SBAddressBookFetcher.m
//  eshop
//
//  Created by Pierluigi Cifani on 1/14/13.
//  Copyright (c) 2013 Pierluigi Cifani. All rights reserved.
//

#import "SBAddressBookFetcher.h"
#import <AddressBook/AddressBook.h>

@implementation SBAddressBookFetcher


+ (BOOL)isABAddressBookCreateWithOptionsAvailable
{
    return &ABAddressBookCreateWithOptions != NULL;
}

+ (void) getContactsFromAddressBook:(SBAddressBookCompletion)completionBlock;
{
    ABAddressBookRef addressBook;
    
    if ([self isABAddressBookCreateWithOptionsAvailable])
    {
        CFErrorRef error = nil;
        addressBook = ABAddressBookCreateWithOptions(NULL, &error);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error)
                {
                    // display error message here
                }
                else if (!granted)
                {
                    // display access denied error message here
                }
                else
                {
                    // access granted
                    [self processAddressBook:addressBook
                             completionBlock:completionBlock];
                }
            });
        });
        
    } else {
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        addressBook = ABAddressBookCreate();
#pragma clang diagnostic pop

        [self processAddressBook:addressBook
                 completionBlock:completionBlock];
    }
    
    return;
}

+ (void)processAddressBook:(ABAddressBookRef)addressBook
           completionBlock:(SBAddressBookCompletion)completionBlock
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSArray * array = [self arrayWithContentsOf:addressBook];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(array);
        });
    });
}

+ (NSArray *)arrayWithContentsOf:(ABAddressBookRef)addressBook {
    
    NSMutableArray *array = [NSMutableArray array];
    
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople( addressBook );
    CFIndex nPeople = ABAddressBookGetPersonCount( addressBook );

    for ( int i = 0; i < nPeople; i++ ){
        ABRecordRef ref = CFArrayGetValueAtIndex (allPeople, i );
        NSMutableDictionary *person = [NSMutableDictionary dictionary];
        
        CFTypeRef firstName = ABRecordCopyValue(ref, kABPersonFirstNameProperty);
        if (firstName != nil) {
            [person setObject:[NSString stringWithFormat:@"%@",firstName]
                       forKey:@"firstname"];
            CFRelease(firstName);
        }
        
        CFTypeRef lastName = ABRecordCopyValue(ref, kABPersonLastNameProperty);
        if (lastName != nil) {
            [person setObject:[NSString stringWithFormat:@"%@",lastName]
                       forKey:@"lastname"];
            CFRelease(lastName);
        }
                        
        ABMultiValueRef mailTmp = ABRecordCopyValue(ref, kABPersonEmailProperty);
        int numEmails = ABMultiValueGetCount(mailTmp);
        if (numEmails > 0)
        {
            for ( int i = 0; i < ABMultiValueGetCount(mailTmp); i++ )
            {
                CFTypeRef mail = ABMultiValueCopyValueAtIndex(mailTmp, i);
                if (mail)
                {
                    [person setObject:[NSString stringWithFormat:@"%@",mail]
                               forKey:@"mail"];
                    
                    CFRelease(mail);
                }
            }
        }
        else
        {
            CFRelease(mailTmp);
            continue;
        }
        
        CFRelease(mailTmp);
        
        NSData *contactImageData = (NSData*)CFBridgingRelease(ABPersonCopyImageDataWithFormat(ref, kABPersonImageFormatThumbnail));
        if (contactImageData) {
            [person setObject:contactImageData
                       forKey:@"imagedata"];
        }

        
        [array addObject:person];
    }
    CFRelease(addressBook);
    CFRelease(allPeople);
    
    return array;
}

@end
