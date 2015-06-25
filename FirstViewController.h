//
//  FirstViewController.h
//  BeaconCrowdsourcing
//
//  Created by Yachen on 07/04/2015.
//  Copyright (c) 2015 Yachen. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@class CMMotionActivity;

typedef void (^CMPedometerHandler)(CMPedometerData *pedometerData, NSError *error);

@interface FirstViewController : UIViewController <CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *magneticHeading;
@property (weak, nonatomic) IBOutlet UILabel *trueHeading;
@property (weak, nonatomic) IBOutlet UILabel *Steps;
@property (weak, nonatomic) IBOutlet UILabel *Distance;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CMMotionActivityManager *cmManager;
@property (nonatomic, strong) CMPedometer *pedometer;

+(double)DistanceComputation:(double)oldDistance withnew:(double)newDistance
    anddegree:(double)degree;

@end

