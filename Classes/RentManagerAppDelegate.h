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
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

+ (RentManagerAppDelegate *)getAppDelegate;

+ (UILocalNotification *)createLocalNotification:(NSString *)message withDate:(NSDate *)date;

@end
