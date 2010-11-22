//
//  SoundController.h
//  Alarm
//
//  Created by Cherif YAYA on 06/11/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SoundController : NSObject <NSSoundDelegate> {
	NSSound *sound;
	int repeatCount;

}

-(NSSound *)playMusicFrom:(NSString *)customUrl Repeat:(int)count;
-(NSSound *)playMusicFrom:(NSString *)customUrl During:(int)nbSecs;
-(void)stopAllPlayback;

+ (SoundController*)sharedInstance;

@end
