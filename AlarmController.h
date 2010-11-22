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

@class AlarmWindowController;

@interface AlarmController : NSObject {
	NSMutableArray *alarms;
	IBOutlet NSTableView *alarmsTable;
	
	AlarmWindowController *controller;
	
	AuthorizationRef myAuthorizationRef; 
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

- (NSString *) pathForDataFile;
- (void) saveDataToDisk;
- (void) loadDataFromDisk; 

@end
