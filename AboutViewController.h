//
//  AboutViewController.h
//  Groups
//
//  Created by Benjamin Mies on 04.03.10.
//  Copyright 2010 os-cillation e.K.. All rights reserved.
//


@interface AboutViewController : UIViewController  {
	IBOutlet UIScrollView *scrollView;
}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

- (IBAction)done;

@end


