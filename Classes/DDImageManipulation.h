//
//  DDImageManipulation.h
//  WeatherBuddy
//
//  Created by Daniel on 25.07.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DDImageManipulation : NSObject {
@private
    
}

- (NSBitmapImageRep *)greyscale:(NSImage *)image;
- (NSBitmapImageRep *)otsu:(NSImage *)source;
- (void)histogram;

@end
