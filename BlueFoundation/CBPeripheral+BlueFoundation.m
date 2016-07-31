//
//  CBPeripheral+BlueFoundation.m
//  BlueFoundation
//
//  Created by Xin Wang on 7/27/16.
//  Copyright © 2016 EtchingLab. All rights reserved.
//

#import "CBPeripheral+BlueFoundation.h"
#import "BFError.h"
#import "BFUtilities.h"

@implementation CBPeripheral (BlueFoundation)
@dynamic bf_characteristics;
@dynamic bf_completionQueue;

#pragma mark - Dynamic property

- (nullable NSDictionary<NSString *,CBCharacteristic *> *)bf_characteristics
{
    BFPeripheralDelegate *bfPeripheralDelegate = [self getBlueFoundationPeripheralDelegate];
    NSAssert(bfPeripheralDelegate, @"The delegate of this peripheral is not managed by BlueFoundation.");

    return [bfPeripheralDelegate.mutableCharacteristics copy];
}

- (nullable dispatch_queue_t)bf_completionQueue
{
    BFPeripheralDelegate *bfPeripheralDelegate = [self getBlueFoundationPeripheralDelegate];
    NSAssert(bfPeripheralDelegate, @"The delegate of this peripheral is not managed by BlueFoundation.");

    return bfPeripheralDelegate.completionQueue;
}

- (void)setBf_completionQueue:(dispatch_queue_t)bf_completionQueue
{
    BFPeripheralDelegate *bfPeripheralDelegate = [self getBlueFoundationPeripheralDelegate];
    NSAssert(bfPeripheralDelegate, @"The delegate of this peripheral is not managed by BlueFoundation.");
    
    bfPeripheralDelegate.completionQueue = bf_completionQueue;
}

#pragma mark -

- (void)bf_writeValue:(NSData *)data forCharacteristicUUIDString:(NSString *)characteristicUUIDString withNotify:(BFPeripheralDelegateWriteWithNotifyHandler)handler;
{
    BFPeripheralDelegate *bfPeripheralDelegate = [self getBlueFoundationPeripheralDelegate];
    NSAssert(bfPeripheralDelegate, @"The delegate of this peripheral is not managed by BlueFoundation.");

    bfPeripheralDelegate.writeWithNotifyHandler = handler;
    CBCharacteristic *characteristic = bfPeripheralDelegate.mutableCharacteristics[characteristicUUIDString.uppercaseString];
    if (characteristic) {
        CBCharacteristicWriteType writeType = [self getCharacteristicWriteType:characteristic];
        [self writeValue:data forCharacteristic:characteristic type:writeType];
    } else {
        dispatch_async(self.bf_completionQueue, ^{
            executeBlockIfExistsThenSetNil(bfPeripheralDelegate.writeWithNotifyHandler,
                                           nil, [BFError errorWithCode:BFErrorCodePeripheralNoSuchCharacteristic]);
        });
    }
}

- (void)bf_writeValue:(NSData *)data forCharacteristicUUIDString:(NSString *)characteristicUUIDString withoutNotify:(BFPeripheralDelegateWriteWithoutNotifyHandler)handler
{
    BFPeripheralDelegate *bfPeripheralDelegate = [self getBlueFoundationPeripheralDelegate];
    NSAssert(bfPeripheralDelegate, @"The delegate of this peripheral is not managed by BlueFoundation.");

    bfPeripheralDelegate.writeWithoutNotifyHandler = handler;
    CBCharacteristic *characteristic = bfPeripheralDelegate.mutableCharacteristics[characteristicUUIDString.uppercaseString];
    if (characteristic) {
        CBCharacteristicWriteType writeType = [self getCharacteristicWriteType:characteristic];
        [self writeValue:data forCharacteristic:characteristic type:writeType];
    } else {
        dispatch_async(self.bf_completionQueue, ^{
            executeBlockIfExistsThenSetNil(bfPeripheralDelegate.writeWithoutNotifyHandler,
                                           [BFError errorWithCode:BFErrorCodePeripheralNoSuchCharacteristic]);
        });
    }
}

