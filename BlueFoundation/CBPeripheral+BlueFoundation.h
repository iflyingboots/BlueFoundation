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

/**
 *  <code>CBPeripheral (BlueFoundation)</code> category provides convenient APIs for Bluetooth operations.
 */
@interface CBPeripheral (BlueFoundation)

/**
 *  Peripheral's discovered chacateristes.
 */
@property (nonatomic, strong, readonly, nullable) NSDictionary<NSString *, CBCharacteristic *> *bf_characteristics;

/**
 *  A dispatch queue that completion where peripheral's operation blocks will be executed, default is main queue.
 */
@property (nonatomic, strong, nullable) dispatch_queue_t bf_completionQueue;

/**
 *  Discover services with serviceUUIDs and characteristics.
 *
 *  @param serviceUUIDs An array of serviceUUIDs.
 *  @param handler      A block object will be called after completion.
 */
- (void)bf_discoverServices:(nullable NSArray<CBUUID *> *)serviceUUIDs andCharacteristicsWithCompletion:(BFPeripheralDidDiscoverServicesAndCharacteristicsHandler)handler;

/**
 *  Read peripheral's RSSI.
 *
 *  @param handler A block object will be called after completion.
 */
- (void)bf_readRSSIWithCompletion:(BFPeripheralReadRSSIHandler)handler;

/**
 *  Write value for characteristic, then wait for notification from the same characteristic.
 *
 *  @param data                     Data to write.
 *  @param characteristicUUIDString Characteristic UUID string, case insensitive.
 *  @param handler                  A block object will be called after receiving notifaction from the characteristic.
 */
- (void)bf_writeValue:(NSData *)data forCharacteristicUUIDString:(NSString *)characteristicUUIDString withNotify:(BFPeripheralWriteWithNotifyHandler)handler;

/**
 *  Write value for characteristic, then wait for notification from another characteristic.
 *
 *  @param data                           Data to write.
 *  @param writeCharacteristicUUIDString  The characteristic UUID string for writing, case insensitive.
 *  @param notifyCharacteristicUUIDString The characteristic UUID string for receiving notification, case insensitive.
 *  @param handler                        A block object will be called after receiving notifaction from the characteristic.
 */
- (void)bf_writeValue:(NSData *)data forCharacteristicUUIDString:(NSString *)writeCharacteristicUUIDString withNotifyFromCharacteristicUUIDString:(NSString *)notifyCharacteristicUUIDString completion:(BFPeripheralWriteWithNotifyHandler)handler;

/**
 *  Write value for characteristic, without notification to be received.
 *
 *  @param data                     Data to write.
 *  @param characteristicUUIDString The characteristic UUID string for writing, case insensitive.
 *  @param handler                  A block object will be called after writing to the characteristic.
 */
- (void)bf_writeValue:(NSData *)data forCharacteristicUUIDString:(NSString *)characteristicUUIDString withoutNotify:(BFPeripheralWriteWithoutNotifyHandler)handler;

/**
 *  Write value for characteristic, then read value for characteristic.
 *
 *  @param data                          Data to write.
 *  @param writeCharacteristicUUIDString The characteristic UUID string for writing, case insensitive.
 *  @param readCharacteristicUUIDString  The characteristic UUID string for reading, case insensitive.
 *  @param handler                       A block object will be called after completion.
 */
- (void)bf_writeValue:(NSData *)data forCharacteristicUUIDString:(NSString *)writeCharacteristicUUIDString thenReadCharacteristicUUIDString:(NSString *)readCharacteristicUUIDString completion:(BFPeripheralWriteThenReadHandler)handler;

/**
 *  Read value for characteristic.
 *
 *  @param characteristicUUIDString The characteristic UUID string for reading, case insensitive.
 *  @param completion               A block object will be called after completion.
 */
- (void)bf_readValueForCharacteristicUUIDString:(NSString *)characteristicUUIDString completion:(BFPeripheralReadHandler)completion;

@end

NS_ASSUME_NONNULL_END
