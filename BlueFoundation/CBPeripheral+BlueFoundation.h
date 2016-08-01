//
//  CBPeripheral+BlueFoundation.h
//  BlueFoundation
//
//  Created by Xin Wang on 7/27/16.
//  Copyright © 2016 EtchingLab. All rights reserved.
//

#import "BFCentralManager.h"
#import "BFDefines.h"

@import CoreBluetooth;

NS_ASSUME_NONNULL_BEGIN

@interface CBPeripheral (BlueFoundation)

@property (nonatomic, strong, readonly, nullable) NSDictionary<NSString *, CBCharacteristic *> *bf_characteristics;
@property (nonatomic, strong, nullable) dispatch_queue_t bf_completionQueue;

- (void)bf_discoverServices:(nullable NSArray<CBUUID *> *)serviceUUIDs andCharacteristicsWithCompletion:(BFPeripheralDidDiscoverServicesAndCharacteristicsHandler)handler;

- (void)bf_readRSSIWithCompletion:(BFPeripheralReadRSSIHandler)handler;

- (void)bf_writeValue:(NSData *)data forCharacteristicUUIDString:(NSString *)characteristicUUIDString withNotify:(BFPeripheralWriteWithNotifyHandler)handler;

- (void)bf_writeValue:(NSData *)data forCharacteristicUUIDString:(NSString *)writeCharacteristicUUIDString withNotifyFromCharacteristicUUIDString:(NSString *)notifyCharacteristicUUIDString completion:(BFPeripheralWriteWithNotifyHandler)handler;

- (void)bf_writeValue:(NSData *)data forCharacteristicUUIDString:(NSString *)characteristicUUIDString withoutNotify:(BFPeripheralWriteWithoutNotifyHandler)handler;

- (void)bf_writeValue:(NSData *)data forCharacteristicUUIDString:(NSString *)writeCharacteristicUUIDString thenReadCharacteristicUUIDString:(NSString *)readCharacteristicUUIDString completion:(BFPeripheralWriteThenReadHandler)handler;

- (void)bf_readValueForCharacteristicUUIDString:(NSString *)characteristicUUIDString completion:(BFPeripheralReadHandler)completion;

@end

NS_ASSUME_NONNULL_END
