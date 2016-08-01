//
//  BFDefines.h
//  BlueFoundation
//
//  Created by Xin Wang on 8/1/16.
//  Copyright © 2016 EtchingLab. All rights reserved.
//

#ifndef BFDefines_h
#define BFDefines_h

NS_ASSUME_NONNULL_BEGIN

typedef void (^BFPeripheralDidDiscoverServicesAndCharacteristicsHandler)(NSError * _Nullable error);
typedef void (^BFPeripheralReadRSSIHandler)(NSNumber *RSSI, NSError * _Nullable error);
typedef void (^BFPeripheralWriteWithNotifyHandler)(NSData * _Nullable response, NSError * _Nullable error);
typedef void (^BFPeripheralWriteWithoutNotifyHandler)(NSError * _Nullable error);
typedef void (^BFPeripheralWriteThenReadHandler)(NSData * _Nullable response, NSError * _Nullable error);
typedef void (^BFPeripheralReadHandler)(NSData * _Nullable response, NSError * _Nullable error);

NS_ASSUME_NONNULL_END

#endif /* BFDefines_h */
