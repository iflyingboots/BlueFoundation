//
//  ViewController.m
//  BlueFoundationExample
//
//  Created by Xin Wang on 7/25/16.
//  Copyright © 2016 EtchingLab. All rights reserved.
//

#import "ViewController.h"
#import <BlueFoundation/BlueFoundation.h>

static NSString * const kDISUUID = @"0000180a-0000-1000-8000-00805f9b34fb";

@interface ViewController ()
@property (nonatomic, copy) CBPeripheral *peripheral;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    BFCentralManager *centralManager = [BFCentralManager manager];
    
    NSArray *connectedDevices = [centralManager
                                 retrieveConnectedPeripheralsWithServices:@[[CBUUID UUIDWithString:kDISUUID]]];
    
    NSLog(@"%@", connectedDevices);
    
    if (connectedDevices.count > 0)
    {
        self.peripheral = connectedDevices[0];
    }
    
    NSArray *services = @[[CBUUID UUIDWithString:kDISUUID]];
    
    NSString *charUUID = @"2A24";
    
    [centralManager connectPeripheral:self.peripheral options:nil completion:^(NSError * _Nullable error) {
        [self.peripheral bf_discoverServices:services andCharacteristicsWithCompletion:^(NSError * _Nullable error) {
            if (error) {
                NSLog(@"discover services error: %@", error);
            }
            [self.peripheral bf_readValueForCharacteristicUUIDString:charUUID completion:^(NSData * _Nullable response, NSError * _Nullable error) {
                NSString *responseString = [NSString stringWithUTF8String:[response bytes]];
                NSLog(@"read from %@, receive '%@', error: %@", charUUID, responseString, error);
            }];
        }];
    }];
    
    [self.peripheral bf_readRSSIWithCompletion:^(NSNumber *RSSI, NSError *error) {
        NSLog(@"RSSI: %@", RSSI);
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
