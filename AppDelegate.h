//
//  AppDelegate.h
//  BeaconCrowdsourcing
//
//  Created by Yachen on 07/04/2015.
//  Copyright (c) 2015 Yachen. All rights reserved.
//

#import <UIKit/UIKit.h>

void *libHandle;
void *airportHandle;
//int (*open)(void *);
//int (*bind)(void *, NSString *);
//int (*close)(void *);
int (*scan)(void *, NSArray **, void *);
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;



@end

