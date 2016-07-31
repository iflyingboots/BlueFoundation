//
//  BFPeripheralManager.m
//  BlueFoundation
//
//  Created by Xin Wang on 7/26/16.
//  Copyright © 2016 EtchingLab. All rights reserved.
//

#import "BFPeripheralManager.h"
#import "BFPeripheralDelegate.h"
#import "BFUtilities.h"

@interface BFPeripheralManager ()
@property (nonatomic, strong) NSLock *lock;
@property (nonatomic, strong) NSMutableDictionary<NSString *, BFPeripheralDelegate *> *mutableKeyedPeripheralDelegates;
@end

@implementation BFPeripheralManager

- (nullable instancetype)init
{
    self = [super init];
    if (!self) return nil;
    
    self.lock = [[NSLock alloc] init];
    self.mutableKeyedPeripheralDelegates = [[NSMutableDictionary alloc] init];
    
    return self;
}

+ (nullable instancetype)manager
{
    static BFPeripheralManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[BFPeripheralManager alloc] init];
    });
    
    return _sharedManager;
}

- (void)addPeripheral:(CBPeripheral *)peripheral
{
    BFPeripheralDelegate *delegate = [[BFPeripheralDelegate alloc] init];
    delegate.manager = self;
    peripheral.delegate = delegate;
    [self.lock lock];
    self.mutableKeyedPeripheralDelegates[peripheral.identifier.UUIDString.uppercaseString] = delegate;
    [self.lock unlock];
}

- (void)removePeripheral:(CBPeripheral *)peripheral
{
    [self.lock lock];
    BFPeripheralDelegate *peripheralDelegate = self.mutableKeyedPeripheralDelegates[peripheral.identifier.UUIDString.uppercaseString];
    [self.lock unlock];
    if (peripheralDelegate) {
        peripheral.delegate = nil;
        [self.lock lock];
        [self.mutableKeyedPeripheralDelegates removeObjectForKey:peripheral.identifier.UUIDString.uppercaseString];
        [self.lock unlock];
        peripheralDelegate = nil;
    }
}

- (nullable BFPeripheralDelegate *)getDelegateWithPeripheal:(CBPeripheral *)peripheral
{
    [self.lock lock];
    BFPeripheralDelegate *delegate = self.mutableKeyedPeripheralDelegates[peripheral.identifier.UUIDString.uppercaseString];
    [self.lock unlock];
    return delegate;
}

@end
