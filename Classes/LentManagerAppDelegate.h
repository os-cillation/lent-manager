//
//  LentManagerAppDelegate.h
//  LentManager
//
//  Created by Benjamin Mies on 17.03.10.
//  Copyright os-cillation e.K. 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LentIncomingViewController;
@class LentOutgoingViewController;
@class CategoryTableViewController;

@interface LentManagerAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
    UIWindow *window;
    UITabBarController *tabBarController;
	LentIncomingViewController *incomingController;
	LentOutgoingViewController *outgoingController;
	CategoryTableViewController *categoryController;
	BOOL sleeping;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

+ (LentManagerAppDelegate *)getAppDelegate;
+ (BOOL)deviceSupportsPush;

+ (UILocalNotification *)localNotification:(NSString *)message withDate:(NSDate *)date forEntry:(NSString *)entryId;

@end
