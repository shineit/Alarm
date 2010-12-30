//
//  Alarm.m
//  Alarm
//
//  Created by Cherif YAYA on 04/11/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "Alarm.h"
#import "Action.h"
#import "SoundController.h"
#import "PrefsManager.h"
#import "AlarmOverlayController.h"

@implementation Alarm

@synthesize name, uid, hours, mins, secs, weekday, dayOfMonth, month, year, actions;
@synthesize active, snooze, repeat, triggered;

-(id)initWithName:(NSString *)_name Hours:(int)_hours Mins:(int)_mins Secs:(int)_secs {
		
	return [self initWithName:_name Hours:_hours Mins:_mins Secs:_secs Weekday:ANY DayOfMonth:ANY Month:ANY Year:ANY];
	
}


-(id)initWithName:(NSString *)_name Hours:(int)_hours Mins:(int)_mins Secs:(int)_secs Weekday:(int)_weekday DayOfMonth:(int)_dayOfMonth Month:(int)_month Year:(int)_year {
	
	return [self initWithName:_name Hours:_hours Mins:_mins Secs:_secs WeekdaySet:[NSSet setWithObject: [NSNumber numberWithInt:_weekday ]] DayOfMonthSet:[NSSet setWithObject: [NSNumber numberWithInt:_dayOfMonth ]]
				MonthSet:[NSSet setWithObject: [NSNumber numberWithInt:_month ]] YearSet:[NSSet setWithObject: [NSNumber numberWithInt:_year ]]];
	
}


-(id)initWithName:(NSString *)_name Hours:(int)_hours Mins:(int)_mins Secs:(int)_secs WeekdaySet:(NSSet *)_weekday DayOfMonthSet:(NSSet *)_dayOfMonth MonthSet:(NSSet *)_month YearSet:(NSSet *)_year {
	if (self = [super init]) {
		uid = [[NSString stringWithFormat:@"%@%@", _name, [NSDate date]] copy];
		self.name = _name;
		self.hours = _hours;
		self.mins = _mins;
		self.secs = _secs;
		self.weekday = _weekday;
		self.dayOfMonth = _dayOfMonth;
		self.month = _month;
		self.year = _year;
		
		active = YES, snooze = YES, repeat = YES;
		
		allowToTrigger = YES;
		
		stopped = NO; triggered = NO;
		
		actions = [[NSMutableArray alloc] init];

	}
	
	return self;
	
}

-(void)encodeWithCoder: (NSCoder *)coder { 
	[coder encodeObject: uid forKey:@"uid"];
	[coder encodeObject: name forKey:@"name"];
	[coder encodeInt: hours forKey:@"hours"];
	[coder encodeInt: mins forKey:@"mins"];
	[coder encodeInt: secs forKey:@"secs"];
	[coder encodeObject: weekday forKey:@"weekday"];
	[coder encodeObject: dayOfMonth forKey:@"dayOfMonth"];
	[coder encodeObject: month forKey:@"month"];
	[coder encodeObject: year forKey:@"year"];
	[coder encodeObject: actions forKey:@"actions"];
	
	[coder encodeBool:active forKey:@"active"];
	[coder encodeBool:snooze forKey:@"snooze"];
	[coder encodeBool:repeat forKey:@"repeat"];
}

- (id) initWithCoder: (NSCoder *)coder {
	if (self = [super init]) { 
		uid = [[coder decodeObjectForKey:@"uid"] retain];
		self.name = [coder decodeObjectForKey:@"name"]; 
		self.hours = [coder decodeIntForKey:@"hours"];
		self.mins = [coder decodeIntForKey:@"mins"];
		self.secs = [coder decodeIntForKey:@"secs"];
		self.weekday = [coder decodeObjectForKey:@"weekday"];
		self.dayOfMonth = [coder decodeObjectForKey:@"dayOfMonth"];
		self.month = [coder decodeObjectForKey:@"month"];
		self.year = [coder decodeObjectForKey:@"year"];
		actions = [[NSMutableArray alloc] initWithArray:[coder decodeObjectForKey:@"actions"]];
		
		active = [coder decodeBoolForKey:@"active"], snooze = [coder decodeBoolForKey:@"snooze"];
		repeat = [coder decodeBoolForKey:@"repeat"];
		
		allowToTrigger = YES;
		
		stopped = NO; triggered = NO;
	}
	return self;
}

