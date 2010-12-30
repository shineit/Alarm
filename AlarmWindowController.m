//
//  AlarmWindowController.m
//  Alarm
//
//  Created by Cherif YAYA on 06/11/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "AlarmWindowController.h"
#import "Action.h"
#import "AlarmController.h"


@implementation AlarmWindowController

@synthesize alarm;

-(id)initWithAlarm:(Alarm *)_alarm Action:(int)_action Controller:(AlarmController *)_controller {
	if (self = [super initWithWindowNibName:@"AlarmWindow"]) {
		currentAction = _action;
		alarmController = _controller;
		if (_alarm) {
			self.alarm = _alarm;
		}
		
		//set window background		
		self.window.backgroundColor = [NSColor colorWithPatternImage:[NSImage imageNamed:@"AlarmBackground"]];
	}
	
	return self;
}

-(void)initDefaultsValues {
	
	//ringtones
	[cboxRingtone removeAllItems];
	[cboxRingtone addItemsWithTitles:[Action ringtonesNames]];
	
	//current time
	NSDate *tmpDate = [NSDate date];
	[timePicker setDateValue:tmpDate];
}

-(void)loadValuesFromAlarm:(Alarm *)_alarm {
	if (_alarm) {
		//name and enabled state
		[txtName setStringValue:_alarm.name];
		[chboxEnabled setState:_alarm.active];
		
		//create a date with alarm's hour and mins
		NSDateComponents *components = [[NSDateComponents alloc] init];
		[components setHour:_alarm.hours]; 
		[components setMinute:_alarm.mins]; 
		NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
		NSDate *tmpDate = [gregorian dateFromComponents:components];
		[timePicker setDateValue:tmpDate];
		
		//snooze
		[chboxSnooze setState:_alarm.snooze];
		
		//alarm frequency
		[chboxRepeat setState:_alarm.repeat];
		[self chboxRepeatChanged:self];
		NSSet *weekday = _alarm.weekday;
		for(int i=1; i<=7; i++) {
			NSNumber *nb = [NSNumber numberWithInt:i];
			if ([weekday member:nb]) {
				[sgmtControl setSelected:YES forSegment:(i-1)];
			}
		}
		
		//ringtone
		NSString *ringtone = [_alarm ringtone];
		if ([ringtone hasPrefix:@"ring://"]) {
			//RINGTONE
			[matrixRingtone selectCellWithTag:0];
			[cboxRingtone selectItemAtIndex:[Action ringtoneIndex:ringtone]];
		}
		else {
			[matrixRingtone selectCellWithTag:1];
			if ([ringtone hasPrefix:@"music://"]) {
				[lblPath setStringValue:[ringtone substringFromIndex:8]];
			}
			else {
				[lblPath setStringValue:ringtone];
			}

		}
		[self matrixRingtoneChanged:self];
		
	}
}

