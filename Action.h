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

-(void)playMusicWithSnooze;

+(NSArray *)ringtones;

@end

#define PLAY_MUSIC @"playMusic"

#define RING_MARIO @"ring://Mario"
#define RING_MUSIC_BOX @"ring://Music_Box"
#define RING_LA_CUCARACHA @"ring://La_Cucaracha"
#define RING_MORNING_BIRDS @"ring://Morning_Birds"
#define RING_KILL_BILL_THEME @"ring://Kill_Bill_Theme"