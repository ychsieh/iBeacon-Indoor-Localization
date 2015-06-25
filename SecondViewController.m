//
//  SecondViewController.m
//  BeaconCrowdsourcing
//
//  Created by Yachen on 07/04/2015.
//  Copyright (c) 2015 Yachen. All rights reserved.
//

#import "SecondViewController.h"
#import <Parse/Parse.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface SecondViewController () <CBPeripheralManagerDelegate>

@property (nonatomic) BOOL finishReading;

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (strong, nonatomic) CBPeripheralManager *peripheralManager;

-(BOOL)startReading;
@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // register enter background notification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDidEnterBackgroundNotification)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    _finishReading = NO;
    
    NSLog(@"state is %ld", (long)_peripheralManager.state);  
    _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) options:nil];
    
    if ([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusAvailable) {
        
        NSLog(@"Background updates are available for the app.");
    }else if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusDenied)
    {
        NSLog(@"The user explicitly disabled background behavior for this app or for the whole system.");
    }else if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusRestricted)
    {
        NSLog(@"Background updates are unavailable and the user cannot enable them again. For example, this status can occur when parental controls are in effect for the current user.");
    }
    
    _captureSession = nil;
    [self startReading];
}

-(void)viewDidAppear:(BOOL)animated{
}

- (void)viewDidDisappear:(BOOL)animated {
    NSLog(@"view disappear");
    [_lblStatus performSelectorOnMainThread:@selector(setText:) withObject:@"QR Code Reader" waitUntilDone:NO];
    _finishReading = NO;
}

-(void)handleDidEnterBackgroundNotification{
    NSLog(@"enter background");
    [_lblStatus performSelectorOnMainThread:@selector(setText:) withObject:@"QR Code Reader" waitUntilDone:NO];
    _finishReading = NO;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    // app was "minimized"
    NSLog(@"enter background");
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    //  resign active also includes (accidental) slide down top menu, or the new slide up bottom menu
    NSLog(@"resign active");
}

-(void)viewWillLayoutSubviews{
    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [_videoPreviewLayer setFrame:_viewPreview.layer.bounds];
    [_viewPreview.layer addSublayer:_videoPreviewLayer];
}

- (BOOL)startReading {
    NSError *error;
    
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    
    if (!input) {
        NSLog(@"%@", [error localizedDescription]);
        return NO;
    }
    
    _captureSession = [[AVCaptureSession alloc] init];
    [_captureSession addInput:input];
    
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [_captureSession addOutput:captureMetadataOutput];
    
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("myQueue", NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
    
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    
    [_captureSession startRunning];
    
    return YES;
}

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode] && !_finishReading) {
            _finishReading = YES;
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);

            NSString *dataString = [metadataObj stringValue];
            NSLog(@"UUID is: %@", dataString);
            
            PFQuery *query = [PFQuery queryWithClassName:@"Beacon"];
            [query whereKey:@"UUID" equalTo:dataString];
            [query getFirstObjectInBackgroundWithBlock: ^(PFObject *beacon, NSError *error) {
                // Do something with the returned PFObject.
                NSString *uustr = [beacon objectForKey:@"UUID"];
//                NSLog(@"scan UUID is: %@", uustr);
//                NSLog(@"built UUID is: 9D48D3C0-C20A-4A7A-91AE-EF509ECF2917");
                if([uustr caseInsensitiveCompare:@"9D48D3C0-C20A-4A7A-91AE-EF509ECF2917"] == NSOrderedSame )
                    NSLog(@"equal!!!");

                NSUUID *uuid = [[NSUUID alloc] initWithUUIDString: uustr];
                CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc]
                                                initWithProximityUUID:uuid
                                                identifier:@"test"];
                
//                NSUUID *uuid2 = [[NSUUID alloc] initWithUUIDString: @"9D48D3C0-C20A-4A7A-91AE-EF509ECF2917"];
//                CLBeaconRegion *test = [[CLBeaconRegion alloc] initWithProximityUUID:uuid2
//                                                           identifier:@"test"];
                
                NSDictionary *beaconPeripheralData = [beaconRegion peripheralDataWithMeasuredPower:nil];
//                CBPeripheralManager *peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:nil];
                [_peripheralManager startAdvertising:beaconPeripheralData];
                NSLog(@"state is %ld after scan", (long)_peripheralManager.state);

            }];
            
        }
    }
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    if (peripheral.state == CBPeripheralManagerStatePoweredOn) {
        NSLog(@"Powered On");
//        [self.peripheralManager startAdvertising:self.beaconPeripheralData];
    } else if (peripheral.state == CBPeripheralManagerStatePoweredOff) {
        NSLog(@"Powered Off");
//        [self.peripheralManager stopAdvertising];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
