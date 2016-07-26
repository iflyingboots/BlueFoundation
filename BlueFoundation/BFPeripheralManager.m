//
//  BFPeripheralManager.m
//  BlueFoundation
//
//  Created by Xin Wang on 7/26/16.
//  Copyright © 2016 Xin Wang. All rights reserved.
//

@import CoreBluetooth;

#import "BFPeripheralManager.h"

@interface BFPeripheralDelegate : NSObject <CBPeripheralDelegate>
@property (nonatomic, weak) BFPeripheralManager *manager;
@end

@implementation BFPeripheralDelegate

#pragma mark - Peripheral delegate

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    
}

- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error
{
    
}

@end

@interface BFPeripheralManager ()
@property (nonatomic, strong) NSLock *lock;
@property (nonatomic, strong) NSMutableDictionary<NSString *, BFPeripheralDelegate *> *mutableKeyedPeripheralDelegates;
@end

@implementation BFPeripheralManager

- (instancetype)init
{
    self = [super init];
    if (!self) return nil;
    
    self.lock = [[NSLock alloc] init];
    self.mutableKeyedPeripheralDelegates = [[NSMutableDictionary alloc] init];
    
    return self;
}

+ (instancetype)manager
{
    static BFPeripheralManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[BFPeripheralManager alloc] init];
    });
    
    return _sharedManager;
}

- (void)addPeripheral:(CBPeripheral *)peripheral
{
    [self.lock lock];
    BFPeripheralDelegate *delegate = [[BFPeripheralDelegate alloc] init];
    delegate.manager = self;
    peripheral.delegate = delegate;
    self.mutableKeyedPeripheralDelegates[peripheral.identifier.UUIDString] = delegate;
    [self.lock unlock];
}

@end
