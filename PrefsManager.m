//
//  PrefsManager.m
//  Alarm
//
//  Created by Cherif YAYA on 19/11/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "PrefsManager.h"

static PrefsManager *sharedInstance = nil;

@implementation PrefsManager

+ (void)initialize{
    
    //register defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithBool:YES], @"ShowDockIcon", [NSNumber numberWithInt:60*5], @"AlarmSnoozeInterval", 
                                                                            [NSNumber numberWithBool:NO], @"AllowIdleSleep",[NSNumber numberWithInt:75], @"Volume", nil];
    [defaults registerDefaults:appDefaults];
}

-(int)readMaxSnooze {
	//read snooze prefs from pref file
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	int maxSnooze = [defaults integerForKey:@"AlarmMaxSnooze"];
	if (maxSnooze == 0) {
		maxSnooze = 5;
		[defaults setInteger:maxSnooze forKey:@"AlarmMaxSnooze"];
	}
	
	return maxSnooze;
}


-(int)readSnoozeInterval {
	//read snooze prefs from pref file
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	int snoozeInterval = [defaults integerForKey:@"AlarmSnoozeInterval"];
	if (snoozeInterval == 0) {
		//by default 10 min snooze interval
		snoozeInterval = 60*10;
		[defaults setInteger:snoozeInterval forKey:@"AlarmSnoozeInterval"];
	}
	
	return snoozeInterval;
}

-(int)writeSnoozeInterval:(int)snoozeInterval {
	//read snooze prefs from pref file
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	if (snoozeInterval == 0) {
		//by default 5 min snooze interval
		snoozeInterval = 60*5;
	}
	[defaults setInteger:snoozeInterval forKey:@"AlarmSnoozeInterval"];
	
	return snoozeInterval;
}

-(int)readVolume  {
	//read snooze prefs from pref file
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	int volume = [defaults integerForKey:@"Volume"];
	
	return volume;
}

-(void)writeVolume:(int)volume  {
	//read snooze prefs from pref file
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	[defaults setInteger:volume forKey:@"Volume"];
	
}

-(BOOL)readAllowIdleSleep {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	return [defaults boolForKey:@"AllowIdleSleep"];
}

-(BOOL)writeAllowIdleSleep:(BOOL)allowIdleSleep {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	[defaults setBool:allowIdleSleep forKey:@"AllowIdleSleep"];
	
	return [defaults boolForKey:@"AllowIdleSleep"];
}

-(BOOL)readShowDockIcon {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	return [defaults boolForKey:@"ShowDockIcon"];
}

-(BOOL)writeShowDockIcon:(BOOL)showDockIcon  {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	[defaults setBool:showDockIcon forKey:@"ShowDockIcon"];
	
	return [defaults boolForKey:@"ShowDockIcon"];
}


-(void)dealloc {
	[super dealloc];
}

#pragma mark -
#pragma mark Singleton methods

+ (PrefsManager *)sharedInstance
{
    @synchronized(self)
    {
        if (sharedInstance == nil)
			sharedInstance = [[PrefsManager alloc] init];
    }
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
            return sharedInstance;  // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain {
    return self;
}

- (unsigned)retainCount {
    return UINT_MAX;  // denotes an object that cannot be released
}

- (void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}


@end
