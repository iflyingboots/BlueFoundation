//
//  BFPeripheralDelegate.h
//  BlueFoundation
//
//  Created by Xin Wang on 7/27/16.
//  Copyright © 2016 EtchingLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BFDefines.h"

@import CoreBluetooth;

@class BFPeripheralManager;

typedef NS_ENUM(uint8_t, BFPeripheralDelegateState) {
    BFPeripheralDelegateStateIdle = 0,
    BFPeripheralDelegateStateConnected,
    BFPeripheralDelegateStateDiscoveringServices,
    BFPeripheralDelegateStateDiscoveringCharacteristics,
    BFPeripheralDelegateStateReady,
    BFPeripheralDelegateStateWriteWithNotify,
    BFPeripheralDelegateStateWriteWithoutNotify,
    BFPeripheralDelegateStateWriteThenRead,
    BFPeripheralDelegateStateWriteThenReadInWriting,     // sub state of WriteThenRead
    BFPeripheralDelegateStateWriteThenReadInReading,     // sub state of WriteThenRead
    BFPeripheralDelegateStateRead,
};

NS_ASSUME_NONNULL_BEGIN

@interface BFPeripheralDelegate : NSObject <CBPeripheralDelegate>

@property (nonatomic, weak, nullable) BFPeripheralManager *manager;
@property (nonatomic, strong, nullable) NSMutableDictionary<NSString *, CBCharacteristic *> *mutableCharacteristics;

@property (nonatomic, assign) BFPeripheralDelegateState state;
@property (nonatomic, strong, nullable) dispatch_queue_t completionQueue;

// callbacks
@property (nonatomic, copy, nullable) BFPeripheralDidDiscoverServicesAndCharacteristicsHandler didDiscoverServicesAndCharacteriscitcsHandler;
@property (nonatomic, copy, nullable) BFPeripheralReadRSSIHandler readRSSIHandler;

@property (nonatomic, copy, nullable) BFPeripheralWriteWithNotifyHandler writeWithNotifyHandler;
@property (nonatomic, copy, nullable) BFPeripheralWriteWithoutNotifyHandler writeWithoutNotifyHandler;
@property (nonatomic, copy, nullable) BFPeripheralWriteThenReadHandler writeThenReadHandler;
@property (nonatomic, copy, nullable) BFPeripheralReadHandler readHandler;

- (void)setWriteWithNotifyHandler:(BFPeripheralWriteWithNotifyHandler _Nullable)writeWithNotifyHandler writeCharacteristicUUIDString:(NSString * _Nonnull)writeCharacteristicUUIDString notifyCharacteristicUUIDString:(NSString * _Nonnull)notifyCharacteristicUUIDString;

- (void)setWriteWithoutNotifyHandler:(BFPeripheralWriteWithoutNotifyHandler _Nullable)writeWithoutNotifyHandler writeCharacteristicUUIDString:(NSString * _Nonnull)writeCharacteristicUUIDString;

- (void)setWriteThenReadHandler:(BFPeripheralWriteThenReadHandler _Nullable)writeThenReadHandler writeCharacteristicUUIDString:(NSString * _Nonnull)writeCharacteristicUUIDString readCharacteristicUUIDString:(NSString * _Nonnull)readCharacteristicUUIDString;

- (void)setReadHandler:(BFPeripheralReadHandler _Nullable)readHandler readCharacteristicUUIDString:(NSString * _Nonnull)readCharacteristicUUIDString;

@end

NS_ASSUME_NONNULL_END
