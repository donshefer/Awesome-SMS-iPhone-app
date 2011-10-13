//
//  rootViewController.h
//  AwesomeNotifier
//
//  Created by DON SPENCE on 2/1/11.
//  Copyright 2011 Light-Media.org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>


@interface RootViewController : UIViewController <ADBannerViewDelegate> {

	NSManagedObjectContext *managedObjectContext;
	IBOutlet UIView *contentView;
	UINavigationController *navigationController;
}
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) IBOutlet UIView *contentView;
@property (nonatomic, retain) UINavigationController *navigationController;

@end