-(void)saveValuesToAlarm {
	//read entered values
	//name
	NSString *name = [txtName stringValue];
	//enabled
	BOOL enabled = [chboxEnabled state];
	//time
	NSDate *date = [timePicker dateValue];
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *components = [gregorian components:(NSMinuteCalendarUnit | NSHourCalendarUnit) fromDate:date];
	int hours = [components hour];
	int mins = [components minute];
	//ringtone
	NSString *ringtone;
	NSButtonCell *cell = [matrixRingtone selectedCell];
	if (cell.tag == 0) {
		//RINGTONE
		ringtone = [Action ringtoneAtIndex:[cboxRingtone indexOfSelectedItem]];
	}
	else if (cell.tag == 1) {
		//CUSTOM Media File
		ringtone = [lblPath stringValue];
		ringtone = [@"music://" stringByAppendingFormat:@"%@",ringtone];
	}
	//repeat and weekday
	BOOL repeat = [chboxRepeat state];
	NSMutableSet *weekday = [NSMutableSet set];
	for(int i=0; i<7; i++) {
		NSNumber *nb = [NSNumber numberWithInt:(i+1)];
		if ([sgmtControl isSelectedForSegment:i]) {
			[weekday addObject:nb];
		}
	}
	//snooze
	BOOL snooze = [chboxSnooze state];
	
	if (self.alarm) {
		//update alarm values
		self.alarm.name = name;
		self.alarm.active = enabled;
		self.alarm.hours = hours;
		self.alarm.mins = mins;
		Action *action = [[[Action alloc] initWithName:nil Method:PLAY_MUSIC Params:ringtone] autorelease];
		[self.alarm addAction:action];
		self.alarm.repeat = repeat;
		self.alarm.weekday = weekday;
		self.alarm.snooze = snooze;
	}
	else {
		//create new alarm
		
		//if no name don't save TODO
		
		NSSet *any = [NSSet setWithObject: [NSNumber numberWithInt:ANY]];
		
		Alarm *_alarm = [[[Alarm alloc] initWithName:name Hours:hours Mins:mins Secs:ANY WeekdaySet:weekday DayOfMonthSet:any MonthSet:any YearSet:any] autorelease];
		_alarm.active = enabled;
		_alarm.snooze = snooze;
		_alarm.repeat = repeat;
		Action *action = [[[Action alloc] initWithName:nil Method:PLAY_MUSIC Params:ringtone] autorelease];
		[_alarm addAction:action];
		
		
		if (alarmController) {
			self.alarm = [alarmController addAlarm:_alarm];
		}
	}
	
	[alarmController reloadAlarmsTable];

}

- (void)windowDidLoad {
	[self initDefaultsValues];
	[self matrixRingtoneChanged:nil];
	[self chboxRepeatChanged:nil];
	
	//load values from alarm
	if (self.alarm) {
		[self loadValuesFromAlarm:self.alarm];
	}
	//window title
	if (currentAction == ADD_ACTION) {
		self.window.title = NSLocalizedString(@"Create a new alarm",@"Alarm window title");
	}
	else if (currentAction == EDIT_ACTION) {
		self.window.title = NSLocalizedString(@"Edit alarm",@"Alarm window title");
	}
}

-(BOOL)OffwindowShouldClose:(id)sender {
	//TODO
	return NO;
}

-(IBAction)cancel:(id)sender {
	[self.window performClose:self];
}

-(IBAction)apply:(id)sender {
	//save values
	[self saveValuesToAlarm];
	//close window
	[self.window performClose:self];
}

-(IBAction)chooseMediaFile:(id)sender {
	NSOpenPanel *panel = [NSOpenPanel openPanel];
	[panel setAllowsMultipleSelection:NO];
	[panel setCanChooseDirectories:NO];
	[panel setAllowedFileTypes:[NSArray arrayWithObjects:@"mp3",@"wav",@"aiff",nil]];
	int res = [panel runModal];
	
	if(res == NSOKButton){
		NSURL *url = [panel URL];
		NSString *path = [url path];
		[lblPath setStringValue:path];
	}
}

-(IBAction)chboxRepeatChanged:(id)sender {
	//enable day choice only if repeat enabled
	[sgmtControl setEnabled:[chboxRepeat state]];
}

-(IBAction)matrixRingtoneChanged:(id)sender {
	NSButtonCell *cell = [matrixRingtone selectedCell];
	if (cell.tag == 0) {
		//RINGTONE
		[cboxRingtone setEnabled:YES];
		[btnChooseFile setEnabled:NO];
		[lblPath setEnabled:NO];
	}
	else if (cell.tag == 1) {
		//CUSTOM Media File
		[cboxRingtone setEnabled:NO];
		[btnChooseFile setEnabled:YES];
		[lblPath setEnabled:YES];
	}
}

-(IBAction)didClickPath:(id)sender {
	
}

-(void)dealloc {
	[alarm release];
	[super dealloc];
}

@end
