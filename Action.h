//
//  Action.h
//  Alarm
//
//  Created by Cherif YAYA on 05/11/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Action : NSObject <NSCoding> {
	NSString *name;
	NSString *actionMethod;
	NSString *actionParams;
}

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *actionMethod;
@property (nonatomic, copy) NSString *actionParams;

-(id)initWithName:(NSString *)_name Method:(NSString *)_method Params:(NSString *)_params;
-(void)doActionWithSnooze:(BOOL)snoozeEnabled;

-(void)playMusicWithSnooze:(BOOL)snoozeEnabled;

+(NSArray *)ringtones;
+(NSString *)nameFromRingtone:(NSString *)ringtone;
+(id)ringtoneAtIndex:(int)index;
+(NSArray *)ringtonesNames;
+(int)ringtoneIndex:(NSString *)ringtone;

@end

#define PLAY_MUSIC @"playMusic"

#define RING_MARIO @"ring://Mario"
#define RING_MUSIC_BOX @"ring://Music Box"
#define RING_LA_CUCARACHA @"ring://La Cucaracha"
#define RING_MORNING_BIRDS @"ring://Morning Birds"
#define RING_KILL_BILL_THEME @"ring://Kill Bill Theme"
#define RING_CUCKOO @"ring://Cuckoo"
#define RING_BEEP @"ring://Beep"
#define RING_TELEPHONE @"ring://Telephone"
#define RING_RAIN @"ring://Rain"
#define RING_WIND_CHIMES @"ring://Wind Chimes"



