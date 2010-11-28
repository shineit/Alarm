//
//  AlarmOverlayController.h
//  Alarm
//
//  Created by Cherif YAYA on 23/11/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Alarm.h"

@interface AlarmOverlayController : NSWindowController {
	Alarm *alarm;
	
	IBOutlet NSTextField *lblName;
	IBOutlet NSTextField *lblClock;
	IBOutlet NSButton *btnStop;
	IBOutlet NSButton *btnSnooze;	
}

-(id)initWithAlarm:(id)alarm;

-(IBAction)snooze:(id)sender;
-(IBAction)stop:(id)sender;

@end
