//
//  NSString+BlueFoundation.h
//  BlueFoundation
//
//  Created by Xin Wang on 7/27/16.
//  Copyright © 2016 EtchingLab. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  <code>NSString (BlueFoundation)</code> category provides utilities, including a function that converts hex string to data.
 */
@interface NSString (BlueFoundation)

/**
 *  Get <code>NSData</code> from hex string.
 *
 *  @return NSData object or nil.
 */
- (nullable NSData *)bf_dataFromHexString;

@end