- (void)bf_writeValue:(NSData *)data forCharacteristicUUIDString:(NSString *)writeCharacteristicUUIDString thenReadCharacteristicUUIDString:(NSString *)readCharacteristicUUIDString completion:(BFPeripheralDelegateWriteThenReadHandler)handler
{
    BFPeripheralDelegate *bfPeripheralDelegate = [self getBlueFoundationPeripheralDelegate];
    NSAssert(bfPeripheralDelegate, @"The delegate of this peripheral is not managed by BlueFoundation.");
    
    bfPeripheralDelegate.writeThenReadHandler = handler;
    CBCharacteristic *writeCharacteristic = bfPeripheralDelegate.mutableCharacteristics[writeCharacteristicUUIDString.uppercaseString];
    if (writeCharacteristic) {
        CBCharacteristicWriteType writeType = [self getCharacteristicWriteType:writeCharacteristic];
        bfPeripheralDelegate.state = BFPeripheralDelegateStateWriteThenReadInWriting;
        [self writeValue:data forCharacteristic:writeCharacteristic type:writeType];
    } else {
        dispatch_async(self.bf_completionQueue, ^{
            executeBlockIfExistsThenSetNil(bfPeripheralDelegate.writeThenReadHandler,
                                           nil, [BFError errorWithCode:BFErrorCodePeripheralNoSuchCharacteristic]);
        });
    }
}

- (void)bf_readValueForCharacteristicUUIDString:(NSString *)characteristicUUIDString completion:(BFPeripheralDelegateReadHandler)completion
{
    BFPeripheralDelegate *bfPeripheralDelegate = [self getBlueFoundationPeripheralDelegate];
    NSAssert(bfPeripheralDelegate, @"The delegate of this peripheral is not managed by BlueFoundation.");

    bfPeripheralDelegate.readHandler = completion;
    CBCharacteristic *charcteristic = bfPeripheralDelegate.mutableCharacteristics[characteristicUUIDString];
    if (charcteristic) {
        [self readValueForCharacteristic:charcteristic];
    } else {
        dispatch_async(self.bf_completionQueue, ^{
            executeBlockIfExistsThenSetNil(bfPeripheralDelegate.readHandler,
                                           nil, [BFError errorWithCode:BFErrorCodePeripheralNoSuchCharacteristic]);
        });
    }
}


- (void)bf_discoverServices:(nullable NSArray<CBUUID *> *)serviceUUIDs andCharacteristicsWithCompletion:(BFPeripheralDelegateDidDiscoverServicesAndCharacteristicsHandler)handler;
{
    if (self.state != CBPeripheralStateConnected) {
        dispatch_async(self.bf_completionQueue, ^{
            handler([BFError errorWithCode:BFErrorCodePeripheralDisconnected]);
        });
        return;
    }
    BFPeripheralDelegate *bfPeripheralDelegate = [self getBlueFoundationPeripheralDelegate];
    NSAssert(bfPeripheralDelegate, @"The delegate of this peripheral is not managed by BlueFoundation.");

    bfPeripheralDelegate.state = BFPeripheralDelegateStateDiscoveringServices;
    bfPeripheralDelegate.didDiscoverServicesAndCharacteriscitcsHandler = handler;
    
    [self discoverServices:serviceUUIDs];
}

- (void)bf_readRSSIWithCompletion:(BFPeripheralDelegateReadRSSIHandler)handler
{
    BFPeripheralDelegate *bfPeripheralDelegate = [self getBlueFoundationPeripheralDelegate];
    NSAssert(bfPeripheralDelegate, @"The delegate of this peripheral is not managed by BlueFoundation.");

    bfPeripheralDelegate.readRSSIHandler = handler;
    
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

- (CBCharacteristicWriteType)getCharacteristicWriteType:(nonnull CBCharacteristic *)characteristic
{
    if (characteristic.properties & CBCharacteristicPropertyWriteWithoutResponse) {
        return CBCharacteristicWriteWithoutResponse;
    } else {
        return CBCharacteristicWriteWithResponse;
    }
}

@end
