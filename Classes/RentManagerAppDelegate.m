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
#import "RentIncomingViewController.h"
#import "CategoryTableViewController.h"
#import "AboutViewController.h"


@implementation RentManagerAppDelegate

@synthesize window;
@synthesize tabBarController;

+ (RentManagerAppDelegate *)getAppDelegate {
	return (RentManagerAppDelegate*) [UIApplication sharedApplication].delegate;
}


- (void)applicationDidFinishLaunching:(UIApplication *)application {
#ifdef __IPHONE_4_0
	NSLog(@"#ifdef");
#endif
#ifndef __IPHONE_4_0
	NSLog(@"#ifndef");
#endif
	
	NSString *      initialDefaultsPath;
	NSDictionary *  initialDefaults;
    
	initialDefaultsPath = [[NSBundle mainBundle] pathForResource:@"InitialDefaults" ofType:@"plist"];
	
	initialDefaults = [NSDictionary dictionaryWithContentsOfFile:initialDefaultsPath];
	
	[[NSUserDefaults standardUserDefaults] registerDefaults:initialDefaults];
	
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
//	tabBarController.delegate = self;
    // Add the tab bar controller's current view as a subview of the window
    [window addSubview:tabBarController.view];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	[self applicationDidFinishLaunching:application];
	NSArray *array = [launchOptions allValues];
	for (int i = 0; i < [array count]; i++) {
		NSLog(@"%@", [array objectAtIndex:i]);
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
	int count = [Database getEntryCount];
	[[UIApplication sharedApplication] setApplicationIconBadgeNumber:count];
}


+ (UILocalNotification *)createLocalNotification:(NSString *)message withDate:(NSDate *)date {
		UILocalNotification *notification = [[UILocalNotification alloc] init]; 
		notification.fireDate = date;
		notification.timeZone = [NSTimeZone systemTimeZone];
		notification.alertAction = NSLocalizedString(@"Show", nil); 
		notification.alertBody = [NSString stringWithFormat:NSLocalizedString(@"PushMessage",@""), message];
		notification.soundName = UILocalNotificationDefaultSoundName; 
		
		NSString *tabIndex = [NSString stringWithFormat:@"%i", [[[RentManagerAppDelegate getAppDelegate] tabBarController] selectedIndex]];
		
		NSDictionary *infoDict = [NSDictionary dictionaryWithObject:tabIndex forKey:@"tabIndex"]; 
		notification.userInfo = infoDict; 
		
		[[UIApplication sharedApplication] scheduleLocalNotification:notification];
		
		return notification;
}

- (void)dealloc {
    [tabBarController release];
    [window release];
    [super dealloc];
}

@end

