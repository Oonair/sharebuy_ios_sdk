//
//  SBRequestProtocol.h
//  SBXmpp
//
//  Created by Pierluigi Cifani on 11/1/13.
//  Copyright (c) 2013 Oonair. All rights reserved.
//

#import <Foundation/Foundation.h>

// This represents the error code for the NSError object passed in the SBRequestCompletionBlock
typedef enum  TSBRequestErrorCode{
    
    // An unknown error ocurred processing the request 
    ERequestErrorUnknown = 0,
    
    // This request was cancelled
    ERequestErrorCancelled
    
} TSBRequestErrorCode;

// The error domain for the NSError object passed in the SBRequestCompletionBlock
extern NSString *SBRequestErrorDomain;

/**
 @block SBRequestCompletionBlock
 
 @brief This block is the preferred way to handle responses to requests done to S&B objects. They will be executed when a response for the request is received. 
 
 @param 'response' An id object with the response to the actual request invoked
 @param 'error' A NSError with a SBRequestErrorDomain, and an error code represented by TRequestError

 **/

typedef void (^SBRequestCompletionBlock)(id response, NSError *error);

/**
 @protocol SBRequestProtocol
 
 @brief This protocol is designed to enable the object performing a request
 to cancel it in case it is not interested on the results of this request.
  
 **/

@protocol SBRequestProtocol <NSObject>

/**
 * Attempts to cancel a request
 *
 * @param 'ID' A NSString representing requestID to cancel
 * @return A BOOL representing if the request was cancelled before 
 * being sent to the server.
 *
 * If this method returns NO, the execution block will be executed with 
 * the corresponding NSError noting that the request was cancelled 
 * and a nil response
 *
 * If this method returns YES, the execution block will be executed when 
 * a response from the server is received, but with a corresponding NSError
 * noting that the request was cancelled
 */

- (BOOL) cancelRequestWithID:(NSString *)ID;

@end