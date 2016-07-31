//
//  BFPeripheralDelegate.h
//  BlueFoundation
//
//  Created by Xin Wang on 7/27/16.
//  Copyright © 2016 EtchingLab. All rights reserved.
//

#import <Foundation/Foundation.h>

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

typedef void (^BFPeripheralDelegateConnectHandler)(NSError * _Nullable error);
typedef void (^BFPeripheralDelegateDidDiscoverServicesAndCharacteristicsHandler)(NSError * _Nullable error);
typedef void (^BFPeripheralDelegateReadRSSIHandler)(NSNumber *RSSI, NSError * _Nullable error);
typedef void (^BFPeripheralDelegateWriteWithNotifyHandler)(NSData * _Nullable response, NSError * _Nullable error);
typedef void (^BFPeripheralDelegateWriteWithoutNotifyHandler)(NSError * _Nullable error);
typedef void (^BFPeripheralDelegateWriteThenReadHandler)(NSData * _Nullable response, NSError * _Nullable error);
typedef void (^BFPeripheralDelegateReadHandler)(NSData * _Nullable response, NSError * _Nullable error);

@interface BFPeripheralDelegate : NSObject <CBPeripheralDelegate>

@property (nonatomic, weak, nullable) BFPeripheralManager *manager;
@property (nonatomic, strong, nullable) NSMutableDictionary<NSString *, CBCharacteristic *> *mutableCharacteristics;

@property (nonatomic, assign) BFPeripheralDelegateState state;
@property (nonatomic, strong, nullable) dispatch_queue_t completionQueue;

// callbacks
@property (nonatomic, copy, nullable) BFPeripheralDelegateDidDiscoverServicesAndCharacteristicsHandler didDiscoverServicesAndCharacteriscitcsHandler;
@property (nonatomic, copy, nullable) BFPeripheralDelegateReadRSSIHandler readRSSIHandler;

@property (nonatomic, copy, nullable) BFPeripheralDelegateWriteWithNotifyHandler writeWithNotifyHandler;
@property (nonatomic, copy, nullable) BFPeripheralDelegateWriteWithoutNotifyHandler writeWithoutNotifyHandler;
@property (nonatomic, copy, nullable) BFPeripheralDelegateWriteThenReadHandler writeThenReadHandler;
@property (nonatomic, copy, nullable) BFPeripheralDelegateReadHandler readHandler;

- (void)setWriteWithNotifyHandler:(BFPeripheralDelegateWriteWithNotifyHandler _Nullable)writeWithNotifyHandler writeCharacteristicUUIDString:(NSString * _Nonnull)writeCharacteristicUUIDString notifyCharacteristicUUIDString:(NSString * _Nonnull)notifyCharacteristicUUIDString;

- (void)setWriteWithoutNotifyHandler:(BFPeripheralDelegateWriteWithoutNotifyHandler _Nullable)writeWithoutNotifyHandler writeCharacteristicUUIDString:(NSString * _Nonnull)writeCharacteristicUUIDString;

- (void)setWriteThenReadHandler:(BFPeripheralDelegateWriteThenReadHandler _Nullable)writeThenReadHandler writeCharacteristicUUIDString:(NSString * _Nonnull)writeCharacteristicUUIDString readCharacteristicUUIDString:(NSString * _Nonnull)readCharacteristicUUIDString;

- (void)setReadHandler:(BFPeripheralDelegateReadHandler _Nullable)readHandler readCharacteristicUUIDString:(NSString * _Nonnull)readCharacteristicUUIDString;

@end

NS_ASSUME_NONNULL_END
