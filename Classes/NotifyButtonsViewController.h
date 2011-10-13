//
//  NotifyButtonsViewController.h
//  AwesomeNotifier
//
//  Created by DON SPENCE on 1/17/11.
//  Copyright 2011 Light-Media.org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "MessageTemplate.h"


@interface NotifyButtonsViewController : UIViewController  <MFMessageComposeViewControllerDelegate,
															NSFetchedResultsControllerDelegate,
															UINavigationControllerDelegate,
															MFMailComposeViewControllerDelegate>
{
	NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;
	
	UIScrollView *scrollView;
	
	NSMutableArray *buttons;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSMutableArray *buttons;

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

@end
