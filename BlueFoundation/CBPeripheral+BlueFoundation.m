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
    [self bf_writeValue:data forCharacteristicUUIDString:characteristicUUIDString withNotifyFromCharacteristicUUIDString:characteristicUUIDString completion:handler];
}

- (void)bf_writeValue:(NSData *)data forCharacteristicUUIDString:(NSString *)writeCharacteristicUUIDString withNotifyFromCharacteristicUUIDString:(NSString *)notifyCharacteristicUUIDString completion:(BFPeripheralDelegateWriteWithNotifyHandler)handler
{
    BFPeripheralDelegate *bfPeripheralDelegate = [self getBlueFoundationPeripheralDelegate];
    NSAssert(bfPeripheralDelegate, @"The delegate of this peripheral is not managed by BlueFoundation.");
    
    
    CBCharacteristic *writeCharacteristic = bfPeripheralDelegate.mutableCharacteristics[writeCharacteristicUUIDString.uppercaseString];
    CBCharacteristic *notifyCharacteristic = bfPeripheralDelegate.mutableCharacteristics[notifyCharacteristicUUIDString.uppercaseString];
    
    if (!writeCharacteristic || !notifyCharacteristic) {
        dispatch_async(self.bf_completionQueue, ^{
            executeBlockIfExistsThenSetNil(bfPeripheralDelegate.writeWithNotifyHandler,
                                           nil, [BFError errorWithCode:BFErrorCodePeripheralNoSuchCharacteristic]);
        });
        return;
    }

    [bfPeripheralDelegate setWriteWithNotifyHandler:handler
                      writeCharacteristicUUIDString:writeCharacteristicUUIDString
                     notifyCharacteristicUUIDString:notifyCharacteristicUUIDString];

    CBCharacteristicWriteType writeType = [self getCharacteristicWriteType:writeCharacteristic];
    [self writeValue:data forCharacteristic:writeCharacteristic type:writeType];
    
}

- (void)bf_writeValue:(NSData *)data forCharacteristicUUIDString:(NSString *)characteristicUUIDString withoutNotify:(BFPeripheralDelegateWriteWithoutNotifyHandler)handler
{
    BFPeripheralDelegate *bfPeripheralDelegate = [self getBlueFoundationPeripheralDelegate];
    NSAssert(bfPeripheralDelegate, @"The delegate of this peripheral is not managed by BlueFoundation.");

    bfPeripheralDelegate.writeWithoutNotifyHandler = handler;
    CBCharacteristic *writeCharacteristic = bfPeripheralDelegate.mutableCharacteristics[characteristicUUIDString.uppercaseString];

    if (!writeCharacteristic) {
        dispatch_async(self.bf_completionQueue, ^{
            executeBlockIfExistsThenSetNil(bfPeripheralDelegate.writeWithoutNotifyHandler,
                                           [BFError errorWithCode:BFErrorCodePeripheralNoSuchCharacteristic]);
        });
        return;
    }

    [bfPeripheralDelegate setWriteWithoutNotifyHandler:handler
                         writeCharacteristicUUIDString:characteristicUUIDString];

    CBCharacteristicWriteType writeType = [self getCharacteristicWriteType:writeCharacteristic];
    [self writeValue:data forCharacteristic:writeCharacteristic type:writeType];
}

- (void)bf_writeValue:(NSData *)data forCharacteristicUUIDString:(NSString *)writeCharacteristicUUIDString thenReadCharacteristicUUIDString:(NSString *)readCharacteristicUUIDString completion:(BFPeripheralDelegateWriteThenReadHandler)handler
{
    BFPeripheralDelegate *bfPeripheralDelegate = [self getBlueFoundationPeripheralDelegate];
    NSAssert(bfPeripheralDelegate, @"The delegate of this peripheral is not managed by BlueFoundation.");
    
    bfPeripheralDelegate.writeThenReadHandler = handler;
    CBCharacteristic *writeCharacteristic = bfPeripheralDelegate.mutableCharacteristics[writeCharacteristicUUIDString.uppercaseString];
    CBCharacteristic *readCharacteristic = bfPeripheralDelegate.mutableCharacteristics[readCharacteristicUUIDString.uppercaseString];

    if (!writeCharacteristic || !readCharacteristic) {
        dispatch_async(self.bf_completionQueue, ^{
            executeBlockIfExistsThenSetNil(bfPeripheralDelegate.writeThenReadHandler,
                                           nil, [BFError errorWithCode:BFErrorCodePeripheralNoSuchCharacteristic]);
        });
        return;
    }

    [bfPeripheralDelegate setWriteThenReadHandler:handler
                    writeCharacteristicUUIDString:writeCharacteristicUUIDString
                     readCharacteristicUUIDString:readCharacteristicUUIDString];
    
    CBCharacteristicWriteType writeType = [self getCharacteristicWriteType:writeCharacteristic];
    bfPeripheralDelegate.state = BFPeripheralDelegateStateWriteThenReadInWriting;
    [self writeValue:data forCharacteristic:writeCharacteristic type:writeType];
}

- (void)bf_readValueForCharacteristicUUIDString:(NSString *)characteristicUUIDString completion:(BFPeripheralDelegateReadHandler)handler
{
    BFPeripheralDelegate *bfPeripheralDelegate = [self getBlueFoundationPeripheralDelegate];
    NSAssert(bfPeripheralDelegate, @"The delegate of this peripheral is not managed by BlueFoundation.");

    CBCharacteristic *readCharcteristic = bfPeripheralDelegate.mutableCharacteristics[characteristicUUIDString.uppercaseString];
    
    if (!readCharcteristic) {
        dispatch_async(self.bf_completionQueue, ^{
            executeBlockIfExistsThenSetNil(bfPeripheralDelegate.readHandler,
                                           nil, [BFError errorWithCode:BFErrorCodePeripheralNoSuchCharacteristic]);
        });
        return;
    }
    
    [bfPeripheralDelegate setReadHandler:handler
            readCharacteristicUUIDString:characteristicUUIDString];
    
    [self readValueForCharacteristic:readCharcteristic];
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
