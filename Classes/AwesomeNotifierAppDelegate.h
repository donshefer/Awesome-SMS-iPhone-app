//
//  AwesomeNotifierAppDelegate.h
//  AwesomeNotifier
//
//  Created by DON SPENCE on 1/17/11.
//  Copyright 2011 Light-Media.org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <iAd/iAd.h>

#define SharedAdBannerView ((AwesomeNotifierAppDelegate *)[[UIApplication sharedApplication] delegate]).adBanner


@interface AwesomeNotifierAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
	ADBannerView *adBanner;

    
@private
    NSManagedObjectContext *managedObjectContext_;
    NSManagedObjectModel *managedObjectModel_;
    NSPersistentStoreCoordinator *persistentStoreCoordinator_;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) ADBannerView *adBanner;

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory;
- (void)saveContext;

@end

