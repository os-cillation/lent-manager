//
//  RentManagerAppDelegate.h
//  RentManager
//
//  Created by Benjamin Mies on 17.03.10.
//  Copyright os-cillation e.K. 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RentIncomingViewController;
@class RentOutgoingViewController;
@class CategoryTableViewController;

@interface RentManagerAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
    UIWindow *window;
    UITabBarController *tabBarController;
	RentIncomingViewController *incomingController;
	RentOutgoingViewController *outgoingController;
	CategoryTableViewController *categoryController;
	BOOL sleeping;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

+ (RentManagerAppDelegate *)getAppDelegate;
+ (BOOL)deviceSupportsPush;

+ (NSObject *)createLocalNotification:(NSString *)message withDate:(NSDate *)date forEntry:(NSString *)entryId;

@end
