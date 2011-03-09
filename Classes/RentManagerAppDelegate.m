//
//  RentManagerAppDelegate.m
//  RentManager
//
//  Created by Benjamin Mies on 17.03.10.
//  Copyright os-cillation e.K. 2010. All rights reserved.
//

#import "RentManagerAppDelegate.h"
#import "Database.h"
#import "RentOutgoingViewController.h"
#import "RentOutgoingDetailViewController.h"
#import "RentIncomingViewController.h"
#import "RentIncomingDetailViewController.h"
#import "CategoryTableViewController.h"
#import "AboutViewController.h"


@implementation RentManagerAppDelegate

@synthesize window;
@synthesize tabBarController;

+ (RentManagerAppDelegate *)getAppDelegate {
	return (RentManagerAppDelegate*) [UIApplication sharedApplication].delegate;
}


- (void)applicationDidFinishLaunching:(UIApplication *)application {
	[Database createEditableCopyOfDatabaseIfNeeded];   
	outgoingController = [[RentOutgoingViewController alloc] initWithNibName:@"AbstractTableViewController" bundle:nil];
	outgoingController.title = NSLocalizedString(@"LentToTitle", @"");
	outgoingController.tabBarItem.image = [UIImage imageNamed:@"outgoing2.png"];
	
	int count = [Database getOutgoingCount];
	if (count > 0) {
		outgoingController.tabBarItem.badgeValue = [[NSString alloc] initWithFormat:@"%i", count];
	}

	UINavigationController *navController1 = [[UINavigationController alloc] initWithRootViewController:outgoingController];

	incomingController = [[RentIncomingViewController alloc] initWithNibName:@"AbstractTableViewController" bundle:nil];
	incomingController.title = NSLocalizedString(@"LentFromTitle", @"");
	incomingController.tabBarItem.image = [UIImage imageNamed:@"incoming2.png"];
	UINavigationController *navController2 = [[UINavigationController alloc] initWithRootViewController:incomingController];
	
	count = [Database getIncomingCount];
	if (count > 0) {
		incomingController.tabBarItem.badgeValue = [[NSString alloc] initWithFormat:@"%i", count];
	}
	
	categoryController = [[CategoryTableViewController alloc] initWithNibName:@"CategoryTableViewController" bundle:nil];
	categoryController.title = NSLocalizedString(@"Categories", @"");
	categoryController.tabBarItem.image = [UIImage imageNamed:@"categories.png"];
	UINavigationController *navController3 = [[UINavigationController alloc] initWithRootViewController:categoryController];
	
	
	AboutViewController *aboutController = [[AboutViewController alloc] init];
	aboutController.tabBarItem.image = [UIImage imageNamed:@"info2.png"];
	aboutController.title = NSLocalizedString(@"About", @"");
	UINavigationController *navController4 = [[UINavigationController alloc] initWithRootViewController:aboutController];
	
	NSMutableArray *viewControllers = [[NSMutableArray alloc] init];
	[viewControllers addObject:navController1];
	[viewControllers addObject:navController2];
	[viewControllers addObject:navController3];
	[viewControllers addObject:navController4];
	[tabBarController setViewControllers:viewControllers];

    // Add the tab bar controller's current view as a subview of the window
    [window addSubview:tabBarController.view];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	[self applicationDidFinishLaunching:application];
	if ([launchOptions count] == 0) {
		return YES;
	}
	UILocalNotification *notification =
	[launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
	if (notification) {
		int newTabIndex = [[notification.userInfo valueForKey:@"TabIndex"] intValue];
		NSString *entryId = [notification.userInfo valueForKey:@"CurrentEntry"];
		[tabBarController setSelectedIndex:newTabIndex];
		if (newTabIndex == 0) {
			RentEntry *entry = [Database getOutgoingEntry:entryId];
			if ([entry.entryId intValue] > 0) {
				RentOutgoingDetailViewController *controller = [[RentOutgoingDetailViewController alloc] initWithNibName:@"AbstractDetailViewController" bundle:nil];
				
				controller.delegate = outgoingController;
				controller.entry = entry;
				UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
				controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
				[outgoingController presentModalViewController:navController animated:YES];
				
				[controller release];
			}
		}
		else if (newTabIndex == 1) {
			RentEntry *entry = [Database getIncomingEntry:entryId];
			if ([entry.entryId intValue] > 0) {
				RentIncomingDetailViewController *controller = [[RentIncomingDetailViewController alloc] initWithNibName:@"AbstractDetailViewController" bundle:nil];
				
				controller.delegate = incomingController;
				controller.entry = entry;
				UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
				controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
				[incomingController presentModalViewController:navController animated:YES];
				
				[controller release];
			}
		}
	}
	return YES;
}

- (void)updateBadging {
	outgoingController.tabBarItem.badgeValue = [[NSString alloc] initWithFormat:@"%i", [Database getOutgoingCount]];
	incomingController.tabBarItem.badgeValue = [[NSString alloc] initWithFormat:@"%i", [Database getIncomingCount]];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	int count = [Database getEntryCount];
	[[UIApplication sharedApplication] setApplicationIconBadgeNumber:count];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	sleeping = TRUE;
	int count = [Database getEntryCount];
	[[UIApplication sharedApplication] setApplicationIconBadgeNumber:count];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	if (sleeping) {
		[Database prepareContactInfo];
	}
	sleeping = FALSE;
	
}


- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
	if (!sleeping) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info",@"") message:notification.alertBody delegate:nil cancelButtonTitle:NSLocalizedString(@"Close",@"") otherButtonTitles:nil];
		[alertView show];
		[alertView release];
	}
}


