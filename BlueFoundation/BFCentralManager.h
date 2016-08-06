//
//  BFCentralManager.h
//  BlueFoundation
//
//  Created by Xin Wang on 7/25/16.
//  Copyright © 2016 EtchingLab. All rights reserved.
//

#import <Foundation/Foundation.h>

@import CoreBluetooth;

NS_ASSUME_NONNULL_BEGIN

typedef void (^BFCentralManagerScanCompletionHandler)(CBPeripheral *peripheral, NSDictionary<NSString *,id> *advertisementData, NSNumber *RSSI, BOOL *connectNeeded, BOOL *stopScan);
typedef void (^BFCentralManagerStateDidUpdateHandler)(CBCentralManagerState state);
typedef void (^BFCentralManagerConnectHandler)(NSError * _Nullable error);

/**
 *  `BFCentralManager` scans and connects peripherals, providing common APIs in `CBCentralManager` class.
 */
@interface BFCentralManager : NSObject

/**
 *  Creats and returns a `BFCentralManager` object.
 *
 *  @return `BFCentralManager` object or `nil`.
 */
+ (nullable instancetype)manager;

/**
 *  The dispatch queue for completion block. If `nil` (default), the main queue is used.
 */
@property (nonatomic, strong, nullable) dispatch_queue_t completionQueue;

/**
 *  Scan for peripherals with given serviceUUIDs.
 *
 *  @param serviceUUIDs An array of <code>CBUUID</code> objects that the app is interested in.
 *  @param options      An optional dictionary specifying options to customize the scan.
 *  @param handler      Completion handler.
 *  @see   scanForPeripheralsWithServices:options:
 */
- (void)scanForPeripheralsWithServices:(nullable NSArray<CBUUID *> *)serviceUUIDs options:(nullable NSDictionary<NSString *, id> *)options completion:(BFCentralManagerScanCompletionHandler)handler;

/**
 *  Retrive connected peripherals with given service UUIDs.
 *
 *  @param serviceUUIDs An array of <code>CBUUID</code> objects that the connected devices hold.
 *
 *  @return An array of connected peripherals, or `nil` if no such devices.
 */
- (nullable NSArray<CBPeripheral *> *)retrieveConnectedPeripheralsWithServices:(nullable NSArray<CBUUID *> *)serviceUUIDs;

/**
 *  Connect to a peripheral with options.
 *
 *  @param peripheral   The peripheral needs to be connected.
 *  @param options      An optional connection options.
 *  @param handler      A block object that will be called after completion.
 *
 *  @see            CBConnectPeripheralOptionNotifyOnConnectionKey
 *  @see            CBConnectPeripheralOptionNotifyOnDisconnectionKey
 *  @see            CBConnectPeripheralOptionNotifyOnNotificationKey
 */
- (void)connectPeripheral:(CBPeripheral *)peripheral options:(nullable NSDictionary<NSString *,id> *)options completion:(BFCentralManagerConnectHandler)handler;

/**
 *  Central manager state updates.
 *
 *  @param handler A block object that will be called when state updates.
 */
- (void)stateUpdated:(BFCentralManagerStateDidUpdateHandler)handler;

@end

NS_ASSUME_NONNULL_END
