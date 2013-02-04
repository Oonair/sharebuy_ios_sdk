//
//  SBImageProtocol.h
//  OonairXmpp2
//
//  Created by Pierluigi Cifani on 20/11/12.
//  Copyright (c) 2012 Oonair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@protocol SBImageProtocol <NSObject>

- (void) addImageURL:(NSURL *)aURL
             forSize:(CGSize)aSize;

- (NSArray *) getImageArray;

- (void) setThumbnailURL:(NSURL *)aURL;

- (NSURL *) getThumbnailURL;

- (NSURL *) getImageURLForSize:(CGSize)aSize;

@optional

- (void) setImageArrayFromDictionaryRepresentation:(NSArray *)array;

- (NSArray *) getImageArrayAsDictionaryRepresentation;

@end
