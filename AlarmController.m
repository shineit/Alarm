//
//  AlarmController.m
//  Alarm
//
//  Created by Cherif YAYA on 04/11/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "AlarmController.h"
#import "Action.h"
#import "AlarmWindowController.h"
#import "AlarmCell.h"
#import "AlarmActivationCell.h"
#import "AlarmStopCell.h"
#import <IOKit/pwr_mgt/IOPMLib.h>
#import "AlarmOverlayController.h"
#import "PrefsController.h"

#define INTERVAL 0.1 //in seconds


@implementation AlarmController

-(id)init {
	if (self = [super init]) {
		alarms = [[NSMutableArray arrayWithCapacity:10] retain];
		
		//Set up timer
		[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(tick:) userInfo:nil repeats:YES];
		
		//[self addFixturesAlarm];
	}
	
	return self;
}

-(void)addFixturesAlarm {
	Alarm *alarm = [[[Alarm alloc] initWithName:NSLocalizedString(@"My Alarm",@"Fixture alarm") Hours:8 Mins:00 Secs:ANY Weekday:ANY DayOfMonth:ANY Month:ANY Year:ANY] autorelease];
	Action *action = [[[Action alloc] initWithName:nil Method:PLAY_MUSIC Params:RING_MUSIC_BOX] autorelease];
	[alarm addAction:action];
	alarm.active = NO;
	[self addAlarm:alarm];
}

-(void)tick:(NSTimer *)timer {
	for(int i=0; i<[alarms count]; i++) {
		Alarm *alarm = [alarms objectAtIndex:i];
		if (alarm && alarm.active && (!alarm.triggered)) {
			NSDate *now = [NSDate date];
			if ([alarm shouldTriggerToDate:now]) {
				//show stop button in table
				[self reloadAlarmsTable];
			}
		}
	}
}

-(NSArray *)alarms {
	return alarms;
}

-(void)reloadAlarmsTable {
	[alarmsTable reloadData];
}

-(int)alarmIndexWithName:(NSString *)name {
	for(int i=0; i<[alarms count]; i++) {
		Alarm *alarm = [alarms objectAtIndex:i];
		if (alarm && ([alarm.name compare:name] == 0) ) {
			return i;
		}
	}
	return -1;
}
 
-(int)alarmIndexWithUid:(NSString *)uid {
	for(int i=0; i<[alarms count]; i++) {
		Alarm *alarm = [alarms objectAtIndex:i];
		if (alarm && ([alarm.uid compare:uid] == 0) ) {
			return i;
		}
	}
	return -1;
}

-(Alarm *)alarmAtIndex:(NSInteger)index {
	if (index < [alarms count]) {
		return [alarms objectAtIndex:index];
	}
	else {
		return nil;
	}
}

-(id)addAlarm:(Alarm *)alarm {
	if ( !alarm || ([self alarmIndexWithUid:alarm.uid] != -1) ) {
		return nil;
	}
	int index = 0;
	//add alarm in sorted order
	if ([alarms count] == 0) {
		[alarms addObject:alarm];
		index = 0;
	}
	else {
		int i;
		for(i=0; i<[alarms count]; i++) {
			Alarm *_alarm = [alarms objectAtIndex:i];
			if ([alarm.name compare:_alarm.name] == NSOrderedAscending ) {
				[alarms insertObject:alarm atIndex:i];
				index = i;
				break;
			}
			else if ([alarm.name compare:_alarm.name] == NSOrderedSame) {
				//if same name, add right after current object in table
				[alarms insertObject:alarm atIndex:(i+1)];
				index = i+1;
				break;
			}
		}
		if (i == [alarms count]) {
			[alarms addObject:alarm];
			index = [alarms count]-1;
		}
	}
	//reload table
	[alarmsTable reloadData];
	return [alarms objectAtIndex:index];
}

-(BOOL)removeAlarmWithUid:(NSString *)uid{
	int index;
	if ( !alarm || ((index =[self alarmIndexWithUid:uid]) == -1) ) {
		return NO;
	}
	else {
		[alarms removeObjectAtIndex:index];
		//reload table
		[alarmsTable reloadData];
		return YES;
	}
	
}

-(IBAction)uiAddAlarm:(id)sender {
	if (controller) {
		[controller release];
	}
	controller = [[AlarmWindowController alloc] initWithAlarm:nil Action:ADD_ACTION Controller:self] ;
	[controller window];
	[controller showWindow:self];
	
}

