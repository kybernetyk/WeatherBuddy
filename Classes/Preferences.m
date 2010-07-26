//
//  Preferences.m
//  WeatherBuddy
//
//  Created by Daniel on 26.07.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "Preferences.h"


@implementation Preferences

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

#pragma mark -
#pragma mark autostart

- (void)enableLoginItemWithLoginItemsReference:(LSSharedFileListRef )theLoginItemsRefs ForPath:(CFURLRef)thePath 
{
    NSLog(@"enable login item!");
    
    // We call LSSharedFileListInsertItemURL to insert the item at the bottom of Login Items list.
    LSSharedFileListItemRef item = LSSharedFileListInsertItemURL(theLoginItemsRefs, kLSSharedFileListItemLast, NULL, NULL, thePath, NULL, NULL);        
    if (item)
        CFRelease(item);
}

- (void)disableLoginItemWithLoginItemsReference:(LSSharedFileListRef )theLoginItemsRefs ForPath:(CFURLRef)thePath 
{
    NSLog(@"disable login item!");
    
    UInt32 seedValue;
    
    // We're going to grab the contents of the shared file list (LSSharedFileListItemRef objects)
    // and pop it in an array so we can iterate through it to find our item.
    NSArray  *loginItemsArray = (NSArray *)LSSharedFileListCopySnapshot(theLoginItemsRefs, &seedValue);
    
    for (id item in loginItemsArray) 
    {        
        LSSharedFileListItemRef itemRef = (LSSharedFileListItemRef)item;
        if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef*) &thePath, NULL) == noErr) 
        {
            if ([[(NSURL *)thePath path] hasPrefix: [[NSBundle mainBundle] bundlePath]])
                LSSharedFileListItemRemove(theLoginItemsRefs, itemRef); // Deleting the item
        }
    }
    
    [loginItemsArray release];
}

- (IBAction)addLoginItem:(id)sender 
{
    //    CFURLRef url = (CFURLRef)[NSURL fileURLWithPath:SGApplicationPath];
    
    // Create a reference to the shared file list.
    LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    if (loginItems) 
    {
        NSURL *bundleURL = [NSURL fileURLWithPath: [[NSBundle mainBundle] bundlePath]];
        
        NSLog(@"my bundle path: %@", bundleURL);
        
        BOOL addToLogin = [[NSUserDefaults standardUserDefaults] boolForKey: @"startAtLogin"];
        
        if (addToLogin)
            [self enableLoginItemWithLoginItemsReference: loginItems ForPath: (CFURLRef)bundleURL];
        else
            [self disableLoginItemWithLoginItemsReference: loginItems ForPath: (CFURLRef)bundleURL];
        
        /*if ([[oOpenAtLogin selectedCell] state] == YES)
         [self enableLoginItemWithLoginItemsReference:loginItems ForPath:url];
         else
         [self disableLoginItemWithLoginItemsReference:loginItems ForPath:url];*/
    }
    
    CFRelease(loginItems);
}

@end
