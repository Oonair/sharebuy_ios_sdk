//
//  SBRequestProtocol.h
//  SBXmpp
//
//  Created by Pierluigi Cifani on 11/1/13.
//  Copyright (c) 2013 Pierluigi Cifani. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum  {
    ERequestErrorUnknown = 0,
    ERequestErrorCancelled
} TRequestError;

extern NSString *SBRequestErrorDomain;

typedef void (^SBRequestCompletionBlock)(id response, NSError *error);

@protocol SBRequestProtocol <NSObject>

- (BOOL) cancelRequestWithID:(NSString *)ID;

@end