- (void)didEndSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
	
    [sheet orderOut:self];
	
}

-(void)showNoSelectionAlert {
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	
	[alert setIcon:[NSImage imageNamed:@"clock"]];
	
	[alert addButtonWithTitle:NSLocalizedString(@"OK",@"No selection sheet")];
	
	[alert setMessageText:NSLocalizedString(@"No alarm selected.",@"No selection sheet")];
	
	[alert setInformativeText:NSLocalizedString(@"Please select an alarm to edit or delete.",@"No selection sheet")];
	
	[alert setAlertStyle:NSWarningAlertStyle];
	
	//
	[alert beginSheetModalForWindow:window modalDelegate:self didEndSelector:nil contextInfo:nil];
	

}

-(void)editAlarmAtIndex:(int)index {
	if (controller) {
		[controller release];
	}
	controller = [[AlarmWindowController alloc] initWithAlarm:[alarms objectAtIndex:index] Action:EDIT_ACTION Controller:self] ;
	[controller window];
	[controller showWindow:self];
}

-(IBAction)editAlarmFromMenu:(id)sender {
	NSMenuItem *menuItem = sender;
	[self editAlarmAtIndex:[menuItem tag]];
}

-(IBAction)uiEditAlarm:(id)sender {
	//get current selection
	int index = [alarmsTable selectedRow];
	if (index == -1) {
		//no rows selected
		[self showNoSelectionAlert];
		return;
	}
	
	[self editAlarmAtIndex:index];
}

-(IBAction)uiRemoveAlarm:(id)sender {
	//get current selection
	int index = [alarmsTable selectedRow];
	if (index == -1) {
		//no rows selected
		[self showNoSelectionAlert];
		return;
	}
	
	[alarms removeObjectAtIndex:index];
	//reload table
	[alarmsTable reloadData];
}

-(IBAction)showPreferences:(id)sender {
	NSLog(@"prefs...");
	if (prefsController) {
		[prefsController release];
		prefsController = nil;
	}
	prefsController = [PrefsWindowController alloc];
	[prefsController initWithWindowNibName:@"Prefs"];
	[prefsController showWindow:window];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [alarms count];
}

- (id)tableView:(NSTableView *)aTableView
objectValueForTableColumn:(NSTableColumn *)aTableColumn
			row:(NSInteger)rowIndex
{
    Alarm* theRecord;
	
    if(rowIndex < 0 || rowIndex >= [alarms count]) {
		return nil;
	}
    theRecord = [alarms objectAtIndex:rowIndex];
	if([[aTableColumn identifier] caseInsensitiveCompare:@"alarmactivation"] == NSOrderedSame) {
		return [NSNumber numberWithBool:theRecord.active];
	}
	else if([[aTableColumn identifier] caseInsensitiveCompare:@"alarmstop"] == NSOrderedSame) {
		return [NSNumber numberWithBool:theRecord.triggered];
	}
    else return theRecord;
}

-(void)didClickColumn:(id)sender {
	
	//check to see if it's a double click
	if (lastClickDate && fabs([lastClickDate timeIntervalSinceNow]) < 0.3) {
		//edit alarm
		[self uiEditAlarm:nil];
		lastClickDate = [[NSDate date] retain];
		return;
		
	}
	
	int rowIndex = [alarmsTable clickedRow];
	int colIndex = [alarmsTable clickedColumn];
	if (rowIndex <0 || rowIndex > [alarms count] || colIndex == -1) {
		return;
	}
	
	//if clicked on first column, activate-deactivate alarm
	if (colIndex == 0) {
		Alarm *alarm = [alarms objectAtIndex:rowIndex];
		alarm.active = !alarm.active;
		
		[self reloadAlarmsTable];
	}
	//if third column, stop alarm
	else if	(colIndex == 2) {
		Alarm *alarm = [alarms objectAtIndex:rowIndex];
		[alarm stop];
		
		[self reloadAlarmsTable];
	}
	
	lastClickDate = [[NSDate date] retain];
}


- (NSString *) pathForDataFile {
	NSFileManager *fileManager = [NSFileManager defaultManager]; 
	NSString *folder = @"~/Library/Application Support/Reveil"; 
	folder = [folder stringByExpandingTildeInPath]; 
	if ([fileManager fileExistsAtPath: folder] == NO) { 
		[fileManager createDirectoryAtPath: folder attributes: nil]; 
	} 
	NSString *fileName = @"Alarm.cdcalarm"; 
	return [folder stringByAppendingPathComponent: fileName];
}

