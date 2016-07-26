//
//  BFCentralManager.h
//  BlueFoundation
//
//  Created by Xin Wang on 7/25/16.
//  Copyright © 2016 Xin Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@import CoreBluetooth;

NS_ASSUME_NONNULL_BEGIN

typedef void (^BFCentralManagerScanCompletionHandler)(CBPeripheral *peripheral, NSDictionary<NSString *,id> *advertisementData, NSNumber *RSSI, BOOL *connectNeeded, BOOL *stopScan);
typedef void (^BFCentralManagerStateUpdateHandler)(CBCentralManager *centralManager, CBCentralManagerState state);

@interface BFCentralManager : NSObject

+ (instancetype)manager;

@property (nonatomic, strong, nullable) dispatch_queue_t completionQueue;

- (void)scanForPeripheralsWithServices:(nullable NSArray<CBUUID *> *)serviceUUIDs options:(nullable NSDictionary<NSString *, id> *)options completion:(BFCentralManagerScanCompletionHandler)handler;


- (void)stateUpdated:(BFCentralManagerStateUpdateHandler)handler;

@end

NS_ASSUME_NONNULL_END
