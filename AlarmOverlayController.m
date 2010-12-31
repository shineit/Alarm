//
//  AlarmOverlayController.m
//  Alarm
//
//  Created by Cherif YAYA on 23/11/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "AlarmOverlayController.h"


@implementation AlarmOverlayController


-(id)initWithAlarm:(id)_alarm {
	if (self = [super initWithWindowNibName:@"AlarmOverlay"]) {
		if (_alarm) {
			alarm = _alarm;
		}
		
		//Set up timer
		[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(tick:) userInfo:nil repeats:YES];
	}
	
	return self;
}

-(void)tick:(NSTimer *)timer {
	NSDate *now = [NSDate date];
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *components = [gregorian components:(NSMinuteCalendarUnit | NSHourCalendarUnit | NSSecondCalendarUnit) fromDate:now];
	int hours = [components hour];
	int mins = [components minute];
	int secs = [components second];
	[lblClock setStringValue:[NSString stringWithFormat:@"%02d:%02d:%02d",hours,mins,secs]];
}

-(IBAction)snooze:(id)sender {
	NSLog(@"snooze");
	[btnSnooze setEnabled:YES];
	if (alarm) {
		[alarm snoozeAlarm];
	}
	
	[self close];
}

-(IBAction)stop:(id)sender {
	NSLog(@"stop");
	[btnSnooze setEnabled:YES];
	if (alarm) {
		[alarm stop];
	}
	
	[self close];
}

-(void)makeButtonTitleWhite:(NSButton *)button {
	NSMutableAttributedString *title =
    [[[NSMutableAttributedString alloc] 
	  initWithAttributedString:[button attributedTitle]]
	 autorelease];
	[title
	 addAttribute:NSForegroundColorAttributeName 
	 value:[NSColor whiteColor]
	 range:NSMakeRange(0, [title length])];
	[title fixAttributesInRange:NSMakeRange(0, [title length])];
	[button setAttributedTitle:title];
	
}

-(void) awakeFromNib {
	[self tick:nil];
	if (alarm) {
		[lblName setStringValue:alarm.name];
	}
	[lblClock setFont:[NSFont systemFontOfSize:44]];
	[lblName setFont:[NSFont systemFontOfSize:16]];
	//window
	//self.window.backgroundColor = [NSColor colorWithDeviceRed:0 green:0 blue:0 alpha:0.5];
	//lblClock.backgroundColor = [NSColor colorWithDeviceRed:0 green:0 blue:0 alpha:0.8];
	[self makeButtonTitleWhite:btnStop];
	[self makeButtonTitleWhite:btnSnooze];
}

-(void)windowDidLoad {
	[self.window center];
	//TODO better handling of alarm events
}

-(BOOL)windowShouldClose:(id)sender {
	return YES;
}

-(void)dealloc {
	[alarm release];
	[super dealloc];
}

@end
