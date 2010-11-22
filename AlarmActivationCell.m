//
//  AlarmActivationCell.m
//  Alarm
//
//  Created by Cherif YAYA on 09/11/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "AlarmActivationCell.h"


@implementation AlarmActivationCell

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
	
	CGRect nFrame = CGRectMake(cellFrame.origin.x+5, cellFrame.origin.y, cellFrame.size.width-5, cellFrame.size.height); 
	NSRect nRect = NSRectFromCGRect(nFrame);
	[super drawWithFrame:nRect inView:controlView];
	
}


@end
