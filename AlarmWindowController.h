//
//  AlarmWindowController.h
//  Alarm
//
//  Created by Cherif YAYA on 06/11/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Alarm.h"

#define ADD_ACTION 0
#define EDIT_ACTION 1
#define DELETE_ACTION 2

@class AlarmController;

@interface AlarmWindowController : NSWindowController {
	Alarm *alarm;
	int currentAction;
	AlarmController *alarmController;
	
	IBOutlet NSTextField *txtName;
	IBOutlet NSButton *chboxEnabled;
	IBOutlet NSDatePicker *timePicker;
	IBOutlet NSPopUpButton *cboxRingtone;
	IBOutlet NSButton *chboxRepeat;
	IBOutlet NSButton *chboxSnooze;
	IBOutlet NSSegmentedControl *sgmtControl;
	IBOutlet NSMatrix *matrixRingtone;
	IBOutlet NSTextField *lblPath;
}

@property (retain, nonatomic) Alarm *alarm;

-(IBAction)chooseMediaFile:(id)sender;
-(IBAction)chboxRepeatChanged:(id)sender;
-(IBAction)matrixRingtoneChanged:(id)sender;

-(id)initWithAlarm:(id)alarm Action:(int)action Controller:(AlarmController *)controller;
-(void)loadValuesFromAlarm:(Alarm *)alarm;

-(IBAction)cancel:(id)sender;
-(IBAction)apply:(id)sender;

@end
