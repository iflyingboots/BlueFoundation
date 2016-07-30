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
            message = NSLocalizedStringFromTableInBundle(@"errDefault", @"BlueFoundation", resourcesBundle, nil);
            break;
        }
        case BFErrorCodeNotConnected: {
            message = NSLocalizedStringFromTableInBundle(@"errPeripheralNotConnected", @"BlueFoundation", resourcesBundle, nil);
            break;
        }
        case BFErrorCodePeripheralBusy: {
            message = NSLocalizedStringFromTableInBundle(@"errPeripheralBusy", @"BlueFoundation", resourcesBundle, nil);
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
