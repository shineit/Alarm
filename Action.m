//
//  Action.m
//  Alarm
//
//  Created by Cherif YAYA on 05/11/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <QTKit/QTKit.h>
#import "Action.h"
#import "SoundController.h"
#import "PrefsManager.h"

#define REPEAT 4


@implementation Action

@synthesize name, actionMethod, actionParams;

-(id)initWithName:(NSString *)_name Method:(NSString *)_method Params:(NSString *)_params {
	if (self = [super init]) {
		self.name = _name;
		self.actionMethod = _method;
		self.actionParams = _params;
	}
	
	return self;
}

-(void)doActionWithSnooze:(BOOL)snoozeEnabled {
	if (!actionMethod) {
		return;
	}
	
	if ([actionMethod compare:PLAY_MUSIC] == NSOrderedSame) {
		//play music
		[self playMusicWithSnooze:snoozeEnabled];
	}
	
}

-(id)description {
	if (name) {
		return name;
	}
	else {
		NSString *desc = actionMethod;
		if ([actionMethod compare:PLAY_MUSIC] == NSOrderedSame) {
			desc = @"Playing ";
		}
		return [NSString stringWithFormat:@"%@ %@", desc, actionParams];
	}

}

-(void)dealloc {
	[name release];
	[actionMethod release];
	[actionParams release];
	[super dealloc];
}

-(void)encodeWithCoder: (NSCoder *)coder { 
	[coder encodeObject: name forKey:@"name"];
	[coder encodeObject: actionMethod forKey:@"method"];
	[coder encodeObject: actionParams forKey:@"params"];
}

- (id) initWithCoder: (NSCoder *)coder {
	if (self = [super init]) { 
		self.name = [coder decodeObjectForKey:@"name"]; 
		self.actionMethod = [coder decodeObjectForKey:@"method"];
		self.actionParams = [coder decodeObjectForKey:@"params"];
	}
	return self;
} 

////////////////////////////////////////////

//action methods
-(void)playMusicWithSnooze:(BOOL)snoozeEnabled {
	//read snooze prefs from pref file
	
	int snoozeInterva = [[PrefsManager sharedInstance] readSnoozeInterval];
	
	if (snoozeEnabled) {
		NSLog(@"playing for %d", (snoozeInterva/2));
		[[SoundController sharedInstance] playMusicFrom:self.actionParams During:(snoozeInterva/2)];
	}
	else {
		NSLog(@"playing for %d", (snoozeInterva));
		[[SoundController sharedInstance] playMusicFrom:self.actionParams During:snoozeInterva];
	}
}

+(NSArray *)ringtones {
	return [NSArray arrayWithObjects:RING_BEEP, RING_CUCKOO, RING_LA_CUCARACHA, RING_MORNING_BIRDS, RING_MUSIC_BOX, RING_RAIN, RING_TELEPHONE, nil];
}

+(NSArray *)ringtonesNames {
	NSArray *tmp = [Action ringtones];
	NSMutableArray *names = [NSMutableArray array];
	for (int i=0; i<tmp.count; i++) {
		NSString *ring = [tmp objectAtIndex:i];
		[names addObject:[Action nameFromRingtone:ring]]; 
	}
	
	return names;
}

+(NSString *)nameFromRingtone:(NSString *)ringtone {
	NSString *ret = [ringtone substringFromIndex:7];
	ret = [ret stringByReplacingOccurrencesOfString:@"_" withString:@" "];
	
	return ret;
}

+(id)ringtoneAtIndex:(int)index {
	NSArray *tmp = [Action ringtones];
	return [tmp objectAtIndex:index];
}

+(int)ringtoneIndex:(NSString *)ringtone {
	NSArray *tmp = [Action ringtones];
	
	for (int i=0; i<tmp.count; i++) {
		NSString *ring = [tmp objectAtIndex:i];
		if ([ring compare:ringtone ] == NSOrderedSame) {
			return i;
		}
	}
	
	return 0;
}



@end
