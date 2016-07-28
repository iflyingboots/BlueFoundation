//
//  BFPeripheralManager.h
//  BlueFoundation
//
//  Created by Xin Wang on 7/26/16.
//  Copyright © 2016 EtchingLab. All rights reserved.
//

#import <Foundation/Foundation.h>

@import CoreBluetooth;

NS_ASSUME_NONNULL_BEGIN

@interface BFPeripheralManager : NSObject

+ (nullable instancetype)manager;

- (void)addPeripheral:(CBPeripheral *)peripheral;

@end

NS_ASSUME_NONNULL_END