// When an instance is assigned as objectValue to a NSCell, the NSCell creates a copy.
// Therefore we have to implement the NSCopying protocol
- (id)copyWithZone:(NSZone *)zone {
    Alarm *copy = [[[self class] allocWithZone: zone] initWithName:name Hours:hours Mins:mins Secs:secs WeekdaySet:weekday DayOfMonthSet:dayOfMonth
														  MonthSet:month YearSet:year];
	copy.active = active, copy.snooze = snooze, copy.repeat = repeat;
	copy.actions = actions;
    return copy;
}

-(void)allowTriggering:(NSTimer *)timer {
	@synchronized(self) {
		allowToTrigger = YES;
	}
}

-(void)showOverlayWindow {
	if (overlayController) {
		[overlayController release];
	}
	overlayController = [[AlarmOverlayController alloc] initWithAlarm:self] ;
	[overlayController window];
	[overlayController showWindow:nil];
}

-(void)trigger:(NSTimer *)timer {
	NSLog(@"%@ triggering...", name);
	if (!stopped) {
		[self showOverlayWindow];
		[self performActions];
		nbSnooze++;
		
		if (snooze) {
			//make sure we don't snooze more than maxSnooze
			int maxSnooze = [[PrefsManager sharedInstance] readMaxSnooze];
			int snoozeInterval = [[PrefsManager sharedInstance] readSnoozeInterval];
			
			if (nbSnooze <= maxSnooze) {
				snoozeTimer = [NSTimer scheduledTimerWithTimeInterval:snoozeInterval target:self selector:@selector(trigger:) userInfo:nil repeats:NO];
			}
			else {
				//stop snoozing if maxSnooze reached
				[self stop];
			}

			
		}
	}
}

-(BOOL)shouldTriggerToDate:(NSDate *)date {
	BOOL res = NO;
	
	if (triggered) {
		return NO;
	}
	
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *components = [gregorian components:(NSDayCalendarUnit | NSWeekdayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSSecondCalendarUnit | NSMinuteCalendarUnit | NSHourCalendarUnit) fromDate:date];
	NSNumber *anyNumber = [NSNumber numberWithInt:ANY];
	
	if (secs == ANY || secs == [components second]) {
		if (mins == ANY || mins	== [components minute]) {
			if (hours == ANY || hours == [components hour]) {
				NSNumber *_dayOfMonth = [NSNumber numberWithInt:[components day]];
				if ([dayOfMonth member:_dayOfMonth] || [dayOfMonth member:anyNumber]) {
					NSNumber *_month = [NSNumber numberWithInt:[components month]];
					if ([month member:_month] || [month member:anyNumber]) {
						NSNumber *_year = [NSNumber numberWithInt:[components year]];
						if ([year member:_year] || [year member:anyNumber]) {
							//if repeat activated, check weekday too
							NSNumber *_weekday = [NSNumber numberWithInt:[components weekday]];
							if (repeat ) {
								if(![weekday member:_weekday] && ![weekday member:anyNumber]) {
									return NO;
								}
							}
							
							if(!repeat) {
								//repeat not activated and alarms triggering
								//disable alarm so that it does not repeat
								active = NO;
							}
							
							//allowToTrigger helps avoid triggering after being stopped
							if (allowToTrigger) {
								
								@synchronized(self) {
									//manage stopped state
									allowToTrigger = NO;
									stopped = NO;
									triggered = YES;
								}
								
								[self trigger:nil];
								
								if (secs != ANY) {
									//allow triggering again after 1 sec
									[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(allowTriggering:) userInfo:nil repeats:NO];
								}
								else {
									//allow triggering again after 1 min
									[NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(allowTriggering:) userInfo:nil repeats:NO];
								}
								
								return YES;
							}
												
							
						}
					}
					
				}
			}
		}
	}
	
	return res;
}


-(void)stop {
	@synchronized(self) {
		NSLog(@"%@ stopping...", name);
		stopped = YES;
		triggered = NO;
		nbSnooze = 0;
	}
	//stop all playback
	[[SoundController sharedInstance] stopAllPlayback];
}

