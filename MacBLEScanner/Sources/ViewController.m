//
//  ViewController.m
//  test
//
//  Created by 洪 権 on 2019/06/20.
//  Copyright © 2019 洪 権. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    // Update the view, if already loaded.
}

- (IBAction)onScan:(id)sender {
    AppDelegate *delegate = (AppDelegate *)[NSApplication sharedApplication].delegate;
    NSLog(@"on Clicked Scan");
    [self showState:@"Start Scan"];
    [delegate startScan];
}
- (IBAction)onClear:(id)sender {
//    self.logTextView.
//    self.logTextView.inputContext. = @"";
}
- (void)showState:(NSString*)text {
    self.stateLabel.stringValue = text;
}

@end
