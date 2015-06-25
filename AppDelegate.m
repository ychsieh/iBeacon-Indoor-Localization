//
//  AppDelegate.m
//  BeaconCrowdsourcing
//
//  Created by Yachen on 07/04/2015.
//  Copyright (c) 2015 Yachen. All rights reserved.
//

#import "AppDelegate.h"
#import "Parse/Parse.h"

#include <math.h>
#include "MobileWiFi.h"
//#import "MobileWiFi/MobileWiFi.h"
#include "SpringBoardServices.h"
#import "SpringBoard/SBWiFiManager.h"

HOOK(SpringBoard, applicationDidFinishLaunching$, void, id app) {
    //Listen for events via DARWIN NOTIFICATION CENTER
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL,
                                    &NotificationReceivedCallback, CFSTR("com.yourcompany.yourapp.yournotification"), NULL,
                                    CFNotificationSuspensionBehaviorCoalesce);
};


@import CoreLocation;

@interface AppDelegate () <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
        
    // Override point for customization after application launch.
    // [Optional] Power your app with Local Datastore. For more info, go to
    // https://parse.com/docs/ios_guide#localdatastore/iOS
    
    notify_post("com.yourcompany.yourapp.yournotification");
    
   
    
    WiFiManagerRef manager = WiFiManagerClientCreate(kCFAllocatorDefault, 0);
    
    CFArrayRef networks = WiFiManagerClientCopyNetworks(manager);
    
    NSLog(@"networks: %@", networks);
    

//    WiFiManagerRef manager = WiFiManagerClientCreate(kCFAllocatorDefault, 0);
//    CFArrayRef devices = WiFiManagerClientCopyDevices(manager);
//    
//    WiFiDeviceClientRef client = (WiFiDeviceClientRef)CFArrayGetValueAtIndex(devices, 0);
//    CFDictionaryRef data = (CFDictionaryRef)WiFiDeviceClientCopyProperty(client, CFSTR("RSSI"));
//    CFNumberRef scaled = (CFNumberRef)WiFiDeviceClientCopyProperty(client, kWiFiScaledRSSIKey);
//    
//    CFNumberRef RSSI = (CFNumberRef)CFDictionaryGetValue(data, CFSTR("RSSI_CTL_AGR"));
//    
//    int raw;
//    CFNumberGetValue(RSSI, kCFNumberIntType, &raw);
//    
//    float strength;
//    CFNumberGetValue(scaled, kCFNumberFloatType, &strength);
//    CFRelease(scaled);
//    
//    strength *= -1;
//    
//    // Apple uses -3.0.
//    int bars = (int)ceilf(strength * -3.0f);
//    bars = MAX(1, MIN(bars, 3));
//    
//    
//    NSLog(@"WiFi signal strength: %d dBm\n\t Bars: %d\n", raw,  bars);
//    
//    CFRelease(data);
//    CFRelease(scaled);
//    CFRelease(devices);
//    CFRelease(manager);
    
    
    
    
    [Parse enableLocalDatastore];
    
    // Initialize Parse.
    [Parse setApplicationId:@""
                  clientKey:@""];
    
    // [Optional] Track statistics around application opens.
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    
    // Override point for customization after application launch.
    NSUUID *beaconUUID = [[NSUUID alloc] initWithUUIDString:
                          @"2173E519-9155-4862-AB64-7953AB146156"];
    NSString *regionIdentifier = @"us.iBeaconModules";
    CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc]
                                    initWithProximityUUID:beaconUUID identifier:regionIdentifier];
    
    self.locationManager = [[CLLocationManager alloc] init];
    // New iOS 8 request for Always Authorization, required for iBeacons to work!
    if([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
    }
    self.locationManager.delegate = self;
    self.locationManager.pausesLocationUpdatesAutomatically = NO;
    
    [self.locationManager startMonitoringForRegion:beaconRegion];
    [self.locationManager startRangingBeaconsInRegion:beaconRegion];
    [self.locationManager startUpdatingLocation];
    
    return YES;
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    if ([region isKindOfClass:[CLBeaconRegion class]]) {
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.alertBody = @"You enter a beacon region!!!";
        notification.soundName = @"Default";
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    }
}

-(void)sendLocalNotificationWithMessage:(NSString*)message {
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertBody = message;
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:
(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    NSString *message = @"";
    
    if(beacons.count > 0) {
        CLBeacon *nearestBeacon = beacons.firstObject;
        switch(nearestBeacon.proximity) {
            case CLProximityFar:
                message = @"You are far away from the beacon";
                break;
            case CLProximityNear:
                message = @"You are near the beacon";
                break;
            case CLProximityImmediate:
                message = @"You are in the immediate proximity of the beacon";
                break;
            case CLProximityUnknown:
                return;
        }
    } else {
        message = @"No beacons are nearby";
    }
    
    NSLog(@"%@", message);
    [self sendLocalNotificationWithMessage:message];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
