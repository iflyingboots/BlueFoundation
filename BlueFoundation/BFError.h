//
//  BFError.h
//  BlueFoundation
//
//  Created by Xin Wang on 7/30/16.
//  Copyright © 2016 EtchingLab. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  BlueFoundation error code.
 */
typedef NS_ENUM(uint8_t, BFErrorCode) {
    /**
     *  Default error.
     */
    BFErrorCodeDefault = 0,
    /**
     *  Peripheral is disconnected.
     */
    BFErrorCodePeripheralDisconnected,
    /**
     *  Peripheral has no discovered service.
     */
    BFErrorCodePeripheralNoServiceDiscovered,
    /**
     *  Peripheral has no such characteristic.
     */
    BFErrorCodePeripheralNoSuchCharacteristic,
    /**
     *  Peripheral is busy.
     */
    BFErrorCodePeripheralBusy,
};

@interface BFError : NSError

+ (NSError *)errorWithCode:(BFErrorCode)code;

@end
