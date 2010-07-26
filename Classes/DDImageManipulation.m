//
//  DDImageManipulation.m
//  WeatherBuddy
//
//  Created by Daniel on 25.07.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "DDImageManipulation.h"


@implementation DDImageManipulation

- (id)init {
    if ((self = [super init])) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc {
    // Clean-up code here.
    
    [super dealloc];
}

int histogram[256];
float relativeHistogram[256];

- (NSBitmapImageRep *)otsu:(NSImage *)source {
    NSBitmapImageRep *image = [self greyscale:source];
    
    float threshold = FLT_MAX;
    float previousThreshold = FLT_MAX;
    float myLower = 0;      // µ lower half
    float myUpper = 0;
    int position = 0;
    int countLower = 0;      // helper for µ
    int countUpper = 0;      // helper for µ
    float varianceLower = 0;
    float varianceUpper = 0;
    
    // ultra inefficient implementation. small files anyway...
    
    while (position < 256) {
        // update µ for lower region
        countLower = 0;
        myLower = 0;
        for (int i = 0; i <= position; i++) {
            myLower += histogram[i]*i;
            countLower += histogram[i];
        }
        myLower /= countLower;

        // update µ for upper region
        countUpper = 0;
        myUpper = 0;
        for (int i = position+1; i < 256; i++) {
            myUpper += histogram[i]*i;
            countUpper += histogram[i];
        }
        myUpper /= countUpper;
        
        // calculate lower variance
        varianceLower = 0;
        for (int i = 0; i <= position; i++) {
            varianceLower += (i - myLower) * (i - myLower) * relativeHistogram[i];
        }
        
        // calculate upper variance
        varianceUpper = 0;
        for (int i = position+1; i < 256; i++) {
            varianceUpper += (i - myUpper) * (i - myUpper) * relativeHistogram[i];
        }
        
        threshold = countLower * varianceLower + countUpper * varianceUpper;

        if (threshold > previousThreshold)
            break;
        
		position++; // now everything BELOW this is below the threshold
			
        previousThreshold = threshold;
    }
    
    float alphaColor = position / (float)255.0;
    NSColor *color;
    
    for (int y = 0; y < [image size].height; y++) {
        for (int x = 0; x < [image size].width; x++) {
            color = [image colorAtX:x y:y];
            CGFloat r; CGFloat g; CGFloat b; CGFloat alpha;
            [color getRed:&r green:&g blue:&b alpha:&alpha];
            if (r < alphaColor)
                [image setColor:[NSColor colorWithDeviceRed:0.0 green:0.0 blue:0.0 alpha:1.0] atX:x y:y];
            else
                [image setColor:[NSColor colorWithDeviceRed:0.0 green:0.0 blue:0.0 alpha:0.0] atX:x y:y];
        }
    }
    
    // todo: move bounding box + cropping to seperate functions - has nothing to do with otsu
    
    // find bounding box to reduce image to the smallest size possible
    int xmin = INT_MAX;
    int xmax = INT_MIN;
    int ymin = INT_MAX;
    int ymax = INT_MIN;
    
    for (int y = 0; y < [image size].height; y++) {
        for (int x = 0; x < [image size].width; x++) {
            color = [image colorAtX:x y:y];
            CGFloat r; CGFloat g; CGFloat b; CGFloat alpha;
            [color getRed:&r green:&g blue:&b alpha:&alpha];
            if (alpha > 0) {
                xmin = MIN(x, xmin);
                xmax = MAX(x+1, xmax);
                ymin = MIN(y, ymin);
                ymax = MAX(y+1, ymax);
            }
        }
    }
    
    // and now crop according to bounding volume
	
    CGImageRef cgImg = CGImageCreateWithImageInRect([image CGImage], NSRectToCGRect(NSMakeRect(xmin, ymin, xmax-xmin, ymax-ymin)));
    NSBitmapImageRep *result = [[NSBitmapImageRep alloc] initWithCGImage:cgImg];
    CGImageRelease(cgImg);
    return [result autorelease];
    
//    return image;
}

- (NSBitmapImageRep *)greyscale:(NSImage *)image {
    NSBitmapImageRep *bitmapImageRep = [[NSBitmapImageRep alloc] initWithData:[image TIFFRepresentation]];
    
    NSColor *color;
    memset(histogram, '\0', sizeof(histogram));
    
    for (int y = 0; y < [bitmapImageRep size].height; y++) {
        for (int x = 0; x < [bitmapImageRep size].width; x++) {
            color = [bitmapImageRep colorAtX:x y:y];
            CGFloat r; CGFloat g; CGFloat b; CGFloat alpha;
            [color getRed:&r green:&g blue:&b alpha:&alpha];
            float rgb = r * 0.299  + g * 0.587 + b * 0.114;
            [bitmapImageRep setColor:[NSColor colorWithDeviceRed:rgb green:rgb blue:rgb alpha:0] atX:x y:y];
            
            histogram[(int)round(rgb*255)]++;
        }
    }

    [self histogram];
    
    [bitmapImageRep release];
    return bitmapImageRep;
}

- (void)histogram {
    memset(relativeHistogram, '\0', sizeof(relativeHistogram));
    
    int total = 0;
    
    for (int i = 0; i < 256; i++)
        total += histogram[i];
    
    for (int i = 0; i < 256; i++)
        relativeHistogram[i] = histogram[i] / (float)total;
}



@end
