//
//  AlarmCell.m
//  Alarm
//
//  Created by Cherif YAYA on 09/11/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "AlarmCell.h"


@implementation AlarmCell

- (id) dataDelegate {
	return self; // in case there is no delegate we try to resolve values by using key paths
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
	[self setTextColor:[NSColor blackColor]];
	
	NSObject* data = [self objectValue];
	
	// give the delegate a chance to set a different data object
	if ([[self dataDelegate] respondsToSelector: @selector(dataElementForCell:)]) {
		data = [[self dataDelegate] dataElementForCell:self];
	}
	
	//TODO: Selection with gradient and selection color in white with shadow
	// check out http://www.cocoadev.com/index.pl?NSTableView
	
	BOOL elementDisabled    = NO;	
	if ([[self dataDelegate] respondsToSelector: @selector(disabledForCell:data:)]) {
		elementDisabled = [[self dataDelegate] disabledForCell: self data: data];
	}
	
	NSColor* primaryColor   = [self isHighlighted] ? [NSColor alternateSelectedControlTextColor] : (elementDisabled? [NSColor disabledControlTextColor] : [NSColor textColor]);
	NSString* primaryText   = [[self dataDelegate] primaryTextForCell:self data: data];
	
	NSDictionary* primaryTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys: primaryColor, NSForegroundColorAttributeName,
										   [NSFont boldSystemFontOfSize:13], NSFontAttributeName, nil];	
	[primaryText drawAtPoint:NSMakePoint(cellFrame.origin.x+10, cellFrame.origin.y) withAttributes:primaryTextAttributes];
	
	NSColor* secondaryColor = [self isHighlighted] ? [NSColor alternateSelectedControlTextColor] : [NSColor disabledControlTextColor];
	NSString* secondaryText = [[self dataDelegate] secondaryTextForCell:self data: data];
	NSDictionary* secondaryTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys: secondaryColor, NSForegroundColorAttributeName,
											 [NSFont systemFontOfSize:10], NSFontAttributeName, nil];	
	[secondaryText drawAtPoint:NSMakePoint(cellFrame.origin.x+10, cellFrame.origin.y+cellFrame.size.height/2) 
				withAttributes:secondaryTextAttributes];
	
	/*
	[[NSGraphicsContext currentContext] saveGraphicsState];
	float yOffset = cellFrame.origin.y;
	if ([controlView isFlipped]) {
		NSAffineTransform* xform = [NSAffineTransform transform];
		[xform translateXBy:0.0 yBy: cellFrame.size.height];
		[xform scaleXBy:1.0 yBy:-1.0];
		[xform concat];		
		yOffset = 0-cellFrame.origin.y;
	}	
	NSImage* icon = [[self dataDelegate] iconForCell:self data: data];	
	
	NSImageInterpolation interpolation = [[NSGraphicsContext currentContext] imageInterpolation];
	[[NSGraphicsContext currentContext] setImageInterpolation: NSImageInterpolationHigh];	
	
	[icon drawInRect:NSMakeRect(cellFrame.origin.x+5,yOffset+3,cellFrame.size.height-6, cellFrame.size.height-6)
			fromRect:NSMakeRect(0,0,[icon size].width, [icon size].height)
		   operation:NSCompositeSourceOver
			fraction:1.0];
	
	[[NSGraphicsContext currentContext] setImageInterpolation: interpolation];
	
	[[NSGraphicsContext currentContext] restoreGraphicsState];
	 */
}


#pragma mark - 
#pragma mark Delegate methods

- (BOOL) activeStateForCell: (AlarmCell*) cell data: (NSObject*) data {
	return [data active];
}
- (NSString*) primaryTextForCell: (AlarmCell*) cell data: (NSObject*) data {
	return [data name];
}
- (NSString*) secondaryTextForCell: (AlarmCell*) cell data: (NSObject*) data {
	return [data prettyPrint];		
}


@end
