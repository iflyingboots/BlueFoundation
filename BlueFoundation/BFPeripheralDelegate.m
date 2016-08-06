//
//  BFPeripheralDelegate.m
//  BlueFoundation
//
//  Created by Xin Wang on 7/27/16.
//  Copyright © 2016 EtchingLab. All rights reserved.
//

#import "BFPeripheralDelegate.h"
#import "BFUtilities.h"
#import "BFError.h"

@interface BFPeripheralDelegate ()
@property (nonatomic, strong, nonnull) NSMutableDictionary<NSString *, NSMutableArray<NSString *> *> *mutableServices;
@property (nonatomic, copy, nullable) NSString *currentWriteCharacteristicUUIDString;
@property (nonatomic, copy, nullable) NSString *currentReadCharacteristicUUIDString;
@property (nonatomic, copy, nullable) NSString *currentNotifyCharacteristicUUIDString;
@end

@implementation BFPeripheralDelegate

- (nullable instancetype)init
{
    self = [super init];
    if (!self) return nil;
    
    self.mutableCharacteristics = [[NSMutableDictionary alloc] init];
    self.mutableServices = [[NSMutableDictionary alloc] init];
    self.state = BFPeripheralStateIdle;
    self.completionQueue = dispatch_get_main_queue();
    
    return self;
}

#pragma mark - Set handlers

- (void)setWriteWithNotifyHandler:(BFPeripheralWriteWithNotifyHandler)writeWithNotifyHandler writeCharacteristicUUIDString:(NSString * _Nonnull)writeCharacteristicUUIDString notifyCharacteristicUUIDString:(NSString * _Nonnull)notifyCharacteristicUUIDString
{
    self.writeWithNotifyHandler = writeWithNotifyHandler;
    self.currentWriteCharacteristicUUIDString = writeCharacteristicUUIDString.uppercaseString;
    self.currentReadCharacteristicUUIDString = nil;
    self.currentNotifyCharacteristicUUIDString = notifyCharacteristicUUIDString.uppercaseString;
    self.state = BFPeripheralStateWriteWithNotify;
}

- (void)setWriteWithoutNotifyHandler:(BFPeripheralWriteWithoutNotifyHandler)writeWithoutNotifyHandler writeCharacteristicUUIDString:(NSString * _Nonnull)writeCharacteristicUUIDString
{
    self.writeWithoutNotifyHandler = writeWithoutNotifyHandler;
    self.currentWriteCharacteristicUUIDString = writeCharacteristicUUIDString.uppercaseString;
    self.currentReadCharacteristicUUIDString = nil;
    self.currentNotifyCharacteristicUUIDString = nil;
    self.state = BFPeripheralStateWriteWithoutNotify;
}

- (void)setWriteThenReadHandler:(BFPeripheralWriteThenReadHandler)writeThenReadHandler writeCharacteristicUUIDString:(NSString * _Nonnull)writeCharacteristicUUIDString readCharacteristicUUIDString:(NSString * _Nonnull)readCharacteristicUUIDString
{
    self.writeThenReadHandler = writeThenReadHandler;
    self.currentWriteCharacteristicUUIDString = writeCharacteristicUUIDString.uppercaseString;
    self.currentReadCharacteristicUUIDString = readCharacteristicUUIDString.uppercaseString;
    self.currentNotifyCharacteristicUUIDString = nil;
    self.state = BFPeripheralStateWriteThenRead;
}

- (void)setReadHandler:(BFPeripheralReadHandler)readHandler readCharacteristicUUIDString:(NSString * _Nonnull)readCharacteristicUUIDString
{
    self.readHandler = readHandler;
    self.currentWriteCharacteristicUUIDString = nil;
    self.currentReadCharacteristicUUIDString = readCharacteristicUUIDString.uppercaseString;
    self.currentNotifyCharacteristicUUIDString = nil;
    self.state = BFPeripheralStateRead;
}

#pragma mark - Setters

