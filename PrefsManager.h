//
//  PrefsManager.h
//  Alarm
//
//  Created by Cherif YAYA on 19/11/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PrefsManager : NSObject {

}

-(int)readMaxSnooze;
-(int)readSnoozeInterval;
-(int)writeSnoozeInterval:(int)snoozeInterval;
-(BOOL)readAllowIdleSleep;
-(BOOL)writeAllowIdleSleep:(BOOL)allowIdleSleep;
-(BOOL)readShowDockIcon;
-(BOOL)writeShowDockIcon:(BOOL)showDockIcon;
-(int)readVolume;
-(void)writeVolume:(int)volume;


+ (PrefsManager *)sharedInstance;

@end
