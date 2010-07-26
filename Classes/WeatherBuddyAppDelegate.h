//
//  WeatherBuddyAppDelegate.h
//  WeatherBuddy
//
//  Created by Daniel on 24.07.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "DDLocationWrapper.h"
#import "DDImageCache.h"

@interface WeatherBuddyAppDelegate : NSObject <NSApplicationDelegate, DDLocationWrapperDelegate> {

    NSWindow *window;
    NSString *countryCode;
    
    NSURL *googleMaps;
    
    NSString *degreeUnit;   // can be "C" and "F"
    NSNumber *degrees;
    NSDate  *lastUpdate;
    NSTimer *timer;
    
    DDLocationWrapper *locationWrapper;
    
    @private
    NSStatusBar *bar;
    NSStatusItem *item;
    DDImageCache *ic;
	
	IBOutlet NSMenuItem *updateMenu;
	IBOutlet NSMenuItem *locationMenu;
	IBOutlet NSMenu *statusMenu;
}

@property (assign) IBOutlet NSWindow *window;
@property (readwrite, retain) NSString *countryCode;
@property (readwrite, assign) DDLocationWrapper *locationWrapper;
@property (readwrite, assign) NSTimer *timer;
@property (readwrite, retain) NSURL *googleMaps;
@property (assign) IBOutlet NSMenu *statusMenu;
@property (assign) IBOutlet NSMenuItem *updateMenu;
@property (assign) IBOutlet NSMenuItem *locationMenu;

- (void) atLocation:(CLLocation *)location;
- (NSString *)getTag:(NSString *)xml withTag:(NSString *)tag;
- (void)requestFailed:(ASIHTTPRequest *)request;
- (void)requestFinished:(ASIHTTPRequest *)request;
- (void)quit:(id)sender;
- (void)update:(id)sender;
- (void)myLocation:(id)sender;

@end

