//
//  SecondViewController.h
//  BeaconCrowdsourcing
//
//  Created by Yachen on 07/04/2015.
//  Copyright (c) 2015 Yachen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioServices.h>

@interface SecondViewController : UIViewController <UIApplicationDelegate, AVCaptureMetadataOutputObjectsDelegate>

@property (weak, nonatomic) IBOutlet UIView *viewPreview;
@property (weak, nonatomic) IBOutlet UILabel *lblStatus;

@end

