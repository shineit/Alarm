//
//  AlarmController.h
//  Alarm
//
//  Created by Cherif YAYA on 04/11/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Alarm.h"
#include <Security/Authorization.h>
#include <Security/AuthorizationTags.h>
#import <IOKit/pwr_mgt/IOPMLib.h>


@class AlarmWindowController;
@class AlarmOverlayController;
@class PrefsWindowController;

@interface AlarmController : NSObject {
	NSMutableArray *alarms;
	IBOutlet NSTableView *alarmsTable;
	IBOutlet NSWindow *window;
	
	NSMenu *statusMenu;
	
	AlarmWindowController *controller;
	
	AuthorizationRef myAuthorizationRef; 
	
	AlarmOverlayController *overlayController;
	PrefsWindowController *prefsController;
	NSStatusItem *statusItem;
	
	NSDate *lastClickDate;
	
	IOPMAssertionID sleepAssertionID;
}


-(id)init;
-(void)tick:(NSTimer *)timer;

-(NSArray *)alarms;
-(id)addAlarm:(Alarm *)alarm;
-(BOOL)removeAlarmWithUid:(NSString *)uid;
-(int)alarmIndexWithName:(NSString *)name;
-(int)alarmIndexWithUid:(NSString *)uid;
-(Alarm *)alarmAtIndex:(NSInteger)index;
-(void)reloadAlarmsTable;

-(IBAction)uiAddAlarm:(id)sender;
-(IBAction)uiEditAlarm:(id)sender;
-(IBAction)uiRemoveAlarm:(id)sender;
-(IBAction)showPreferences:(id)sender;
-(IBAction)showMainWindow:(id)sender;

- (NSString *) pathForDataFile;
- (void) saveDataToDisk;
- (void) loadDataFromDisk; 

@end
