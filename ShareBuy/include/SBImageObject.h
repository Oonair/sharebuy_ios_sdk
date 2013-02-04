//
//  SBImageObject
//  OonairXmpp2
//
//  Created by Pierluigi Cifani on 10/18/12.
//  Copyright (c) 2012 Oonair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

@interface SBImageObject : NSObject

- (id) initWithSize:(CGSize)aSize andURL:(NSURL *)aUrl;

- (id) initWithDictionaryRepresentation:(NSDictionary *)aDictionary;

- (NSDictionary *) dictionaryRepresentation;

@property (nonatomic, strong) NSURL *url;
@property (nonatomic)         CGSize size;

@end
