//
//  BFCentralManager.m
//  BlueFoundation
//
//  Created by Xin Wang on 7/25/16.
//  Copyright © 2016 Xin Wang. All rights reserved.
//

#import "BFCentralManager.h"

@import CoreBluetooth;

@interface BFCentralManager () <CBCentralManagerDelegate>
@property (strong, nonatomic) CBCentralManager *centralManager;
@property (strong, nonatomic) dispatch_queue_t queue;
@end

@implementation BFCentralManager

+ (instancetype)sharedManager
{
    static BFCentralManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    
    return _sharedManager;
}


- (instancetype)init
{
    if (self = [super init])
    {
        _queue = dispatch_queue_create("com.etchinglab.bluefoundation", DISPATCH_QUEUE_SERIAL);
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:self.queue options:nil];
    }
    
    return self;
}

#pragma mark - Central manager delegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    CBCentralManagerState centralState = central.state;
    switch (centralState) {
        case CBCentralManagerStateUnknown: {
            break;
        }
        case CBCentralManagerStateResetting: {
            break;
        }
        case CBCentralManagerStateUnsupported: {
            break;
        }
        case CBCentralManagerStateUnauthorized: {
            break;
        }
        case CBCentralManagerStatePoweredOff: {
            break;
        }
        case CBCentralManagerStatePoweredOn: {
            break;
        }
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI
{

}

@end
