//
//  MessageTemplateListTableViewController.h
//  AwesomeNotifier
//
//  Created by DON SPENCE on 1/17/11.
//  Copyright 2011 Light-Media.org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InfoViewController.h"


@interface MessageTemplateListTableViewController : UIViewController <NSFetchedResultsControllerDelegate,InfoScreenDelegate> {
	NSFetchedResultsController *fetchedResultsController;
    NSManagedObjectContext *managedObjectContext;
	BOOL userDrivenDataModelChange;
	
	IBOutlet UITableView *tableView;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) IBOutlet UITableView *tableView;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)save;
@end


