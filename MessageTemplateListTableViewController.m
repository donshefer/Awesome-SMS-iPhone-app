//
//  MessageTemplateListTableViewController.m
//  AwesomeNotifier
//
//  Created by DON SPENCE on 1/17/11.
//  Copyright 2011 Light-Media.org. All rights reserved.
//

#import "MessageTemplateListTableViewController.h"
#import "MessageTemplateDetailViewController.h"
#import "MessageTemplate.h"
#import "GANTracker.h"

@interface MessageTemplateListTableViewController()

UIButton *goProHeaderButtonItem;
UIButton *infoHeaderButtonItem;
@end

@implementation MessageTemplateListTableViewController

@synthesize fetchedResultsController, managedObjectContext,tableView;


#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = @"Setup";
	self.navigationItem.rightBarButtonItem = self.editButtonItem;


	UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)] autorelease];
	

	infoHeaderButtonItem = [UIButton buttonWithType:UIButtonTypeCustom];
	[infoHeaderButtonItem setImage:[UIImage imageNamed:@"info_button.png"] forState:UIControlStateNormal];
	[infoHeaderButtonItem addTarget:self action:@selector(openInfo) forControlEvents:UIControlEventTouchUpInside];

	[headerView addSubview:infoHeaderButtonItem];
	
	goProHeaderButtonItem = [UIButton buttonWithType:UIButtonTypeCustom];
	[goProHeaderButtonItem setImage:[UIImage imageNamed:@"gopro_button.png"] forState:UIControlStateNormal];
	[goProHeaderButtonItem addTarget:self action:@selector(openGoPro) forControlEvents:UIControlEventTouchUpInside];

	[self adjustViewsForOrientation:[UIApplication sharedApplication].statusBarOrientation];
	
	[headerView addSubview:goProHeaderButtonItem ];
	
	self.tableView.tableHeaderView = headerView;
	self.tableView.sectionHeaderHeight = 2.0f;
	
		
	// Initial fetch
	NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
		// Update to handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
	//NSLog(@"Fetched %d", [self.fetchedResultsController.fetchedObjects count]);
	
	[[GANTracker sharedTracker] trackPageview:@"/setup_message_list" withError:nil];

	
}

- (void)viewWillAppear:(BOOL)animated {
	[self.tableView reloadData];
	[self adjustViewsForOrientation:self.interfaceOrientation];

}

#pragma mark -
#pragma mark Table view data source methods

/*
 The data source methods are handled primarily by the fetch results controller
 */

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[fetchedResultsController sections] count];
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
	
	id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
	
	if (aTableView.editing)
        return ([sectionInfo numberOfObjects] + 1);
    else
        return [sectionInfo numberOfObjects];  
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell.
	[self configureCell:cell atIndexPath:indexPath];
    return cell;
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	
	int objectCount = [self.fetchedResultsController.fetchedObjects count];
	//NSLog(@"Config index.row: %d object count: %d",indexPath.row,objectCount);
	
    if ((objectCount != 0) && (indexPath.row <= (objectCount-1)))
	{
		// Configure the cell to show the message's buttonText
		MessageTemplate *message = [fetchedResultsController objectAtIndexPath:indexPath];
		cell.textLabel.text = message.buttonText;
		[cell setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
	}
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	// Display the authors' names as section headings.
    return [[[fetchedResultsController sections] objectAtIndex:section] name];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (self.editing == NO || !indexPath) return UITableViewCellEditingStyleNone;
    if (indexPath.row >= [self.fetchedResultsController.fetchedObjects count]) 
        return UITableViewCellEditingStyleInsert;
    else
        return UITableViewCellEditingStyleDelete;
	
    return UITableViewCellEditingStyleNone;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		
		// Delete the managed object.
		[self.managedObjectContext deleteObject:[fetchedResultsController objectAtIndexPath:indexPath]];
		
		[self save];

    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
		
		// Insert new row
		MessageTemplate *newMessageTemplate = (MessageTemplate *)[NSEntityDescription insertNewObjectForEntityForName:@"MessageTemplate" 
																							   inManagedObjectContext:self.managedObjectContext];
		int objectCount = [self.fetchedResultsController.fetchedObjects count];
		newMessageTemplate.displayOrder = [NSNumber numberWithInt:objectCount+1];
		
		[self save];
	}
}

- (void) save {

	NSError *error;
	if (![self.managedObjectContext save:&error]) {
		// Update to handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
	
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	
	int objectCount = [self.fetchedResultsController.fetchedObjects count];

	if (objectCount == 0) {
		return NO;
	}
	
	if(indexPath.row <= (objectCount - 1)) {
		return YES;		
	} else {
		return NO;
		
	}
	
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    int objectCount = [self.fetchedResultsController.fetchedObjects count];
	
	if( proposedDestinationIndexPath.row > (objectCount - 1))
    {
        return sourceIndexPath;
    }
    else
    {
        return proposedDestinationIndexPath;
    }
}

- (void) tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
	userDrivenDataModelChange = YES;

	NSMutableArray *things = [[fetchedResultsController fetchedObjects] mutableCopy];
	// Grab the item we're moving.
	NSManagedObject *thing = [[self fetchedResultsController] objectAtIndexPath:sourceIndexPath];
	
	// Remove the object we're moving from the array.
	[things removeObject:thing];
	// Now re-insert it at the destination.
	[things insertObject:thing atIndex:[destinationIndexPath row]];
	
	// All of the objects are now in their correct order. Update each
	// object's displayOrder field by iterating through the array.
	int i = 0;
	for (NSManagedObject *mo in things)
	{
		[mo setValue:[NSNumber numberWithInt:i++] forKey:@"displayOrder"];
	}
	[things release];
	things = nil;
	
	[self save];
		
	userDrivenDataModelChange = NO;

}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.tableView beginUpdates];
    [self.tableView setEditing:editing animated:YES];


    if (editing)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.fetchedResultsController.fetchedObjects count] inSection:0];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];                       
    }
    else
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.fetchedResultsController.fetchedObjects count] inSection:0];             
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];                       
		// [self save];

	}
    [self.tableView endUpdates];
}


