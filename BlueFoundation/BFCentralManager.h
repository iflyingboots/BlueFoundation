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

@interface BFCentralManager : NSObject

+ (nullable instancetype)manager;

@property (nonatomic, strong, nullable) dispatch_queue_t completionQueue;

- (void)scanForPeripheralsWithServices:(nullable NSArray<CBUUID *> *)serviceUUIDs options:(nullable NSDictionary<NSString *, id> *)options completion:(BFCentralManagerScanCompletionHandler)handler;

- (nullable NSArray<CBPeripheral *> *)retrieveConnectedPeripheralsWithServices:(nullable NSArray<CBUUID *> *)serviceUUIDs;

- (void)connectPeripheral:(CBPeripheral *)peripheral options:(nullable NSDictionary<NSString *,id> *)options;

- (void)stateUpdated:(BFCentralManagerStateDidUpdateHandler)handler;

@end

NS_ASSUME_NONNULL_END