-(void)snoozeAlarm {
	//stop all playback
	[[SoundController sharedInstance] stopAllPlayback];
	
	//and schedule later triggering
	if (snoozeTimer && [snoozeTimer isValid]) {
		[snoozeTimer invalidate];
	}
	
	int snoozeInterval = [[PrefsManager sharedInstance] readSnoozeInterval];
	snoozeTimer = [NSTimer scheduledTimerWithTimeInterval:snoozeInterval target:self selector:@selector(trigger:) userInfo:nil repeats:NO];
}

-(void)addAction:(id)action {
	if (action) {
		[actions insertObject:action atIndex:0];
	}
}

-(void)performActions {
	NSLog(@"Alarm doing action");
	for (int i=0; i<[actions count] && i<1; i++) {
		Action *action = [actions objectAtIndex:i];
		NSLog(@"%@ : %@", name, action);
		[action doActionWithSnooze:snooze];
	}
}

-(NSString *)ringtone {
	Action *action = [actions objectAtIndex:0];
	return action.actionParams;
}

-(NSString *)prettyPrint {
	NSString *recurrence = nil;
	if (repeat) {
		BOOL mon = [weekday member:[NSNumber numberWithInt:2]] != nil;
		BOOL tue = [weekday member:[NSNumber numberWithInt:3]] != nil;
		BOOL wed = [weekday member:[NSNumber numberWithInt:4]] != nil;
		BOOL thu = [weekday member:[NSNumber numberWithInt:5]] != nil;
		BOOL fri = [weekday member:[NSNumber numberWithInt:6]] != nil;
		BOOL sat = [weekday member:[NSNumber numberWithInt:7]] != nil;
		BOOL sun = [weekday member:[NSNumber numberWithInt:1]] != nil;
		
		if (mon && tue & wed && thu && fri && sat && sun) {
			recurrence = NSLocalizedString(@"everyday",@"Alarm description");
		}
		else if	(mon && tue & wed && thu && fri) {
			recurrence = NSLocalizedString(@"every work day",@"Alarm description");
		}
		else if (mon || tue || wed || thu || fri || sat || sun) {
			//TODO
			recurrence =  NSLocalizedString(@"every ",@"Alarm description");
			if (mon) {
				recurrence = [recurrence stringByAppendingFormat:NSLocalizedString(@"monday, ",@"Alarm description")];
			}
			if (tue) {
				recurrence = [recurrence stringByAppendingFormat:NSLocalizedString(@"tuesday, ",@"Alarm description")];
			}
			if (wed) {
				recurrence = [recurrence stringByAppendingFormat:NSLocalizedString(@"wednesday, ",@"Alarm description")];
			}
			if (thu) {
				recurrence = [recurrence stringByAppendingFormat:NSLocalizedString(@"thursday, ",@"Alarm description")];
			}
			if (fri) {
				recurrence = [recurrence stringByAppendingFormat:NSLocalizedString(@"friday, ",@"Alarm description")];
			}
			if (sat) {
				recurrence = [recurrence stringByAppendingFormat:NSLocalizedString(@"saturday, ",@"Alarm description")];
			}
			if (sun) {
				recurrence = [recurrence stringByAppendingFormat:NSLocalizedString(@"sunday, ",@"Alarm description")];
			}
			//remove extra comma
			if ([recurrence hasSuffix:@", "]) {
				recurrence = [recurrence stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@", "]];
			}
		}
		else {
			recurrence = NSLocalizedString(@"At ",@"Alarm description");
		}
	}
	
	if (!recurrence) {
		recurrence = NSLocalizedString(@"At ",@"Alarm description");
	}
	else {
		recurrence = [recurrence stringByAppendingFormat:NSLocalizedString(@" at",@"Alarm description")];
	}

	
	NSString *tmp = [NSString stringWithFormat:@"%@ %02d:%02d", recurrence, hours,mins];
	return tmp;
}

-(void)dealloc {
	[overlayController release];
	[weekday release];
	[dayOfMonth release];
	[month release];
	[year release];
	[name release];
	[uid release];
	[actions release];
	[super dealloc];
}

@end