#pragma mark -
#pragma mark Selection and moving

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
    // Create and push a detail view controller.
	MessageTemplateDetailViewController *detailViewController = [[MessageTemplateDetailViewController alloc] initWithNibName:nil bundle:nil];
    MessageTemplate *selectedMessage = (MessageTemplate *)[[self fetchedResultsController] objectAtIndexPath:indexPath];
    // Pass the selected message to the new view controller.
    detailViewController.messageTemplate = selectedMessage;
    detailViewController.managedObjectContext = managedObjectContext;
	detailViewController.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:detailViewController animated:YES];
	[detailViewController release];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	
	[self tableView:tableView didSelectRowAtIndexPath:indexPath];
}

#pragma mark -
#pragma mark Fetched results controller

/**
 Returns the fetched results controller. Creates and configures the controller if necessary.
 */
- (NSFetchedResultsController *)fetchedResultsController {
    
    if (fetchedResultsController != nil) {
        return fetchedResultsController;
    }
    
	// Create and configure a fetch request with the message entity.
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"MessageTemplate" inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:entity];
	
	// Create the sort descriptors array.
	NSSortDescriptor *displayOrderDescriptor = [[NSSortDescriptor alloc] initWithKey:@"displayOrder" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:displayOrderDescriptor,nil];
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	// Create and initialize the fetch results controller.
	NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
	self.fetchedResultsController = aFetchedResultsController;
	fetchedResultsController.delegate = self;
	
	// Memory management.
	[aFetchedResultsController release];
	[fetchRequest release];
	[displayOrderDescriptor release];
	[sortDescriptors release];
	
	return fetchedResultsController;
}    


/**
 Delegate methods of NSFetchedResultsController to respond to additions, removals and so on.
 */

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	if (userDrivenDataModelChange) return;

	// The fetch controller is about to start sending change notifications, so prepare the table view for updates.
	[self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
	if (userDrivenDataModelChange) return;

	UITableView *aTableView = self.tableView;
	
	switch(type) {
			
		case NSFetchedResultsChangeInsert:
			[aTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[aTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeUpdate:
			[self configureCell:[aTableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
			break;
			
		case NSFetchedResultsChangeMove:
			[aTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [aTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
	if (userDrivenDataModelChange) return;

	switch(type) {
			
		case NSFetchedResultsChangeInsert:
			[self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	if (userDrivenDataModelChange) return;

	// The fetch controller has sent all current change notifications, so tell the table view to process all updates.
	[self.tableView endUpdates];
}

// Info screen methods

- (void) openInfo {
    // Create and push a detail view controller.
	InfoViewController *ivc = [[InfoViewController alloc] initWithNibName:nil bundle:nil];
	ivc.delegate = self;
	UINavigationController *navController = [[UINavigationController alloc]
											 initWithRootViewController:ivc];
	
	[self presentModalViewController:navController animated:YES];
	
	[ivc release];	
}

- (void)infoViewController:(InfoViewController *)controller
					  done:(BOOL)done
{
	if (done) {
		[self dismissModalViewControllerAnimated:YES];	
	}
}

- (void) openGoPro {
	
	[[GANTracker sharedTracker] trackPageview:@"/goPro_link" withError:nil];
	
	// Open Go Pro URL
	//NSLog(@"open Go Pro");
	
	// open link to rate this app in appstore app 
	NSURL *url = [ [ NSURL alloc ] initWithString:@"http://www.symbiosystems.com/awn"];
	BOOL result = [[UIApplication sharedApplication] openURL:url];
	//NSLog(@"Open URL result: %d",result);
	
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self adjustViewsForOrientation:toInterfaceOrientation];
}

- (void) adjustViewsForOrientation:(UIInterfaceOrientation)orientation {
	
	if (UIDeviceOrientationIsPortrait(orientation)) {
		infoHeaderButtonItem.frame = CGRectMake(8, 5, 48, 32);
		goProHeaderButtonItem.frame = CGRectMake(246, 5, 64, 32);
	} else {
		infoHeaderButtonItem.frame = CGRectMake(8, 10, 48, 32);
		goProHeaderButtonItem.frame = CGRectMake(406, 10, 64, 32);
		
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}



#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
		
	self.fetchedResultsController = nil;
}


- (void)dealloc {
	[tableView release];
	[fetchedResultsController release];
	[managedObjectContext release];	
    [super dealloc];
}


@end

