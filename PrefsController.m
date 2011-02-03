//
//  PrefsController.m
//  Notepad
//
//  Created by Cherif YAYA on 31/10/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "PrefsController.h"
#import "PrefsManager.h";


@implementation PrefsWindowController

-(void)awakeFromNib {
	//load snooze interval value
	int snoozeInterva = [[PrefsManager sharedInstance] readSnoozeInterval];
	[snoozeIntervalSlider setIntValue:(snoozeInterva / 60)];	
	[self snoozeIntervalSliderChanged:self];
	
	//prevent sleep
	BOOL allowSleep = [[PrefsManager sharedInstance] readAllowIdleSleep];
	[chboxPreventSleep setState:!allowSleep];

}

-(IBAction)snoozeIntervalSliderChanged:(id)sender {
	int snoozeInterval = [snoozeIntervalSlider intValue];
	//Save value
	int wsnoozeInterval = [[PrefsManager sharedInstance] writeSnoozeInterval:(snoozeInterval*60)];
	//Display
	[lblSnoozeInterval setStringValue:[NSString stringWithFormat:NSLocalizedString(@"%d mn",@"Snooze interval in Prefs"),snoozeInterval]];
	
}

-(IBAction)chboxPreventSleepClicked:(id)sender {
	//save opposite of checkbox since checkbox is Preventing Sleep
	[[PrefsManager sharedInstance] writeAllowIdleSleep:(![chboxPreventSleep state])];
}


@end
