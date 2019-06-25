//
//  AppDelegate.m
//  test
//
//  Created by 洪 権 on 2019/06/20.
//  Copyright © 2019 洪 権. All rights reserved.
//

#import "AppDelegate.h"
#import "Define.h"
#import "NCDataObject.h"

@implementation AppDelegate{
    CBCentralManager    *_manager;
    CBPeripheral        *_np;

    CBCharacteristic    *_ds;
    CBCharacteristic    *_cp;
    CBCharacteristic    *_ns;

    NSMutableData       *_dsDataCache;
    CBCharacteristic    *_controlChar;
    NSTimer             *_delayTimer;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    _manager = [[CBCentralManager alloc]initWithDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    [NSUserNotificationCenter defaultUserNotificationCenter].delegate = self;
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    [_manager cancelPeripheralConnection:_np];
}

- (void)startScan{
    NSLog(@"Called startScan()");
    [_manager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:@"C70CB8F3-BB87-4412-B2D4-A90702ABDA0F"]] options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : [NSNumber numberWithBool:YES] }];
}

- (NSData *)buildCommandForGettingNotificationWithUID:(NSData *)uidData Attributes:(NSArray *)reqAttr{
    NSMutableData *data = [[NSMutableData alloc]initWithBytes:"\x00" length:1];
    [data appendData:uidData];
    for (NSDictionary *dict in reqAttr) {
        [data appendData:[dict objectForKey:@"action"]];
        if ([dict objectForKey:@"length"]) {
            [data appendData:[dict objectForKey:@"length"]];
        }
    }
    NSLog(@"%@",data);
    return data;
}

- (void)processNotificationUpdateData:(NSData *)data {
    NSUInteger len = [data length];
    Byte *byteData = (Byte*)malloc(len);
    memcpy(byteData, [data bytes], len);
    switch (byteData[0]) {
        case EventIDNotificationAdded:
        {
            NSLog(@"Event Added");
            NSArray *cmdArray = @[@{@"action": [NSData dataWithBytes:"\x00" length:1]},
                                  @{@"action": [NSData dataWithBytes:"\x01" length:1],@"length":[NSData dataWithBytes:"\xFF\xFF" length:2]},
                                  @{@"action": [NSData dataWithBytes:"\x02" length:1],@"length":[NSData dataWithBytes:"\xFF\xFF" length:2]},
                                  @{@"action": [NSData dataWithBytes:"\x03" length:1],@"length":[NSData dataWithBytes:"\xFF\xFF" length:2]}];

            [_np writeValue:[self buildCommandForGettingNotificationWithUID:[data subdataWithRange:NSMakeRange(4, 4)] Attributes:cmdArray] forCharacteristic:_cp type:CBCharacteristicWriteWithResponse];
        }
            break;

        case EventIDNotificationModified:
            NSLog(@"Event Modified");
            break;

        case EventIDNotificationRemoved:
            NSLog(@"Event Removed");
            break;

        default:
            NSLog(@"Unknown Event:%i",byteData[0]);
            break;
    }
}

- (void)processDataSource:(NSData *)data {
    if (![[data subdataWithRange:NSMakeRange(0, 1)]isEqualToData:[NSData dataWithBytes:"\x00" length:1]] && _dsDataCache) {
        [_dsDataCache appendData:data];
    }else{
        _dsDataCache = [data mutableCopy];
    }
    if (data.length == 20) {
        if (_delayTimer) {
            [_delayTimer invalidate];
            _delayTimer = nil;
        }
        _delayTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(finalizeDataSourceReply) userInfo:nil repeats:NO];
    }else{
        [self finalizeDataSourceReply];
    }
}