- (void) saveDataToDisk {
	NSString * path = [self pathForDataFile]; 
	NSMutableDictionary * rootObject; 
	rootObject = [NSMutableDictionary dictionary]; 
	[rootObject setValue:alarms forKey:@"alarms"]; 
	[NSKeyedArchiver archiveRootObject: rootObject toFile: path]; 
}

- (void) loadDataFromDisk {
	NSString * path = [self pathForDataFile]; 
	NSDictionary * rootObject; 
	rootObject = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
	id _alarms = [rootObject valueForKey:@"alarms"];
	if (_alarms && ([_alarms respondsToSelector:@selector(count)]) ) {
		alarms = [[NSMutableArray arrayWithArray:_alarms] retain];
	}
	else {
		alarms = [[NSMutableArray arrayWithCapacity:10] retain];
	}
	
	//reload table
	[alarmsTable reloadData];
}

- (void)activateStatusMenu {
	
    NSStatusBar *bar = [NSStatusBar systemStatusBar];
	
    statusItem = [bar statusItemWithLength:NSSquareStatusItemLength];
    [statusItem retain];
	
	
	
    [statusItem setImage:[NSImage imageNamed:@"ringtone_16"]];
	
    [statusItem setHighlightMode:YES];
	[statusItem setTarget:self];
	[statusItem setAction:@selector(statusItemClicked:)];
	
    //[theItem setMenu:theMenu];
	
}

-(void)statusItemClicked:(id)sender {
	//customize status menu
	if (statusMenu) {
		[statusMenu release];
	}
	
	statusMenu = [[NSMenu allocWithZone:[NSMenu menuZone]] initWithTitle:@""];
	
	//add New Alarm menu item
	NSMenuItem *newItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:NSLocalizedString(@"New alarm",@"menu") action:@selector(uiAddAlarm:) keyEquivalent:@""];
    [newItem setEnabled:YES];
    [newItem setTarget:self];
    [statusMenu addItem:newItem];
    [newItem release];
	//separator
	[statusMenu addItem:[NSMenuItem separatorItem]];
	
	//now add alarms
	if ([alarms count]>0) {
		for(int i=0; i<[alarms count]; i++) {
			Alarm *_alarm = [alarms objectAtIndex:i];
			
			newItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:[NSString stringWithFormat:@"%@ (%@)",[_alarm name], [_alarm prettyPrint:YES]] action:@selector(editAlarmFromMenu:) keyEquivalent:@""];
			[newItem setTarget:self];
			[newItem setEnabled:YES];
			[newItem setTag:i];
			//checkmark if alarm enabled
			if (_alarm.active) {
				[newItem setState:NSOnState];
			}
			[statusMenu addItem:newItem];
			[newItem release];
		}
	}
	else {
		//add Pending alarms message
		newItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:NSLocalizedString(@"Pending alarms",@"menu") action:nil keyEquivalent:@""];
		[newItem setEnabled:NO];
		[statusMenu addItem:newItem];
		[newItem release];
		
	}
	
	//separator
	[statusMenu addItem:[NSMenuItem separatorItem]];
	//Preferences
	newItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:NSLocalizedString(@"Preferences",@"menu") action:@selector(showPreferences:) keyEquivalent:@""];
    [newItem setEnabled:YES];
    [newItem setTarget:self];
    [statusMenu addItem:newItem];
    [newItem release];	

	
	//separator
	[statusMenu addItem:[NSMenuItem separatorItem]];
	//Quit Reveil
	newItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:NSLocalizedString(@"Quit Reveil",@"menu") action:@selector(terminate:) keyEquivalent:@""];
    [newItem setEnabled:YES];
    [newItem setTarget:NSApp];
    [statusMenu addItem:newItem];
    [newItem release];
	
	//show menu
	[statusItem popUpStatusItemMenu:statusMenu];
	
	//show window if hidden
	//[window makeKeyAndOrderFront:self];
}

