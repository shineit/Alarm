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
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	int snoozeInterva = [[PrefsManager sharedInstance] readSnoozeInterval];
	
	if (snoozeEnabled) {
		NSLog([NSString stringWithFormat:@"playing for %d", (snoozeInterva/2)]);
		[[SoundController sharedInstance] playMusicFrom:self.actionParams During:(snoozeInterva/2)];
	}
	else {
		NSLog([NSString stringWithFormat:@"playing for %d", (snoozeInterva)]);
		[[SoundController sharedInstance] playMusicFrom:self.actionParams During:snoozeInterva];
	}
}

+(NSArray *)ringtones {
	[NSArray arrayWithObjects:RING_MARIO,RING_MUSIC_BOX,RING_LA_CUCARACHA,RING_MORNING_BIRDS,RING_KILL_BILL_THEME,nil];
}


@end
