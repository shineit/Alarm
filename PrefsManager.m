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
		snoozeInterval = 60;
		[defaults setInteger:snoozeInterval forKey:@"AlarmSnoozeInterval"];
	}
	
	return snoozeInterval;
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
