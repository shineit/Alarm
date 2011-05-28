//
//  PrefsController.h
//  Notepad
//
//  Created by Cherif YAYA on 31/10/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PrefsWindowController : NSWindowController {
	IBOutlet NSSlider *snoozeIntervalSlider;
	IBOutlet NSTextField *lblSnoozeInterval;
	IBOutlet NSButton *chboxPreventSleep;
    
    IBOutlet NSButton *chboxShowDockIcon;
    
    IBOutlet NSSlider *volumeSlider;
	IBOutlet NSTextField *lblVolume;
	
}

-(IBAction)snoozeIntervalSliderChanged:(id)sender;
-(IBAction)volumeSliderChanged:(id)sender;
-(IBAction)chboxPreventSleepClicked:(id)sender;
-(IBAction)chboxShowDockIconClicked:(id)sender;

@end
