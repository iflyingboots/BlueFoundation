//
//  CBPeripheral+BlueFoundation.m
//  BlueFoundation
//
//  Created by Xin Wang on 7/27/16.
//  Copyright © 2016 EtchingLab. All rights reserved.
//

#import "CBPeripheral+BlueFoundation.h"
#import "BFError.h"

@implementation CBPeripheral (BlueFoundation)
@dynamic bf_characteristics;

#pragma mark - Dynamic property

- (nullable NSDictionary<NSString *,CBCharacteristic *> *)bf_characteristics
{
    BFPeripheralDelegate *bfPeripheralDelegate = [self getBlueFoundationPeripheralDelegate];
    if (bfPeripheralDelegate) {
        return [bfPeripheralDelegate.mutableCharacteristics copy];
    }
    return nil;
}

#pragma mark -

- (void)bf_writeValue:(NSData *)data forCharacteristicUUIDString:(NSString *)characteristicUUIDString withNotify:(BFPeripheralDelegateWriteWithNotifyHandler)handler;
{
    BFPeripheralDelegate *bfPeripheralDelegate = [self getBlueFoundationPeripheralDelegate];
    if (bfPeripheralDelegate) {
        bfPeripheralDelegate.writeWithNotifyHandler = handler;
        CBCharacteristic *characteristic = bfPeripheralDelegate.mutableCharacteristics[characteristicUUIDString.uppercaseString];
        if (characteristic) {
            if (characteristic.properties & CBCharacteristicPropertyWriteWithoutResponse) {
                [self writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
            } else {
                [self writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
            }
        } else {
            bfPeripheralDelegate.writeWithNotifyHandler(nil, [BFError errorWithCode:BFErrorCodePeripheralNoSuchCharacteristic]);
        }
    } else {
        // TODO: non-BlueFoundation delegate
    }
}

- (void)bf_writeValue:(NSData *)data forCharacteristicUUIDString:(NSString *)characteristicUUIDString withoutNotify:(BFPeripheralDelegateWriteWithoutNotifyHandler)handler
{
    BFPeripheralDelegate *bfPeripheralDelegate = [self getBlueFoundationPeripheralDelegate];
    if (bfPeripheralDelegate) {
        bfPeripheralDelegate.writeWithoutNotifyHandler = handler;
        CBCharacteristic *characteristic = bfPeripheralDelegate.mutableCharacteristics[characteristicUUIDString.uppercaseString];
        if (characteristic) {
            if (characteristic.properties & CBCharacteristicPropertyWriteWithoutResponse) {
                [self writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
            } else {
                [self writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
            }
        } else {
            bfPeripheralDelegate.writeWithoutNotifyHandler([BFError errorWithCode:BFErrorCodePeripheralNoSuchCharacteristic]);
        }
    } else {
        // TODO: non-BlueFoundation delegate
    }
}

- (void)bf_writeValue:(NSData *)data forCharacteristicUUIDString:(NSString *)writeCharacteristicUUIDString thenReadCharacteristicUUIDString:(NSString *)readCharacteristicUUIDString completion:(BFPeripheralDelegateWriteThenReadHandler)handler
{
    BFPeripheralDelegate *bfPeripheralDelegate = [self getBlueFoundationPeripheralDelegate];
    if (bfPeripheralDelegate) {
        bfPeripheralDelegate.writeThenReadHandler = handler;
        CBCharacteristic *writeCharacteristic = bfPeripheralDelegate.mutableCharacteristics[writeCharacteristicUUIDString.uppercaseString];
        if (writeCharacteristic) {
            if (writeCharacteristic.properties & CBCharacteristicPropertyWriteWithoutResponse) {
                [self writeValue:data forCharacteristic:writeCharacteristic type:CBCharacteristicWriteWithoutResponse];
            } else {
                [self writeValue:data forCharacteristic:writeCharacteristic type:CBCharacteristicWriteWithResponse];
            }
        } else {
            bfPeripheralDelegate.writeThenReadHandler(nil, [BFError errorWithCode:BFErrorCodePeripheralNoSuchCharacteristic]);
        }
        // TODO: then read
    } else {
        // TODO: non-BlueFoundation delegate
    }
}

- (void)bf_readValueForCharacteristicUUIDString:(NSString *)characteristicUUIDString completion:(BFPeripheralDelegateReadHandler)completion
{
    BFPeripheralDelegate *bfPeripheralDelegate = [self getBlueFoundationPeripheralDelegate];
    if (bfPeripheralDelegate) {
        bfPeripheralDelegate.readHandler = completion;
        CBCharacteristic *charcteristic = bfPeripheralDelegate.mutableCharacteristics[characteristicUUIDString];
        if (charcteristic) {
            [self readValueForCharacteristic:charcteristic];
        }
    }
}


- (void)bf_discoverServices:(nullable NSArray<CBUUID *> *)serviceUUIDs andCharacteristicsWithCompletion:(BFPeripheralDelegateDidDiscoverServicesAndCharacteristicsHandler)handler;
{
    if (self.state != CBPeripheralStateConnected) {
        handler([BFError errorWithCode:BFErrorCodePeripheralDisconnected]);
        return;
    }
    BFPeripheralDelegate *bfPeripheralDelegate = [self getBlueFoundationPeripheralDelegate];
    if (bfPeripheralDelegate) {
        // TODO: error handling
        bfPeripheralDelegate.state = BFPeripheralDelegateStateDiscoveringServices;
        bfPeripheralDelegate.didDiscoverServicesAndCharacteriscitcsHandler = handler;
    }
    
    [self discoverServices:serviceUUIDs];
}

- (void)bf_readRSSIWithHandler:(BFPeripheralDelegateReadRSSIHandler)handler
{
    BFPeripheralDelegate *bfPeripheralDelegate = [self getBlueFoundationPeripheralDelegate];
    if (bfPeripheralDelegate) {
        bfPeripheralDelegate.readRSSIHandler = handler;
    }
    
    [self readRSSI];
}

#pragma mark - Helpers

- (nullable BFPeripheralDelegate *)getBlueFoundationPeripheralDelegate
{
    id<CBPeripheralDelegate> delegate = self.delegate;
    
    if (delegate && [delegate isKindOfClass:BFPeripheralDelegate.class]) {
        return (BFPeripheralDelegate *)delegate;
    }
    
    return nil;
}

@end