- (void)setState:(BFPeripheralState)state
{
    BFPeripheralState previousState = _state;
    if (_state == state) {
        return;
    }
    switch (state) {
        case BFPeripheralStateIdle:
        case BFPeripheralStateConnected: {
            _state = state;
            break;
        }
        case BFPeripheralStateDiscoveringServices: {
            // check connection
            if (previousState < BFPeripheralStateConnected) {
                break;
            }
            _state = state;
            break;
        }
        case BFPeripheralStateDiscoveringCharacteristics: {
            // discovered services?
            if (previousState < BFPeripheralStateDiscoveringServices
                || self.mutableServices.count == 0
                ) {
                dispatch_async(self.completionQueue, ^{
                    executeBlockIfExistsThenSetNil(self.didDiscoverServicesAndCharacteriscitcsHandler,
                                                   [BFError errorWithCode:BFErrorCodePeripheralNoServiceDiscovered]);
                });
                break;
            }
            _state = state;
            break;
        }
        case BFPeripheralStateReady: {
            // discovered characteristcs?
            if (previousState < BFPeripheralStateDiscoveringCharacteristics
                || self.mutableServices.count == 0  // should have services
                || self.mutableCharacteristics.count == 0 // should have characteristics
                ) {
                break;
            }
            _state = state;
            break;
        }
        case BFPeripheralStateWriteWithNotify: {
            // executing other operations?
            if ([self checkIsExecuting]) {
                dispatch_async(self.completionQueue, ^{
                    executeBlockIfExistsThenSetNil(self.writeWithNotifyHandler,
                                                   nil, [BFError errorWithCode:BFErrorCodePeripheralBusy]);
                });
                break;
            }
            _state = state;
            break;
        }
        case BFPeripheralStateWriteWithoutNotify: {
            // executing other operations?
            if ([self checkIsExecuting]) {
                dispatch_async(self.completionQueue, ^{
                    executeBlockIfExistsThenSetNil(self.writeWithoutNotifyHandler,
                                                   [BFError errorWithCode:BFErrorCodePeripheralBusy]);
                });
                break;
            }
            _state = state;
            break;
        }
        case BFPeripheralStateWriteThenRead: {
            // executing other operations?
            if ([self checkIsExecuting]) {
                dispatch_async(self.completionQueue, ^{
                    executeBlockIfExistsThenSetNil(self.writeThenReadHandler,
                                                   nil, [BFError errorWithCode:BFErrorCodePeripheralBusy]);
                });
                break;
            }
            _state = state;
            break;
        }
        case BFPeripheralStateWriteThenReadInWriting: {
            if (previousState != BFPeripheralStateWriteThenRead) {
                BFLog(@"Invalid state transition for WriteAndReadInWriting");
                break;
            }
            _state = state;
            break;
        }
        case BFPeripheralStateWriteThenReadInReading: {
            if (previousState != BFPeripheralStateWriteThenReadInWriting) {
                BFLog(@"Invalid state transition for WriteAndReadInReading");
                break;
            }
            _state = state;
            break;
        }
        case BFPeripheralStateRead: {
            // executing other operations?
            if ([self checkIsExecuting]) {
                dispatch_async(self.completionQueue, ^{
                    executeBlockIfExistsThenSetNil(self.readHandler,
                                                   nil, [BFError errorWithCode:BFErrorCodePeripheralBusy]);
                });
                break;
            }
            _state = state;
            break;
        }
    }
}

#pragma mark - State transition helper

- (BOOL)checkIsExecuting
{
    switch (self.state) {
        case BFPeripheralStateIdle:
        case BFPeripheralStateConnected:
        case BFPeripheralStateDiscoveringServices:
        case BFPeripheralStateDiscoveringCharacteristics:
        case BFPeripheralStateReady:
            return NO;
        case BFPeripheralStateWriteWithNotify:
        case BFPeripheralStateWriteWithoutNotify:
        case BFPeripheralStateWriteThenRead:
        case BFPeripheralStateWriteThenReadInWriting:
        case BFPeripheralStateWriteThenReadInReading:
        case BFPeripheralStateRead:
            return YES;
    }
}

#pragma mark - Delegate

