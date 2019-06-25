//
//  AppDelegate.h
//  test
//
//  Created by 洪 権 on 2019/06/20.
//  Copyright © 2019 洪 権. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <IOBluetooth/IOBluetooth.h>

//#import <CoreBluetooth/CoreBluetooth.h>
@import CoreBluetooth;

@interface AppDelegate : NSObject <NSApplicationDelegate,CBCentralManagerDelegate,CBPeripheralDelegate,NSUserNotificationCenterDelegate>

@property (assign) IBOutlet NSWindow *window;
- (IBAction)sendMessage:(id)sender;

//@interface AppDelegate : NSObject <NSApplicationDelegate>

- (void)startScan;

@end

