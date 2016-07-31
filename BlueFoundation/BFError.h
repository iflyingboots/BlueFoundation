//
//  BFError.h
//  BlueFoundation
//
//  Created by Xin Wang on 7/30/16.
//  Copyright © 2016 EtchingLab. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(uint8_t, BFErrorCode) {
    BFErrorCodeDefault = 0,
    BFErrorCodePeripheralDisconnected,
    BFErrorCodePeripheralNoServiceDiscovered,
    BFErrorCodePeripheralNoSuchCharacteristic,
    BFErrorCodePeripheralBusy,
};

@interface BFError : NSError

+ (NSError *)errorWithCode:(BFErrorCode)code;

@end
