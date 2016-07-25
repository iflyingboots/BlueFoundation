//
//  BFCentralManager.h
//  BlueFoundation
//
//  Created by Xin Wang on 7/25/16.
//  Copyright © 2016 Xin Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CBPeripheral;

@interface BFCentralManager : NSObject

+ (instancetype)sharedManager;

@end
