//
//  BFCentralManager.m
//  BlueFoundation
//
//  Created by Xin Wang on 7/25/16.
//  Copyright © 2016 EtchingLab. All rights reserved.
//

#import "BFCentralManager.h"
#import "BFPeripheralManager.h"

static dispatch_queue_t central_manager_processing_queue()
{
    static dispatch_queue_t bf_central_manager_processing_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bf_central_manager_processing_queue = dispatch_queue_create("com.etchinglab.bluefoundation.processing", DISPATCH_QUEUE_SERIAL);
    });
    
    return bf_central_manager_processing_queue;
}

@interface BFCentralManager () <CBCentralManagerDelegate>
@property (strong, nonatomic) CBCentralManager *centralManager;
@property (strong, nonatomic) BFPeripheralManager *peripheralManager;
@property (copy, nonatomic) BFCentralManagerScanCompletionHandler scanCompletionHandler;
@property (copy, nonatomic) BFCentralManagerStateUpdateHandler stateUpdateHandler;
@end

@implementation BFCentralManager
{
    BOOL _didDiscoverPeripheralStopScanFlag;
    BOOL _didDiscoverPeripheralConnectNeededFlag;
}

+ (void)load
{
    // Trigger CBCentralManager to run in a very early phase
    [[self class] manager];
}

+ (instancetype)manager
{
    static BFCentralManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[BFCentralManager alloc] init];
    });
    
    return _sharedManager;
}

- (instancetype)init
{
    self = [super init];
    if (!self) return nil;
    
    // TODO: customize `options`
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:central_manager_processing_queue() options:nil];
    self.peripheralManager = [BFPeripheralManager manager];
    
    _didDiscoverPeripheralStopScanFlag = NO;
    _didDiscoverPeripheralConnectNeededFlag = NO;
    
    return self;
}

#pragma mark - Public

- (void)scanForPeripheralsWithServices:(nullable NSArray<CBUUID *> *)serviceUUIDs options:(nullable NSDictionary<NSString *, id> *)options completion:(BFCentralManagerScanCompletionHandler)handler
{
    self.scanCompletionHandler = handler;
    [self.centralManager scanForPeripheralsWithServices:serviceUUIDs options:options];
}

- (void)stateUpdated:(BFCentralManagerStateUpdateHandler)handler
{
    self.stateUpdateHandler = handler;
}

- (NSArray<CBPeripheral *> *)retrieveConnectedPeripheralsWithServices:(NSArray<CBUUID *> *)serviceUUIDs
{
    return [self.centralManager retrieveConnectedPeripheralsWithServices:serviceUUIDs];
}

#pragma mark - Central manager delegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    CBCentralManagerState centralState = central.state;
    
    if (self.stateUpdateHandler) {
        dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
            self.stateUpdateHandler(central, centralState);
        });
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI
{
    if (self.scanCompletionHandler && !_didDiscoverPeripheralStopScanFlag) {
        dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
            self.scanCompletionHandler(peripheral, advertisementData, RSSI, &_didDiscoverPeripheralConnectNeededFlag, &_didDiscoverPeripheralStopScanFlag);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (_didDiscoverPeripheralStopScanFlag)
                {
                    self.scanCompletionHandler = nil;
                    [self.centralManager stopScan];
                }
            
                if (_didDiscoverPeripheralConnectNeededFlag)
                {
                    [self.centralManager connectPeripheral:peripheral options:nil];
                    _didDiscoverPeripheralConnectNeededFlag = NO;
                }
                
            
            });
        });
    }
}

- (void)connectPeripheral:(CBPeripheral *)peripheral options:(nullable NSDictionary<NSString *,id> *)options
{
    [self.peripheralManager addPeripheral:peripheral];
    [self.centralManager connectPeripheral:peripheral options:options];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    
}

@end