- (void)finalizeDataSourceReply {
    if (_delayTimer) {
        [_delayTimer invalidate];
        _delayTimer = nil;
    }
    NSLog(@"%@",_dsDataCache);

    NSData *uid = [_dsDataCache subdataWithRange:NSMakeRange(1, 4)];
    NSData *messageData = [_dsDataCache subdataWithRange:NSMakeRange(5, [_dsDataCache length]-5)];
    NSInteger currentIndex = 0;
    NSUInteger len = [messageData length];
    Byte *byteData = (Byte*)malloc(len);
    memcpy(byteData, [messageData bytes], len);
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    while (currentIndex < messageData.length) {
        int messageLength = byteData[currentIndex+1];
        NCDataObject *dataObject = [[NCDataObject alloc]initWithUID:uid Type:byteData[currentIndex+0] data:[messageData subdataWithRange:NSMakeRange(currentIndex+3, messageLength)]];
        NSLog(@"%@",[dataObject description]);
        if (dataObject.type == 1) {
            [dict setObject:dataObject forKey:@"app"];
        }
        if (dataObject.type == 3) {
            [dict setObject:dataObject forKey:@"message"];
        }
        currentIndex = currentIndex + 3 + messageLength;
    }
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = [(NCDataObject *)[dict objectForKey:@"app"] data];
    notification.informativeText = [(NCDataObject *)[dict objectForKey:@"message"] data];
    notification.soundName = NSUserNotificationDefaultSoundName;
    //notification.hasActionButton = YES;
    //notification.hasReplyButton = YES;

    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
}

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification {
    if (notification.activationType == NSUserNotificationActivationTypeReplied){
        NSString* userResponse = notification.response.string;
        NSLog(@"Res:%@",userResponse);
    }
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    if (central.state == CBManagerStatePoweredOn) {
        [self startScan];
    } else {
        NSLog(@"Bluetooth Power Off");
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    NSLog(@"didDiscoverPeripheral Advert:%@",advertisementData.description);
    _np = peripheral;

    [central connectPeripheral:peripheral options:nil];
    [central stopScan];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    NSLog(@"didConnectPeripheral peripheral:%@",peripheral.description);
//    [central stopScan];
    [peripheral setDelegate:self];
    [peripheral discoverServices:nil];
//    [peripheral discoverServices:@[[CBUUID UUIDWithString:@"ffe0"]]];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    if (error) {
        NSLog(@"didFailToConnectPeripheral Failed: %@",error);
        return;
    }

    NSLog(@"didFailToConnectPeripheral");
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    if (error) {
        NSLog(@"didDiscoverServices Failed: %@",error);
        return;
    }

    NSLog(@"---- KKEN Services Founding ------");
    for (CBService *aService in peripheral.services){
        NSLog(@"KKEN Found Service: %@", aService.UUID);
        if ([aService.UUID isEqual:[CBUUID UUIDWithString:@"C70CB8F3-BB87-4412-B2D4-A90702ABDA0F"]]) {
            NSLog(@"KKEN Found Control");
            [peripheral discoverCharacteristics:nil forService:aService];
        }
        if ([aService.UUID isEqual:[CBUUID UUIDWithString:ANCS_SERVICE]]) {
            NSLog(@"KKEN Found ANCS_SERVICE");
            [peripheral discoverCharacteristics:nil forService:aService];
        }
    }
    NSLog(@"---------------------------------");
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    if (error) {
        NSLog(@"didDiscoverCharacteristicsForService Failed: %@",error);
        return;
    }

    NSLog(@"-- KKEN Characteristics Founding --");
    for (CBCharacteristic *aChar in service.characteristics){
        NSLog(@"KKEN Found Char:%@",aChar.UUID);
        if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"629B4394-7040-49C5-B0D0-218AB5FC92CD"]]) {
            NSLog(@"Discover SELF Control");
            _controlChar = aChar;
            [peripheral setNotifyValue:YES forCharacteristic:aChar];
            [peripheral readValueForCharacteristic:aChar];
        }
        if ([aChar.UUID isEqual:[CBUUID UUIDWithString:NOTIFICATION_SOURCE]]) {
            NSLog(@"Discover Notification Source");
            _ns = aChar;
            [peripheral setNotifyValue:YES forCharacteristic:aChar];
        }
        if ([aChar.UUID isEqual:[CBUUID UUIDWithString:DATA_SOURCE]]) {
            NSLog(@"Discover Data Source");
            _ds = aChar;
            [peripheral setNotifyValue:YES forCharacteristic:aChar];
        }
        if ([aChar.UUID isEqual:[CBUUID UUIDWithString:CONTROL_POINT]]) {
            NSLog(@"Discover Control Point");
            _cp = aChar;
        }
    }
    NSLog(@"---------------------------------");
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (error) {
        NSLog(@"didUpdateValueForCharacteristic ERROR: %@",[error description]);
        return;
    }
//    [self getNotifiData: characteristic.value];
    NSLog(@"KKEN characteristic.UUID: %@",characteristic.UUID);
    NSLog(@"KKEN characteristic.value: %@",characteristic.value);
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:NOTIFICATION_SOURCE]]) {
        NSLog(@"Notification:%@",characteristic.value.description);
        [self processNotificationUpdateData:characteristic.value];
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:DATA_SOURCE]]) {
        NSLog(@"Data Source:%@",characteristic.value.description);
        [self processDataSource:characteristic.value];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        NSLog(@"Error:%@",error);
    }
    NSLog(@"didWriteValueForCharacteristic");
}

- (IBAction)sendMessage:(id)sender {
    //[_np writeValue:[NSData dataWithBytes:"\x12" length:1] forCharacteristic:_cp type:CBCharacteristicWriteWithResponse];
}

- (void)getNotifiData:(NSData*) data{
    NSLog(@"getNotifiData() %@",data);
    // 8バイト取り出す
    unsigned char bytes[8];
    [data getBytes:bytes length:8];

    // Event ID
    unsigned char eventId = bytes[0];
    switch (eventId) {
        case 0:
            NSLog(@"Notification Added");
            break;
        case 1:
            NSLog(@"Notification Modified");
            break;
        case 2:
            NSLog(@"Notification Removed");
            break;
        default:
            // reserved
            break;
    }

    unsigned char categoryId = bytes[2];
    switch (categoryId) {
        case 0:
            // Other
            break;
        case 1:
            NSLog(@"Incoming Call");
            break;
        case 2:
            NSLog(@"Missed Call");
            break;
        case 3:
            NSLog(@"Voice Mail");
            break;
        case 4:
            NSLog(@"Social");
            break;
        case 5:
            NSLog(@"Schedule");
            break;
        case 6:
            NSLog(@"Email");
            break;
        case 7:
            NSLog(@"News");
            break;
        case 8:
            NSLog(@"Health and Fitness");
            break;
        case 9:
            NSLog(@"Business and Finance");
            break;
        case 10:
            NSLog(@"Location");
            break;
        case 11:
            NSLog(@"Entertainment");
            break;
        default:
            // Reserved
            break;
    }
}
@end