+ (NSObject *)createLocalNotification:(NSString *)message withDate:(NSDate *)date forEntry:(NSString *)entryId {
	Class myClass = NSClassFromString(@"UILocalNotification");
	if (myClass) {
		UILocalNotification *notification = [[myClass alloc] init];
		notification.fireDate = date;
		notification.timeZone = [NSTimeZone systemTimeZone];
		notification.alertAction = NSLocalizedString(@"Show", nil); 
		notification.alertBody = [NSString stringWithFormat:NSLocalizedString(@"PushMessage",@""), message];
		notification.soundName = UILocalNotificationDefaultSoundName; 
		
		NSString *tabIndex = [[NSString alloc ] initWithFormat:@"%i", [[[RentManagerAppDelegate getAppDelegate] tabBarController] selectedIndex]];
		
		NSMutableDictionary *infoDict = [[NSMutableDictionary alloc] init];
		[infoDict setValue:tabIndex forKey:@"TabIndex"];
		[infoDict setValue:entryId forKey:@"CurrentEntry"];
		
		notification.userInfo = infoDict; 
		
		[[UIApplication sharedApplication] scheduleLocalNotification:notification];
		
		return notification;
	}
	//	UILocalNotification *notification = [[UILocalNotification alloc] init]; 
//		notification.fireDate = date;
//		notification.timeZone = [NSTimeZone systemTimeZone];
//		notification.alertAction = NSLocalizedString(@"Show", nil); 
//		notification.alertBody = [NSString stringWithFormat:NSLocalizedString(@"PushMessage",@""), message];
//		notification.soundName = UILocalNotificationDefaultSoundName; 
//		
//		NSString *tabIndex = [NSString stringWithFormat:@"%i", [[[RentManagerAppDelegate getAppDelegate] tabBarController] selectedIndex]];
//		
//		NSDictionary *infoDict = [NSDictionary dictionaryWithObject:tabIndex forKey:@"tabIndex"]; 
//		notification.userInfo = infoDict; 
//		
//		[[UIApplication sharedApplication] scheduleLocalNotification:notification];
//		
//		return notification;
	return nil;
}

+ (BOOL)deviceSupportsPush {
	Class myClass = NSClassFromString(@"UILocalNotification");
	if (myClass) {
		return YES;
	}
	return NO;
}

- (void)dealloc {
    [tabBarController release];
    [window release];
	[incomingController release];
	[outgoingController release];
	[categoryController release];
    [super dealloc];
}

@end

