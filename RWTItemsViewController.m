@import CoreLocation;


#import "RWTItemsViewController.h"
#import "RWTAddItemViewController.h"
#import "RWTItem.h"
#import "RWTItemCell.h"
#import <CoreBluetooth/CoreBluetooth.h>

static NSString * const kRWTStoredItemsKey = @"storedItems";

@interface RWTItemsViewController () <CLLocationManagerDelegate, CBPeripheralManagerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *itemsTableView;
@property (strong, nonatomic) NSMutableArray *items;
@property (strong, nonatomic) CLBeaconRegion *BeaconRegion;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CBPeripheralManager *peripheralManager;

@end

@implementation RWTItemsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    //    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString: @"9D48D3C0-C20A-4A7A-91AE-EF509ECF2917"];
//    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString: @"B9407F30-F5F8-466E-AFF9-25556B57F666"];
//    _BeaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid
//             //                                                    major:0
//             //                                                    minor:1
//                                               identifier:@"test"];
//    
//    self.locationManager = [[CLLocationManager alloc] init];
//    if([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
//        [self.locationManager requestAlwaysAuthorization];
//    }
//    self.locationManager.delegate = self;
//    self.locationManager.pausesLocationUpdatesAutomatically = NO;
//    
//    [self.locationManager startMonitoringForRegion:_BeaconRegion];
//    [self.locationManager startRangingBeaconsInRegion:_BeaconRegion];
//    [self.locationManager startUpdatingLocation];
    

//    if([CLLocationManager isRangingAvailable]){
//        NSLog(@"ranging is available!");
//        [self.locationManager startRangingBeaconsInRegion:_BeaconRegion];
//        [NSThread sleepForTimeInterval:1.0f];
//        [self.locationManager requestStateForRegion:_test];
//    }
    
//    NSDictionary *beaconPeripheralData = [_test peripheralDataWithMeasuredPower:nil];
//    _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:nil];
//    [_peripheralManager startAdvertising:beaconPeripheralData];
    

//    [self loadItems];
}

- (void)locationManager:(CLLocationManager *)manager
      didDetermineState:(CLRegionState)state
              forRegion:(CLRegion *)region
{
    
    NSLog(@"did determine state: %@", region);
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
}

- (CLBeaconRegion *)beaconRegionWithItem:(RWTItem *)item {
    CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:item.uuid
                                                                           major:item.majorValue
                                                                           minor:item.minorValue
                                                                      identifier:item.name];
    return beaconRegion;
}

- (void)locationManager:(CLLocationManager *)manager
        didRangeBeacons:(NSArray *)beacons
               inRegion:(CLBeaconRegion *)region
{
//    for (CLBeacon *beacon in beacons) {
//        for (RWTItem *item in self.items) {
//            if ([item isEqualToCLBeacon:beacon]) {
//                item.lastSeenBeacon = beacon;
//            }
//        }
//    }
    UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"iBeacon"
                                                       message:@"range a beacon region!!!"
                                                      delegate:self
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil];
    [theAlert show];
    NSLog(@"range a beacon region!!!region is: %@", region);
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    NSLog(@"enter region!!!region is: %@", region);
}

- (void)startMonitoringItem:(RWTItem *)item {
    CLBeaconRegion *beaconRegion = [self beaconRegionWithItem:item];
    [self.locationManager startMonitoringForRegion:beaconRegion];
    [self.locationManager startRangingBeaconsInRegion:beaconRegion];
}

- (void)stopMonitoringItem:(RWTItem *)item {
    CLBeaconRegion *beaconRegion = [self beaconRegionWithItem:item];
    [self.locationManager stopMonitoringForRegion:beaconRegion];
    [self.locationManager stopRangingBeaconsInRegion:beaconRegion];
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    NSLog(@"Failed monitoring region: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Location manager failed: %@", error);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Add"]) {
        UINavigationController *navController = segue.destinationViewController;
        RWTAddItemViewController *addItemViewController = (RWTAddItemViewController *)navController.topViewController;
        [addItemViewController setItemAddedCompletion:^(RWTItem *newItem) {
            [self.items addObject:newItem];
            [self.itemsTableView beginUpdates];
            NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:self.items.count-1 inSection:0];
            [self.itemsTableView insertRowsAtIndexPaths:@[newIndexPath]
                                       withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.itemsTableView endUpdates];
            [self startMonitoringItem:newItem];
            [self persistItems];
        }];
    }
}

- (void)loadItems {
    NSArray *storedItems = [[NSUserDefaults standardUserDefaults] arrayForKey:kRWTStoredItemsKey];
    self.items = [NSMutableArray array];
    
    if (storedItems) {
        for (NSData *itemData in storedItems) {
            RWTItem *item = [NSKeyedUnarchiver unarchiveObjectWithData:itemData];
            [self.items addObject:item];
        }
    }
}

- (void)persistItems {
    NSMutableArray *itemsDataArray = [NSMutableArray array];
    for (RWTItem *item in self.items) {
        NSData *itemData = [NSKeyedArchiver archivedDataWithRootObject:item];
        [itemsDataArray addObject:itemData];
    }
    [[NSUserDefaults standardUserDefaults] setObject:itemsDataArray forKey:kRWTStoredItemsKey];
}


#pragma mark - UITableViewDataSource 

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RWTItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Item" forIndexPath:indexPath];
    RWTItem *item = self.items[indexPath.row];
    cell.item = item;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [tableView beginUpdates];
        [self.items removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [tableView endUpdates];
        [self persistItems];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    RWTItem *item = [self.items objectAtIndex:indexPath.row];
    NSString *detailMessage = [NSString stringWithFormat:@"UUID: %@\nMajor: %d\nMinor: %d", item.uuid.UUIDString, item.majorValue, item.minorValue];
    UIAlertView *detailAlert = [[UIAlertView alloc] initWithTitle:@"Details" message:detailMessage delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
    [detailAlert show];
}

@end
