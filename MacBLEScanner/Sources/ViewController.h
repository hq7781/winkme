//
//  ViewController.h
//  test
//
//  Created by 洪 権 on 2019/06/20.
//  Copyright © 2019 洪 権. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController

@property (weak) IBOutlet NSTextField *stateLabel;
@property (weak) IBOutlet NSButton *serviceScanButton;
@property (weak) IBOutlet NSScrollView *logTextView;
@property (weak) IBOutlet NSButton *clearLogButton;


@end

