//
//  Alarm.h
//  Alarm
//
//  Created by Cherif YAYA on 04/11/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define ANY -1

@interface Alarm : NSObject <NSCoding, NSCopying> {
	NSString *name;
	NSString *uid;
	int hours, mins, secs;
	NSSet *weekday, *dayOfMonth, *month, *year;
	NSMutableArray *actions;
	
	BOOL active, snooze, repeat;
	int nbSnooze;
	BOOL triggered, stopped;
	
	//flag to avoid alarm triggering on and on
	BOOL allowToTrigger;
	
}

@property (nonatomic, copy) NSString *name;
@property (nonatomic, readonly) NSString *uid;
@property BOOL active;
@property BOOL snooze;
@property BOOL repeat;
@property (nonatomic, readonly) BOOL triggered;
@property int hours;
@property int mins;
@property int secs;
@property (nonatomic, copy) NSSet * weekday;
@property (nonatomic, copy) NSSet * dayOfMonth;
@property (nonatomic, copy) NSSet * month;
@property (nonatomic, copy) NSSet * year;

-(NSString *)prettyPrint;

-(id)initWithName:(NSString *)_name Hours:(int)_hours Mins:(int)_mins Secs:(int)_secs WeekdaySet:(NSSet *)_weekday DayOfMonthSet:(NSSet *)_dayOfMonth MonthSet:(NSSet *)_month YearSet:(NSSet *)_year;
-(id)initWithName:(NSString *)name Hours:(int)hours Mins:(int)mins Secs:(int)secs Weekday:(int)day DayOfMonth:(int)dayOfMonth Month:(int)month Year:(int)year;
-(id)initWithName:(NSString *)name Hours:(int)hours Mins:(int)mins Secs:(int)secs;
-(BOOL)shouldTriggerToDate:(id)date;
-(void)addAction:(id)action;
-(void)performActions;
-(void)stop;

@end
