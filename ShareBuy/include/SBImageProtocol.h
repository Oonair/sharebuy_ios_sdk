//
//  SBImageProtocol.h
//  OonairXmpp2
//
//  Created by Pierluigi Cifani on 20/11/12.
//  Copyright (c) 2012 Oonair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

/**
 @protocol SBImageProtocol
 
 @brief This protocol is designed to simplify the managment of multiple URLs for different image resolutions. 
  
 **/

@protocol SBImageProtocol <NSObject>

// This method adds a URL for a given size
// Note: aSize is represented in pixels
- (void) addImageURL:(NSURL *)aURL
             forSize:(CGSize)aSize;

// This method returns a NSArray populated with a NSDictionary representation of each URL-Size pair 
- (NSArray *) getImageArray;

// This method sets a URL to be used as a Thumbnail
- (void) setThumbnailURL:(NSURL *)aURL;

// This method return the URL of Thumbnail
- (NSURL *) getThumbnailURL;

// This method returns an appropiate URL for a given size
// Note: this takes into account the pixel density of the current display
- (NSURL *) getImageURLForSize:(CGSize)aSize;

@optional

- (void) setImageArrayFromDictionaryRepresentation:(NSArray *)array;

- (NSArray *) getImageArrayAsDictionaryRepresentation;

@end
