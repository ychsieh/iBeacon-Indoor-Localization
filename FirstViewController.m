//
//  FirstViewController.m
//  BeaconCrowdsourcing
//
//  Created by Yachen on 07/04/2015.
//  Copyright (c) 2015 Yachen. All rights reserved.
//

@import CoreMotion;

#import "FirstViewController.h"

@interface FirstViewController ()
@end

@implementation FirstViewController
{
    NSNumber *cmDistance;
    double curLoc;
    double curHeading;
    double prevHeading;
    int round;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    cmDistance = 0;
    curLoc = 0;
    prevHeading = 0;
    round = 0;
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingHeading];
    [self.locationManager startUpdatingLocation];
    
    if ([CMMotionActivityManager isActivityAvailable]){
        self.cmManager = [[CMMotionActivityManager alloc] init];
        [self.cmManager startActivityUpdatesToQueue:[NSOperationQueue new] withHandler: ^(CMMotionActivity *activity) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if(activity.stationary)
                {
                    NSLog(@"stationatry");
                }
                if(activity.walking)
                {
                    NSLog(@"walking");
                }
                if(activity.automotive)
                {
                    NSLog(@"automotive");
                }
                if(activity.cycling)
                {
                    NSLog(@"cycling");
                }
                if(activity.unknown)
                {
                    NSLog(@"unknown");
                }
            });
        }];
        
        self.pedometer = [[CMPedometer alloc] init];
        [self.pedometer startPedometerUpdatesFromDate:[NSDate date] withHandler:^(CMPedometerData *pedometerData, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSNumber *newdistance = pedometerData.distance;
                double newstep = [newdistance doubleValue]-[cmDistance doubleValue];
                if(error){
                    NSLog(@"%@", error);
                }else{
                    double absDiff = fabs(prevHeading-curHeading);
                    NSLog(@"degree difference is: %f",absDiff);
                    self.Steps.text = [NSString stringWithFormat:@"%@", pedometerData.numberOfSteps];
                    if(absDiff > 1){
                        if(absDiff>180) absDiff = 360-absDiff;
                        double prevLoc = curLoc;
                        curLoc = [FirstViewController DistanceComputation:curLoc withnew:newstep anddegree:180-absDiff];
                        double temp = pow(prevLoc, 2)+pow(curLoc, 2)-pow(newstep,2);
                        prevHeading = acos(temp/(2*prevLoc*curLoc))* 180 / M_PI;
                        self.Distance.text = [NSString stringWithFormat:@"%f", curLoc];
                        //                        double result = [FirstViewController DistanceComputation:curLoc withnew:newstep anddegree:absDiff];
                        //                        NSLog(@"result is %f",result);
                    }
                    else{
                        curLoc += newstep;
                        prevHeading = curHeading;
                        self.Distance.text = [NSString stringWithFormat:@"%f", curLoc];
                    }
                    cmDistance = newdistance;
                    
                    if(curLoc > 15)
                        self.magneticHeading.text = [NSString stringWithFormat:@"OUT!!!"];
                    NSLog(@"step updates: %f", curLoc);
                }
            });
        }];
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    if(round == 0){
        curHeading = newHeading.trueHeading;
        
        //    self.magneticHeading.text = [NSString stringWithFormat:@"%f", newHeading.magneticHeading];
        
        round++;
    }
    else{
        round++;
        round %= 50;
    }
    self.trueHeading.text = [NSString stringWithFormat:@"%f", newHeading.trueHeading];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+(double)DistanceComputation:(double)oldDistance
                     withnew:(double)newDistance
                   anddegree:(double)degree
{
    double abcos = 2 * oldDistance * newDistance * cos(degree*M_PI/180);
    double powersum = pow(oldDistance, 2) + pow(newDistance, 2);
    return sqrt(powersum-abcos);
}


@end
