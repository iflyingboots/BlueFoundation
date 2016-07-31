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
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray<NSString *> *> *mutableServices;
@end

@implementation BFPeripheralDelegate

- (nullable instancetype)init
{
    self = [super init];
    if (!self) return nil;
    
    self.mutableCharacteristics = [[NSMutableDictionary alloc] init];
    self.mutableServices = [[NSMutableDictionary alloc] init];
    self.state = BFPeripheralDelegateStateIdle;
    
    return self;
}

#pragma mark - Setters

- (void)setWriteWithNotifyHandler:(BFPeripheralDelegateWriteWithNotifyHandler)writeWithNotifyHandler
{
    _writeWithNotifyHandler = [writeWithNotifyHandler copy];
    self.state = BFPeripheralDelegateStateWriteWithNotify;
}

- (void)setWriteWithoutNotifyHandler:(BFPeripheralDelegateWriteWithoutNotifyHandler)writeWithoutNotifyHandler
{
    _writeWithoutNotifyHandler = [writeWithoutNotifyHandler copy];
    self.state = BFPeripheralDelegateStateWriteWithoutNotify;
}

- (void)setWriteThenReadHandler:(BFPeripheralDelegateWriteThenReadHandler)writeThenReadHandler
{
    _writeThenReadHandler = [writeThenReadHandler copy];
    self.state = BFPeripheralDelegateStateWriteThenRead;
}

- (void)setReadHandler:(BFPeripheralDelegateReadHandler)readHandler
{
    _readHandler = [readHandler copy];
    self.state = BFPeripheralDelegateStateRead;
}

- (void)setState:(BFPeripheralDelegateState)state
{
    BFPeripheralDelegateState previousState = _state;
    if (_state == state) {
        return;
    }
    switch (state) {
        case BFPeripheralDelegateStateIdle:
        case BFPeripheralDelegateStateConnected: {
            _state = state;
            break;
        }
        case BFPeripheralDelegateStateDiscoveringServices: {
            // check connection
            if (previousState < BFPeripheralDelegateStateConnected) {
                // TODO: ???
                break;
            }
            _state = state;
            break;
        }
        case BFPeripheralDelegateStateDiscoveringCharacteristics: {
            // discovered services?
            if (previousState < BFPeripheralDelegateStateDiscoveringServices
                || self.mutableServices.count == 0
                ) {
                executeBlockIfExistsThenSetNil(self.didDiscoverServicesAndCharacteriscitcsHandler,
                                               [BFError errorWithCode:BFErrorCodePeripheralNoServiceDiscovered]);
                break;
            }
            _state = state;
            break;
        }
        case BFPeripheralDelegateStateReady: {
            // discovered characteristcs?
            if (previousState < BFPeripheralDelegateStateDiscoveringCharacteristics
                || self.mutableServices.count == 0  // should have services
                || self.mutableCharacteristics.count == 0 // should have characteristics
                ) {
                break;
            }
            _state = state;
            break;
        }
        case BFPeripheralDelegateStateWriteWithNotify: {
            // executing other operations?
            if ([self checkIsExecuting]) {
                executeBlockIfExistsThenSetNil(self.writeWithNotifyHandler,
                                               nil, [BFError errorWithCode:BFErrorCodePeripheralBusy]);
                break;
            }
            _state = state;
            break;
        }
        case BFPeripheralDelegateStateWriteWithoutNotify: {
            // executing other operations?
            if ([self checkIsExecuting]) {
                executeBlockIfExistsThenSetNil(self.writeWithoutNotifyHandler,
                                               [BFError errorWithCode:BFErrorCodePeripheralBusy]);
                break;
            }
            _state = state;
            break;
        }
        case BFPeripheralDelegateStateWriteThenRead: {
            // executing other operations?
            if ([self checkIsExecuting]) {
                executeBlockIfExistsThenSetNil(self.writeThenReadHandler,
                                               nil, [BFError errorWithCode:BFErrorCodePeripheralBusy]);
                break;
            }
            _state = state;
            break;
        }
        case BFPeripheralDelegateStateRead: {
            // executing other operations?
            if ([self checkIsExecuting]) {
                executeBlockIfExistsThenSetNil(self.readHandler,
                                               nil, [BFError errorWithCode:BFErrorCodePeripheralBusy]);
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
        case BFPeripheralDelegateStateIdle:
        case BFPeripheralDelegateStateConnected:
        case BFPeripheralDelegateStateDiscoveringServices:
        case BFPeripheralDelegateStateDiscoveringCharacteristics:
        case BFPeripheralDelegateStateReady:
            return NO;
        case BFPeripheralDelegateStateWriteWithNotify:
        case BFPeripheralDelegateStateWriteWithoutNotify:
        case BFPeripheralDelegateStateWriteThenRead:
        case BFPeripheralDelegateStateRead:
            return YES;
    }
}

#pragma mark - Delegate

#pragma mark Data

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (self.state == BFPeripheralDelegateStateWriteWithoutNotify) {
        executeBlockIfExistsThenSetNil(self.writeWithoutNotifyHandler, error);
        self.state = BFPeripheralDelegateStateReady;
    } else if (self.state == BFPeripheralDelegateStateWriteWithNotify) {
        executeBlockIfExistsThenSetNil(self.writeWithNotifyHandler, characteristic.value, error);
        self.state = BFPeripheralDelegateStateReady;
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error
{
    if (self.state == BFPeripheralDelegateStateRead) {
        executeBlockIfExistsThenSetNil(self.readHandler, characteristic.value, error);
        self.state = BFPeripheralDelegateStateReady;
    } else if (self.state == BFPeripheralDelegateStateWriteWithNotify) {
        executeBlockIfExistsThenSetNil(self.writeWithNotifyHandler, characteristic.value, error);
        self.state = BFPeripheralDelegateStateReady;
    }
}

#pragma mark RSSI

- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error
{
    executeBlockIfExistsThenSetNil(self.readRSSIHandler, RSSI, error);
}

#pragma mark Services

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    // TODO: error handling
    for (CBService *service in peripheral.services) {
        // converts UUID string to uppercase
        self.mutableServices[service.UUID.UUIDString.uppercaseString] = [[NSMutableArray alloc] init];
        [peripheral discoverCharacteristics:nil forService:service];
    }
    
    self.state = BFPeripheralDelegateStateDiscoveringCharacteristics;
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
        self.state = BFPeripheralDelegateStateReady;
        executeBlockIfExistsThenSetNil(self.didDiscoverServicesAndCharacteriscitcsHandler, error);
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
