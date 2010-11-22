//
//  AlarmStopCell.m
//  Alarm
//
//  Created by Cherif YAYA on 10/11/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "AlarmStopCell.h"


@implementation AlarmStopCell

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
	
	NSNumber* data = [self objectValue];
	//if alarm triggered, draw button
	if ([data boolValue]) {
		CGRect nFrame = CGRectMake(cellFrame.origin.x+10, cellFrame.origin.y+5, cellFrame.size.width-20, cellFrame.size.height-10); 
		NSRect nRect = NSRectFromCGRect(nFrame);
		[super drawWithFrame:nRect inView:controlView];
	}
	
}

@end
