//
//  DDLocationWrapper.m
//  WeatherBuddy
//
//  Created by Daniel on 25.07.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "DDLocationWrapper.h"


@implementation DDLocationWrapper

@synthesize locationManager, delegate, isUpdatingLocation, location, timer;

- (id)init {
    if ((self = [super init])) {
        // Initialization code here.
    }
    
    timeout = 5.0f;     // standard timeout. 5s after not receiving an update the current location is returned
    isUpdatingLocation = NO;

    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    [self updateLocation];
    
    return self;
}

- (void)updateLocation {
    if (isUpdatingLocation)
        return;
    isUpdatingLocation = YES;
    timer = nil;
    [locationManager startUpdatingLocation];

}

- (void)stopUpdating {
	[locationManager stopUpdatingLocation];
    isUpdatingLocation = NO;
    [timer invalidate];
    timer = nil;
}

- (void)targetMethod:(NSTimer *)theTimer {
    [self stopUpdating];
    [delegate atLocation:location];
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
}

- (void)locationManager: (CLLocationManager *)manager didUpdateToLocation: (CLLocation *)newLocation fromLocation:(CLLocation *) oldLocation {
    self.location = newLocation;
    [timer invalidate];
    timer = [[NSTimer scheduledTimerWithTimeInterval:timeout target:self selector:@selector(targetMethod:) userInfo:NULL repeats:NO] retain];

	if (newLocation.horizontalAccuracy < 0 || newLocation.horizontalAccuracy > 1000)
		return;
}


- (void)dealloc {
    // Clean-up code here.
    if (isUpdatingLocation)
        [self stopUpdating];
    
    locationManager.delegate = nil;
    [locationManager release];
    
    [super dealloc];
}

@end
