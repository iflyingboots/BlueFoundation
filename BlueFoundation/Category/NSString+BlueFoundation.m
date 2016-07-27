//
//  NSString+BlueFoundation.m
//  BlueFoundation
//
//  Created by Xin Wang on 7/27/16.
//  Copyright © 2016 EtchingLab. All rights reserved.
//

#import "NSString+BlueFoundation.h"

@implementation NSString (BlueFoundation)

- (nullable NSData *)dataFromHexString
{
    if (self.length % 2 != 0) return nil;
    
    NSMutableData *commandToSend= [[NSMutableData alloc] init];
    
    unsigned char whole_byte;
    char byte_chars[3] = {'\0','\0','\0'};
    
    for (int i = 0; i < self.length / 2; i++) {
        byte_chars[0] = [self characterAtIndex:i * 2];
        byte_chars[1] = [self characterAtIndex:i * 2 + 1];
        whole_byte = strtol(byte_chars, NULL, 16);
        [commandToSend appendBytes:&whole_byte length:1];
    }
    
    return [commandToSend copy];
}

@end
