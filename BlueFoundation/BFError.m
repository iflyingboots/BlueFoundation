//
//  BFError.m
//  BlueFoundation
//
//  Created by Xin Wang on 7/30/16.
//  Copyright © 2016 EtchingLab. All rights reserved.
//

#import "BFError.h"

static NSString *const kBlueFoundationErrorDomain = @"com.etchinglab.bluefoundation";

@implementation BFError

+ (NSError *)errorWithCode:(BFErrorCode)code
{
    static dispatch_once_t onceToken;
    static NSBundle *resourcesBundle = nil;
    dispatch_once(&onceToken, ^{
        NSURL *url = [[NSBundle bundleForClass:[self class]] URLForResource:@"BlueFoundation" withExtension:@"bundle"];
        resourcesBundle = [NSBundle bundleWithURL:url];
    });
    
    NSString *message = nil;
    
    switch (code) {
        case BFErrorCodeDefault: {
            message = NSLocalizedStringFromTableInBundle(@"Default error, nobody knows why.", @"BlueFoundation", resourcesBundle, nil);
            break;
        }
        case BFErrorCodePeripheralDisconnected: {
            message = NSLocalizedStringFromTableInBundle(@"Peripheral is disconnected.", @"BlueFoundation", resourcesBundle, nil);
            break;
        }
        case BFErrorCodePeripheralBusy: {
            message = NSLocalizedStringFromTableInBundle(@"Peripheral is busy.", @"BlueFoundation", resourcesBundle, nil);
            break;
        }
        case BFErrorCodePeripheralNoServiceDiscovered: {
            message = NSLocalizedStringFromTableInBundle(@"Peripheral has no service.", @"BlueFoundation", resourcesBundle, nil);
            break;
        }
        case BFErrorCodePeripheralNoSuchCharacteristic: {
            message = NSLocalizedStringFromTableInBundle(@"Peripheral has no such characteristic.", @"BlueFoundation", resourcesBundle, nil);
            break;
        }
    }

    NSDictionary *userInfo = nil;
    if (message) {
        userInfo = @{NSLocalizedDescriptionKey: message};
    }
    
    return [NSError errorWithDomain:kBlueFoundationErrorDomain code:code userInfo:userInfo];
}

@end
