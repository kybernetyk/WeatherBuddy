//
//  DDImageCache.m
//  WeatherBuddy
//
//  Created by Daniel on 25.07.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "DDImageCache.h"
#import "DDImageManipulation.h"


@implementation DDImageCache

- (id)init {
    if ((self = [super init])) {
        // Initialization code here.
    }
    
    // get system cache path
    cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    cachePath = [cachePath stringByAppendingPathComponent:[[NSBundle mainBundle] bundleIdentifier]];
    [cachePath retain];
    
    // create cache folder if it doesn't exist yet
    BOOL isDir;
    if (![[NSFileManager defaultManager] fileExistsAtPath:cachePath isDirectory:&isDir])
        [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:nil];

    // initialize the dictionary that keeps track of our current image download requests
    requests = [[NSMutableDictionary alloc] init];
    
    return self;
}

- (void)dealloc {
    // Clean-up code here.
    [cachePath release];
    [requests release];
    [super dealloc];
}


// returns YES if image was already cached
- (BOOL)setImageForObject:(id)object withURL:(NSURL *)url {
    NSString *filepath = [cachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%u.png", [[url description] hash]]];

    BOOL isDir;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filepath isDirectory:&isDir]) {
        if (!isDir && [object respondsToSelector:@selector(setImage:)]) {
            [object setImage:[[[NSImage alloc] initWithContentsOfFile:filepath] autorelease]];
        }
        return YES;
    }
    
    // the image wasn't yet cached. fetch it, manipulate it, save it, call setImage again afterwards
    ASIHTTPRequest *request = [[ASIHTTPRequest requestWithURL:url] retain];

    @synchronized (requests) {
        [requests setValue:object forKey:[url description]];
    }

    [request setDelegate:self];
    [request startAsynchronous];
    
    return NO;
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSString *filepath = [cachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%u.png", [[[request url] description] hash]]];
    
    NSImage *originalImage = [[NSImage alloc] initWithData:[request responseData]];
    DDImageManipulation *im = [[DDImageManipulation alloc] init];
    
    // binarization with otsu
    NSBitmapImageRep *bitmapImageRep = [im otsu:originalImage];
    
    // resize image to x * 21
    int height = [bitmapImageRep pixelsHigh];
    int width = [bitmapImageRep pixelsWide];
    float scale = 17.0 / height;
    width = (int)round(width*scale);
    [bitmapImageRep setSize:NSMakeSize(width, 17)];
    
    // save binarized image representation
    NSData *data;
    data = [bitmapImageRep representationUsingType: NSPNGFileType properties: nil];
    [data writeToFile:filepath atomically:NO];
    
    // create nsimage from binarized representation
    NSImage *newImage = [[NSImage alloc] initWithSize:[bitmapImageRep size]];
    [newImage addRepresentation:bitmapImageRep];
    
    // set image for object
    id object = [requests valueForKey:[[request url] description]];
    if (object) {
        if ([object respondsToSelector:@selector(setImage:)]) {
            [object setImage:newImage];
        }
    }
    
    // the request handling is finished - remove it to conserve memory
    @synchronized (requests) {
        [requests removeObjectForKey:[[request url] description]];
    }
    
    [im release];
    [originalImage release];
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    if (error)
        NSLog(@"%@", error);
}

@end
