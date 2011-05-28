//
//  SoundController.m
//  Alarm
//
//  Created by Cherif YAYA on 06/11/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "SoundController.h"
#import "PrefsManager.h"

static SoundController *sharedInstance = nil;


@implementation SoundController

#pragma mark -
#pragma mark class instance methods

-(NSSound *)playMusicFrom:(NSString *)customUrl Repeat:(int)count {
	NSString *path;
	
	//clean up current song
	if (sound) {
		repeatCount = 0;
		if ([sound isPlaying]) {
			[sound stop];
		}
		
		[sound release];
		sound = nil;
	}
	
	if ([customUrl hasPrefix:@"ring://"]) {
		//play ring tone. either system or bundled resource
		path = [customUrl substringFromIndex:7];
		
		sound = [[NSSound soundNamed:path] retain];
		
	}
	else if ([customUrl hasPrefix:@"music://"]) {
		//play ring tone. either system or bundled resource
		path = [customUrl substringFromIndex:8];
		
		sound = [[NSSound alloc] initWithContentsOfFile:path
						  
													 byReference:YES];
		
	}
	else {
		//unsupported play protocol
		NSLog(@"Unsupported playing protocol %@", customUrl);
		return nil;
	}
	
	//set repeat
	repeatCount = count;
	//set delegate to be notified when playback ends
	[sound setDelegate:self];
    //set volume
    int volume = [[PrefsManager sharedInstance] readVolume];
    [sound setVolume:(volume/100.0)];
	//play
	[sound play];
	
	return sound;	
}

-(NSSound *)playMusicFrom:(NSString *)customUrl During:(int)nbSecs {
	NSString *path;
	
	//clean up current song
	if (sound) {
		repeatCount = 0;
		if ([sound isPlaying]) {
			[sound stop];
		}
		
		[sound release];
		sound = nil;
	}
	
	if ([customUrl hasPrefix:@"ring://"]) {
		//play ring tone. either system or bundled resource
		path = [customUrl substringFromIndex:7];
		
		sound = [[NSSound soundNamed:path] retain];
		
	}
	else if ([customUrl hasPrefix:@"music://"]) {
		//play ring tone. either system or bundled resource
		path = [customUrl substringFromIndex:8];
		
		sound = [[NSSound alloc] initWithContentsOfFile:path
				 
											byReference:YES];
		
	}
	else {
		//unsupported play protocol
		NSLog([NSString stringWithFormat:@"Unsupported playing protocol %@", customUrl]);
		return nil;
	}
	
	
	//set repeat
	//first cast the duration in int
	int duration = [sound duration];
	duration = duration ? duration : 1;
	repeatCount = nbSecs/duration;
	if (repeatCount > 0) {
		repeatCount = repeatCount - 1;
	}
	//set delegate to be notified when playback ends
	[sound setDelegate:self];
    //set volume
    int volume = [[PrefsManager sharedInstance] readVolume];
    [sound setVolume:(volume/100.0)];
	//play
	[sound play];
	
	return sound;
}

-(void)sound:(NSSound *)_sound didFinishPlaying:(BOOL)finishedPlaying {
	if (finishedPlaying && (repeatCount > 0)) {
		repeatCount--;
		
		[_sound play];
	}
}

-(void)stopAllPlayback {
	if (sound) {
		repeatCount = 0;
		if ([sound isPlaying]) {
			[sound stop];
		}
		
		[sound release];
		sound = nil;
	}
}

-(void)dealloc {
	[sound release];
	[super dealloc];
}

#pragma mark -
#pragma mark Singleton methods

+ (SoundController*)sharedInstance
{
    @synchronized(self)
    {
        if (sharedInstance == nil)
			sharedInstance = [[SoundController alloc] init];
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
