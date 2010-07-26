//
//  DDImageCache.h
//  WeatherBuddy
//
//  Created by Daniel on 25.07.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ASIHTTPRequest.h"



@interface DDImageCache : NSObject {
@private
    NSString *cachePath;
    NSMutableDictionary *requests;
}

- (BOOL)setImageForObject:(id)object withURL:(NSURL *)url;
- (void)requestFinished:(ASIHTTPRequest *)request;
- (void)requestFailed:(ASIHTTPRequest *)request;

@end
