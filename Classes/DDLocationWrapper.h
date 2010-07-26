//
//  DDLocationWrapper.h
//  WeatherBuddy
//
//  Created by Daniel on 25.07.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreLocation/CoreLocation.h>

@protocol DDLocationWrapperDelegate;

@interface DDLocationWrapper : NSObject <CLLocationManagerDelegate> {

    float timeout;
    id<DDLocationWrapperDelegate> delegate;
    CLLocation *location;
    
@private
    
    CLLocationManager *locationManager;
    NSTimer *timer;
    BOOL isUpdatingLocation;

}

- (void)updateLocation;
- (void)stopUpdating;
- (void)targetMethod:(NSTimer *)theTimer;
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error;
- (void)locationManager: (CLLocationManager *)manager didUpdateToLocation: (CLLocation *)newLocation fromLocation:(CLLocation *) oldLocation;

@property (readwrite, assign) CLLocationManager *locationManager;
@property (readwrite, assign) id delegate;
@property (readwrite, assign) NSTimer *timer;
@property (readwrite, assign) BOOL isUpdatingLocation;
@property (readwrite, retain) CLLocation *location;

@end

@protocol DDLocationWrapperDelegate
- (void) atLocation:(CLLocation *)location;
@optional
@end
