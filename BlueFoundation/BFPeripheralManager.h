//
//  BFPeripheralManager.h
//  BlueFoundation
//
//  Created by Xin Wang on 7/26/16.
//  Copyright © 2016 Xin Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BFPeripheralManager : NSObject

+ (instancetype)manager;

- (void)addPeripheral:(CBPeripheral *)peripheral;

@end
