//
//  CBPeripheral+BlueFoundation.h
//  BlueFoundation
//
//  Created by Xin Wang on 7/27/16.
//  Copyright © 2016 EtchingLab. All rights reserved.
//

#import "BFCentralManager.h"
#import "BFPeripheralDelegate.h"

@import CoreBluetooth;

NS_ASSUME_NONNULL_BEGIN

@interface CBPeripheral (BlueFoundation)

@property (nonatomic, strong, readonly, nullable) NSDictionary<NSString *, CBCharacteristic *> *bf_characteristics;
@property (nonatomic, strong, nullable) dispatch_queue_t bf_completionQueue;

- (void)bf_discoverServices:(nullable NSArray<CBUUID *> *)serviceUUIDs andCharacteristicsWithCompletion:(BFPeripheralDelegateDidDiscoverServicesAndCharacteristicsHandler)handler;

- (void)bf_readRSSIWithHandler:(BFPeripheralDelegateReadRSSIHandler)handler;

- (void)bf_writeValue:(NSData *)data forCharacteristicUUIDString:(NSString *)characteristicUUIDString withNotify:(BFPeripheralDelegateWriteWithNotifyHandler)handler;

- (void)bf_writeValue:(NSData *)data forCharacteristicUUIDString:(NSString *)characteristicUUIDString withoutNotify:(BFPeripheralDelegateWriteWithoutNotifyHandler)handler;

- (void)bf_writeValue:(NSData *)data forCharacteristicUUIDString:(NSString *)writeCharacteristicUUIDString thenReadCharacteristicUUIDString:(NSString *)readCharacteristicUUIDString completion:(BFPeripheralDelegateWriteThenReadHandler)handler;

- (void)bf_readValueForCharacteristicUUIDString:(NSString *)characteristicUUIDString completion:(BFPeripheralDelegateReadHandler)completion;

@end

NS_ASSUME_NONNULL_END
