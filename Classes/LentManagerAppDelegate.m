/*-
 * Copyright 2011 os-cillation GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "LentManagerAppDelegate.h"
#import "Database.h"
#import "LentOutgoingViewController.h"
#import "LentOutgoingDetailViewController.h"
#import "LentIncomingViewController.h"
#import "LentIncomingDetailViewController.h"
#import "CategoryTableViewController.h"
#import "AboutViewController.h"


@implementation LentManagerAppDelegate

@synthesize window;
@synthesize tabBarController;

- (void)dealloc
{
    [tabBarController release];
    [window release];
	[incomingController release];
	[outgoingController release];
	[categoryController release];
    [super dealloc];
}

+ (LentManagerAppDelegate *)getAppDelegate 
{
	return (LentManagerAppDelegate*) [UIApplication sharedApplication].delegate;
}

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
	[Database createEditableCopyOfDatabaseIfNeeded];   
	outgoingController = [[LentOutgoingViewController alloc] initWithNibName:@"AbstractTableViewController" bundle:nil];
	outgoingController.title = NSLocalizedString(@"LentToTitle", @"");
	outgoingController.tabBarItem.image = [UIImage imageNamed:@"outgoing2.png"];
	
	int count = [Database getOutgoingCount];
	if (count > 0) {
		outgoingController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%i", count];
	}

	UINavigationController *navController1 = [[UINavigationController alloc] initWithRootViewController:outgoingController];

	incomingController = [[LentIncomingViewController alloc] initWithNibName:@"AbstractTableViewController" bundle:nil];
	incomingController.title = NSLocalizedString(@"LentFromTitle", @"");
	incomingController.tabBarItem.image = [UIImage imageNamed:@"incoming2.png"];
	UINavigationController *navController2 = [[UINavigationController alloc] initWithRootViewController:incomingController];
	
	count = [Database getIncomingCount];
	if (count > 0) {
		incomingController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%i", count];
	}
	
	categoryController = [[CategoryTableViewController alloc] initWithNibName:@"CategoryTableViewController" bundle:nil];
	categoryController.title = NSLocalizedString(@"Categories", @"");
	categoryController.tabBarItem.image = [UIImage imageNamed:@"categories.png"];
	UINavigationController *navController3 = [[UINavigationController alloc] initWithRootViewController:categoryController];
	
	
	AboutViewController *aboutController = [[AboutViewController alloc] init];
	aboutController.tabBarItem.image = [UIImage imageNamed:@"info2.png"];
	aboutController.title = NSLocalizedString(@"About", @"");
	UINavigationController *navController4 = [[UINavigationController alloc] initWithRootViewController:aboutController];
    [aboutController release];
	
	[tabBarController setViewControllers:[NSArray arrayWithObjects:navController1, navController2, navController3, navController4, nil]];
    
    [navController1 release];
    [navController2 release];
    [navController3 release];
    [navController4 release];

    // Add the tab bar controller's current view as a subview of the window
    [window addSubview:tabBarController.view];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[self applicationDidFinishLaunching:application];
    if ([launchOptions count]) {
        UILocalNotification *notification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
        if (notification) {
            int newTabIndex = [[notification.userInfo valueForKey:@"TabIndex"] intValue];
            NSString *entryId = [notification.userInfo valueForKey:@"CurrentEntry"];
            [tabBarController setSelectedIndex:newTabIndex];
            if (newTabIndex == 0) {
                LentEntry *entry = [Database getOutgoingEntry:entryId];
                if ([entry.entryId intValue] > 0) {
                    LentOutgoingDetailViewController *controller = [[LentOutgoingDetailViewController alloc] initWithNibName:@"AbstractDetailViewController" bundle:nil];
                    
                    controller.delegate = outgoingController;
                    controller.entry = entry;
                    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
                    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
                    [outgoingController presentModalViewController:navController animated:YES];
                    
                    [controller release];
                    [navController release];
                }
            }
            else if (newTabIndex == 1) {
                LentEntry *entry = [Database getIncomingEntry:entryId];
                if ([entry.entryId intValue] > 0) {
                    LentIncomingDetailViewController *controller = [[LentIncomingDetailViewController alloc] initWithNibName:@"AbstractDetailViewController" bundle:nil];
                    
                    controller.delegate = incomingController;
                    controller.entry = entry;
                    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
                    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
                    [incomingController presentModalViewController:navController animated:YES];
                    
                    [controller release];
                    [navController release];
                }
            }
        }
    }
	return YES;
}

- (void)updateBadging
{
	outgoingController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%i", [Database getOutgoingCount]];
	incomingController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%i", [Database getIncomingCount]];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	[[UIApplication sharedApplication] setApplicationIconBadgeNumber:[Database getEntryCount]];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	sleeping = TRUE;
	[[UIApplication sharedApplication] setApplicationIconBadgeNumber:[Database getEntryCount]];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	if (sleeping) {
		[Database prepareContactInfo];
	}
	sleeping = FALSE;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
	if (!sleeping) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info",@"") message:notification.alertBody delegate:nil cancelButtonTitle:NSLocalizedString(@"Close",@"") otherButtonTitles:nil];
		[alertView show];
		[alertView release];
	}
    else {
        int newTabIndex = [[notification.userInfo valueForKey:@"TabIndex"] intValue];
		NSString *entryId = [notification.userInfo valueForKey:@"CurrentEntry"];
		[tabBarController setSelectedIndex:newTabIndex];
		if (newTabIndex == 0) {
			LentEntry *entry = [Database getOutgoingEntry:entryId];
			if ([entry.entryId intValue] > 0) {
				LentOutgoingDetailViewController *controller = [[LentOutgoingDetailViewController alloc] initWithNibName:@"AbstractDetailViewController" bundle:nil];
				
				controller.delegate = outgoingController;
				controller.entry = entry;
				UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
				controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
				[outgoingController presentModalViewController:navController animated:YES];
				
				[controller release];
                [navController release];
                
			}
		}
		else if (newTabIndex == 1) {
			LentEntry *entry = [Database getIncomingEntry:entryId];
			if ([entry.entryId intValue] > 0) {
				LentIncomingDetailViewController *controller = [[LentIncomingDetailViewController alloc] initWithNibName:@"AbstractDetailViewController" bundle:nil];
				
				controller.delegate = incomingController;
				controller.entry = entry;
				UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
				controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
				[incomingController presentModalViewController:navController animated:YES];
				
				[controller release];
                [navController release];
                
			}
		}
	}
}


+ (UILocalNotification *)localNotification:(NSString *)message withDate:(NSDate *)date forEntry:(NSString *)entryId
{
	Class klass = NSClassFromString(@"UILocalNotification");
	if (klass) {
		UILocalNotification *notification = [[[klass alloc] init] autorelease];
		notification.fireDate = date;
		notification.timeZone = [NSTimeZone systemTimeZone];
		notification.alertAction = NSLocalizedString(@"Show", nil); 
		notification.alertBody = [NSString stringWithFormat:NSLocalizedString(@"PushMessage",@""), message];
		notification.soundName = UILocalNotificationDefaultSoundName; 
		
		NSString *tabIndex = [NSString stringWithFormat:@"%i", [[[LentManagerAppDelegate getAppDelegate] tabBarController] selectedIndex]];
		
		NSMutableDictionary *infoDict = [[NSMutableDictionary alloc] initWithCapacity:2];
		[infoDict setValue:tabIndex forKey:@"TabIndex"];
		[infoDict setValue:entryId forKey:@"CurrentEntry"];
		notification.userInfo = infoDict; 
        [infoDict release];
		
		[[UIApplication sharedApplication] scheduleLocalNotification:notification];
		
		return notification;
	}
	return nil;
}

+ (BOOL)deviceSupportsPush
{
    return NSClassFromString(@"UILocalNotification") ? YES : NO;
}

@end

