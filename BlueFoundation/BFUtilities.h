//
//  BFUtilities.h
//  BlueFoundation
//
//  Created by Xin Wang on 7/28/16.
//  Copyright © 2016 EtchingLab. All rights reserved.
//

#ifndef BFUtilities_h
#define BFUtilities_h

#if DEBUG
#define BFLog(content, ... ) NSLog( @"<%@:(%d)> %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(content), ##__VA_ARGS__] )
#else
#define BFLog(content, ... ) do{} while(0)
#endif

#define executeBlockIfExistsThenSetNil(blk, ...) do { \
if (blk) { blk(__VA_ARGS__); blk = nil;}; \
} while (0)

#endif /* BFUtilities_h */