#pragma mark Data

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (self.state == BFPeripheralStateWriteWithoutNotify) {
        dispatch_async(self.completionQueue, ^{
            executeBlockIfExistsThenSetNil(self.writeWithoutNotifyHandler, error);
        });
        self.state = BFPeripheralStateReady;
    } else if (self.state == BFPeripheralStateWriteWithNotify) {
        dispatch_async(self.completionQueue, ^{
            executeBlockIfExistsThenSetNil(self.writeWithNotifyHandler, characteristic.value, error);
        });
        self.state = BFPeripheralStateReady;
    } else if (self.state == BFPeripheralStateWriteThenReadInWriting) {
        self.state = BFPeripheralStateWriteThenReadInReading;
    } else {
        NSAssert(NO, @"didWriteValueForCharacteristic: Illegal state: %@", @(self.state));
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error
{
    if (self.state == BFPeripheralStateRead) {
        // not from expected characteristic
        if (![characteristic.UUID.UUIDString.uppercaseString isEqualToString:self.currentReadCharacteristicUUIDString]) {
            return;
        }
        dispatch_async(self.completionQueue, ^{
            executeBlockIfExistsThenSetNil(self.readHandler, characteristic.value, error);
        });
        self.state = BFPeripheralStateReady;
    } else if (self.state == BFPeripheralStateWriteWithNotify) {
        // not from expected characteristic
        if (![characteristic.UUID.UUIDString.uppercaseString isEqualToString:self.currentNotifyCharacteristicUUIDString]) {
            return;
        }
        dispatch_async(self.completionQueue, ^{
            executeBlockIfExistsThenSetNil(self.writeWithNotifyHandler, characteristic.value, error);
        });
        self.state = BFPeripheralStateReady;
    } else if (self.state == BFPeripheralStateWriteThenReadInReading) {
        // not from expected characteristic
        if (![characteristic.UUID.UUIDString.uppercaseString isEqualToString:self.currentReadCharacteristicUUIDString]) {
            return;
        }
        dispatch_async(self.completionQueue, ^{
            executeBlockIfExistsThenSetNil(self.writeThenReadHandler, characteristic.value, error);
        });
        self.state = BFPeripheralStateReady;
    } else {
        NSAssert(NO, @"didUpdateValueForCharacteristic: Illegal state: %@", @(self.state));
    }
}

#pragma mark RSSI

- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error
{
    dispatch_async(self.completionQueue, ^{
        executeBlockIfExistsThenSetNil(self.readRSSIHandler, RSSI, error);
    });
}

#pragma mark Services

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error) {
        dispatch_async(self.completionQueue, ^{
            executeBlockIfExistsThenSetNil(self.didDiscoverServicesAndCharacteriscitcsHandler, error);
        });
        return;
    }
    
    for (CBService *service in peripheral.services) {
        // converts UUID string to uppercase
        self.mutableServices[service.UUID.UUIDString.uppercaseString] = [[NSMutableArray alloc] init];
        [peripheral discoverCharacteristics:nil forService:service];
    }
    
    self.state = BFPeripheralStateDiscoveringCharacteristics;
}

- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray<CBService *> *)invalidatedServices
{
    
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(nullable NSError *)error
{
    
}

#pragma mark Characteristics

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service
             error:(NSError *)error
{
    if (error) {
        dispatch_async(self.completionQueue, ^{
            executeBlockIfExistsThenSetNil(self.didDiscoverServicesAndCharacteriscitcsHandler, error);
        });
        return;
    }
    
    // convert UUID string to uppercase
    NSString *serviceUUIDString = service.UUID.UUIDString.uppercaseString;
    for (CBCharacteristic *charasteristic in service.characteristics) {
        NSString *characteristicUUIDString = charasteristic.UUID.UUIDString.uppercaseString;
        if (charasteristic.properties & CBCharacteristicPropertyNotify) {
            [peripheral setNotifyValue:YES forCharacteristic:charasteristic];
        }
        self.mutableCharacteristics[characteristicUUIDString] = charasteristic;
        [self.mutableServices[serviceUUIDString] addObject:characteristicUUIDString];
    }
    
    // check if all services are discovered, and invoke callback if needed
    __block BOOL finishDiscoveringAllServices = YES;
    [self.mutableServices enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSMutableArray<NSString *> * _Nonnull obj, BOOL * _Nonnull stop) {
        if (obj.count == 0) {
            finishDiscoveringAllServices = NO;
            *stop = YES;
        }
    }];
    
    if (finishDiscoveringAllServices) {
        self.state = BFPeripheralStateReady;
        dispatch_async(self.completionQueue, ^{
            executeBlockIfExistsThenSetNil(self.didDiscoverServicesAndCharacteriscitcsHandler, error);
        });
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error
{

}

#pragma mark Name

- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral
{
    
}

@end