- (void) awakeFromNib { 
	[NSApp setDelegate: self]; 
	[self loadDataFromDisk]; 
	
	//if no alarm, add a dummy alarm
	if ([alarms count] == 0) {
		[self addFixturesAlarm];
	}
	
	[alarmsTable setTarget:self];
	[alarmsTable setAction:@selector(didClickColumn:)];
	
	//set custom cell
	NSTableColumn* activationColumn = [[alarmsTable tableColumns] objectAtIndex:2];
	NSTableColumn* checkboxColumn = [[alarmsTable tableColumns] objectAtIndex:0];
	NSTableColumn* textColumn = [[alarmsTable tableColumns] objectAtIndex:1];
	
	AlarmStopCell* btnCell = [[[AlarmStopCell alloc] init] autorelease];
	//[btnCell setButtonType:NSMomentaryChangeButton];
	[btnCell setBezelStyle:NSTexturedRoundedBezelStyle];
	[btnCell setTitle:NSLocalizedString(@"Stop",@"Alarm list Stop")];
	[activationColumn setDataCell: btnCell];
	
	AlarmActivationCell* chboxCell = [[[AlarmActivationCell alloc] init] autorelease];
	[chboxCell setButtonType:NSSwitchButton];
	[chboxCell setTitle:nil];
	[checkboxColumn setDataCell: chboxCell];
	
	AlarmCell* cell = [[[AlarmCell alloc] init] autorelease];	
	[textColumn setDataCell: cell];	
	
	//file for notification
	[self fileNotifications];
	
	//add status item
	[self activateStatusMenu];
	
}

- (void)applicationWillBecomeActive:(NSNotification *)aNotification {
	//show window if hidden
	[window makeKeyAndOrderFront:self];
	
}

- (void) applicationWillTerminate: (NSNotification *)note { 
	[self saveDataToDisk]; 
}

-(BOOL)authorizeUser {
	OSStatus myStatus;
    AuthorizationFlags myFlags = kAuthorizationFlagDefaults;              // 1
	myAuthorizationRef;                                  // 2
	
	
	
    myStatus = AuthorizationCreate(NULL, kAuthorizationEmptyEnvironment,  // 3
								   myFlags, &myAuthorizationRef);
	
    if (myStatus != errAuthorizationSuccess)
        return NO;
	
	AuthorizationItem myItems = {kAuthorizationRightExecute, 0,    // 4
		NULL, 0};
	
	AuthorizationRights myRights = {1, &myItems};                  // 5
	
	
	
	myFlags = kAuthorizationFlagDefaults |                         // 6
	kAuthorizationFlagInteractionAllowed |
	kAuthorizationFlagExtendRights;
	
	myStatus = AuthorizationCopyRights (myAuthorizationRef,       // 7
										&myRights, NULL, myFlags, NULL );
	
	if (myStatus != errAuthorizationSuccess)
        return NO;
	
	return YES;
	
}

- (void)unauthorizeUser {
	AuthorizationFree (myAuthorizationRef, kAuthorizationFlagDefaults); 
}

- (void) receiveSleepNote: (NSNotification*) note {
    NSLog(@"receiveSleepNote: %@", [note name]);
	NSCalendarDate  *timeIntervalSinceNow = [NSCalendarDate dateWithTimeIntervalSinceNow:40];
	IOReturn result = IOPMSchedulePowerEvent ((CFDateRef)timeIntervalSinceNow, NULL, CFSTR(kIOPMAutoWakeOrPowerOn));
	NSLog(@"result: %d", result);
	/*
	if ([self authorizeUser]) {
		IOReturn result = IOPMSchedulePowerEvent ((CFDateRef)timeIntervalSinceNow, NULL, CFSTR(kIOPMAutoWake));
		NSLog(@"result: %d", result);
		
		[self unauthorizeUser];
	}
	 */
}

- (void) receiveWakeNote: (NSNotification*) note {
    NSLog(@"receiveWakeNote: %@", [note name]);
}

- (void) fileNotifications {
    //These notifications are filed on NSWorkspace's notification center, not the default notification center. 
    //  You will not receive sleep/wake notifications if you file with the default notification center.
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self 
														   selector: @selector(receiveSleepNote:) name: NSWorkspaceWillSleepNotification object: NULL];
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self 
														   selector: @selector(receiveWakeNote:) name: NSWorkspaceDidWakeNotification object: NULL];
}

-(BOOL)windowShouldClose:(id)sender {
	//instead hide window
	[window orderOut:self];
	return NO;
}

-(void)dealloc {
	[lastClickDate release];
	[statusItem release];
	[prefsController release];
	[overlayController release];
	[controller release];
	[alarms release];
	[super dealloc];
}

@end
