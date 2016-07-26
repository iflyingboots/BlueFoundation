//
//  ViewController.m
//  BlueFoundationExample
//
//  Created by Xin Wang on 7/25/16.
//  Copyright © 2016 Xin Wang. All rights reserved.
//

#import "ViewController.h"
#import <BlueFoundation/BlueFoundation.h>

@interface ViewController ()
@property (nonatomic, copy) CBPeripheral *peripheral;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    BFCentralManager *centralManager = [BFCentralManager manager];
    
    [centralManager scanForPeripheralsWithServices:@[]
                                           options:nil
                                        completion:^(CBPeripheral * _Nonnull peripheral, NSDictionary<NSString *,id> * _Nonnull advertisementData, NSNumber * _Nonnull RSSI, BOOL * _Nonnull connect, BOOL * _Nonnull stop) {
        
    }];
    
    [centralManager stateUpdated:^(CBCentralManager * _Nonnull centralManager, CBCentralManagerState state) {

    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
