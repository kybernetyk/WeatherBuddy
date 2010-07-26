//
//  WeatherBuddyAppDelegate.m
//  WeatherBuddy
//
//  Created by Daniel on 24.07.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//


#import "WeatherBuddyAppDelegate.h"
#import "ASIHTTPRequest.h"
#import "PFMoveApplication.h"

@implementation WeatherBuddyAppDelegate

@synthesize window;
@synthesize countryCode, locationWrapper, timer, googleMaps, statusMenu, locationMenu, updateMenu;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
	PFMoveToApplicationsFolderIfNecessary();
    
    // Insert code here to initialize your application
    bar = [NSStatusBar systemStatusBar];
    item = [[bar statusItemWithLength:NSVariableStatusItemLength] retain];
    
    [item setTitle:@"WB"];
    [item setHighlightMode:YES];
		[item setMenu:statusMenu];
    
    NSLocale *locale = [NSLocale currentLocale];
	self.countryCode = [NSString stringWithFormat:@"%@-%@", [locale objectForKey: NSLocaleLanguageCode], [locale objectForKey: NSLocaleCountryCode]];
    
    [[NSUserDefaults standardUserDefaults]
     setObject:@"NO" forKey:@"DeleteBackup"];
    
    ic = [[DDImageCache alloc] init];
    
    locationWrapper = [[DDLocationWrapper alloc] init];
    locationWrapper.delegate = self;
    [locationWrapper updateLocation];
    
    googleMaps = nil;
    
    degreeUnit = @"C";
    [degreeUnit retain];
}

- (void)startUpdate:(NSTimer *)theTimer {
    [locationWrapper updateLocation];
}

- (void)atLocation:(CLLocation *)location {
    // schedule next update
    timer = [[NSTimer scheduledTimerWithTimeInterval:600.0 target:self selector:@selector(startUpdate:) userInfo:nil repeats:NO] retain];

    // work some magic    
    NSString *gpsLocation = [NSString stringWithFormat:@"%f,%f", location.coordinate.latitude, location.coordinate.longitude];

    [googleMaps release];
    googleMaps = [[NSURL URLWithString:[NSString stringWithFormat:@"http://maps.google.com/?q=%@", gpsLocation]] retain];

	NSString *weatherURL = [NSString stringWithFormat:@"http://weather.service.msn.com/find.aspx?outputview=search&src=vista&weasearchstr=%@&weadegreetype=%@&culture=%@", gpsLocation, degreeUnit, countryCode];
	
	ASIHTTPRequest *request = [[ASIHTTPRequest requestWithURL:[NSURL URLWithString:weatherURL]] retain];
	[request setDelegate:self];
	[request startAsynchronous];
}

- (void)dealloc {
    locationWrapper.delegate = nil;
    [locationWrapper release];
    [item release];
    [ic release];
    [super dealloc];
}


- (void)requestFinished:(ASIHTTPRequest *)request {
	NSString *weatherXML = [request responseString];
	
	NSString *error = [self getTag:weatherXML withTag:@"weather errormessage"];
	if (error) {
		if (![error isEqualToString:@""]) {
			countryCode = @"en-US";
			return;
		}
	}
	
    // <?xml version="1.0" ?><weatherdata><weather weatherlocationcode="wc:USCA0273" weatherlocationname="Cupertino, CA" zipcode="95014" weatherfullname="Cupertino, California" searchlocation="37.331689,-122.030731" searchdistance="1.17738187475946" searchscore="0.95" url="http://weather.msn.com/local.aspx?wealocations=wc:USCA0273&amp;q=Cupertino%2c+CA" imagerelativeurl="http://blst.msn.com/as/wea3/i/en-us/" degreetype="C" provider="WDT" isregion="False" region="" alert="" searchresult="Cupertino, CA (closest location for 37.331689,-122.030731)" lat="37.331689" lon="-122.030731"><current temperature="11" skycode="27" skytext="Mostly Cloudy" /></weather></weatherdata>
    
    NSString *location = [self getTag:weatherXML withTag:@"weatherlocationname"];
    
    if (location)
        [locationMenu setTitle:[NSString stringWithFormat:@"Location: %@", location]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	[dateFormatter setDateStyle:NSDateFormatterShortStyle];
	NSString *update = [NSString stringWithFormat:@"Last Update: %@", [dateFormatter stringFromDate:[NSDate date]]];
    [updateMenu setTitle:update];
	[dateFormatter release];

    
    NSString *temperature = [NSString stringWithFormat:@"%@°%@", [self getTag:weatherXML withTag:@"temperature"], degreeUnit];
    NSString *url = [self getTag:weatherXML withTag:@"imagerelativeurl"];
    NSString *skycode = [self getTag:weatherXML withTag:@"skycode"];

    NSURL *image = [NSURL URLWithString:url];
    image = [image URLByAppendingPathComponent:@"law"];
    image = [image URLByAppendingPathComponent:skycode];
    image = [image URLByAppendingPathExtension:@"gif"];
    [image retain];
    
    [ic setImageForObject:item withURL:image];
    
    [item setTitle:temperature];
    
    [request release];
}


- (void)requestFailed:(ASIHTTPRequest *)request {
    [request release];
}

- (NSString *)getTag:(NSString *)xml withTag:(NSString *)tag {
	NSScanner *theScanner;
	NSString *text = nil;
	
	theScanner = [NSScanner scannerWithString:xml];
	
	[theScanner scanUpToString:[NSString stringWithFormat:@"%@=\"", tag] intoString:NULL];
	if ([xml length] > [theScanner scanLocation] + [tag length] + 2)
		[theScanner setScanLocation:[theScanner scanLocation] + [tag length] + 2];
	[theScanner scanUpToString:@"\" " intoString:&text];
	
	return text;
}

- (void)quit:(id)sender {
    [[NSStatusBar systemStatusBar] removeStatusItem:item];
	[NSApp performSelector:@selector(terminate:) withObject:nil afterDelay:0.1];
}

- (void)update:(id)sender {
    [timer invalidate];
    [locationWrapper updateLocation];
}

- (void)myLocation:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:googleMaps];
}

@end

