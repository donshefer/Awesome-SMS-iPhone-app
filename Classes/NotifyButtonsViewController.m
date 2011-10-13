//
//  NotifyButtonsViewController.m
//  AwesomeNotifier
//
//  Created by DON SPENCE on 1/17/11.
//  Copyright 2011 Light-Media.org. All rights reserved.
//

#import "NotifyButtonsViewController.h"
#import "MessageTemplateListTableViewController.h"
#import "MessageTemplate.h"
#import <MessageUI/MessageUI.h>
#import "Appirater.h"
#import "GANTracker.h"


@implementation UINavigationBar (CustomImage)
- (void)drawRect:(CGRect)rect {
    UIImage *image = [UIImage imageNamed: @"nav_bar_image.png"];
    [image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
}
@end

@interface NotifyButtonsViewController()

- (void)createButtons;
- (void)updateButtons;
- (void)sendMessage:(MessageTemplate *)message;

@end

@implementation NotifyButtonsViewController

@synthesize managedObjectContext,fetchedResultsController,scrollView,buttons;

- (NSArray *)buttons {
	if (!buttons) {
		buttons = [[NSMutableArray alloc] init];
	}
	return buttons;
}

#define SCROLLVIEW_CONTENT_HEIGHT 720
#define SCROLLVIEW_CONTENT_WIDTH  320

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	self.wantsFullScreenLayout = YES;
	[UIApplication sharedApplication].statusBarOrientation = self.interfaceOrientation;
	
	self.title = @"Awesome!!";
	self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.6f green:0.2f blue:0.0 alpha:0.8];
	
	UIBarButtonItem *addButton = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Setup", @"")
																   style:UIBarButtonItemStyleBordered
																  target:self
																  action:@selector(setupButtonPressed:)] autorelease];
	self.navigationItem.rightBarButtonItem = addButton;
	
	self.scrollView.contentSize = CGSizeMake(SCROLLVIEW_CONTENT_WIDTH,
											 SCROLLVIEW_CONTENT_HEIGHT);
	
	NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
		// Update to handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
	
	[self createButtons];
	[[GANTracker sharedTracker] trackPageview:@"/button_screen" withError:nil];
	
	if (![[GANTracker sharedTracker] trackEvent:@"button_screen"
										 action:@"number of buttons"
										  label:[NSString stringWithFormat:@"%d",[self.fetchedResultsController.fetchedObjects count]]
										  value:-1
									  withError:&error]) {
		// Handle error here
		NSLog(@"GoogleAnalytics error: %@",error);
	}
	

}

- (void) viewWillAppear:(BOOL)animated {
	[self updateButtons];
	[self adjustViewsForOrientation:self.interfaceOrientation];
}

- (void) createButtons {

	// Create message button
	int yPos = 20;
	int index = 0;
	for (MessageTemplate *aMessage in self.fetchedResultsController.fetchedObjects) {

		UIButton *myButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		myButton.tag = index;
		myButton.frame = CGRectMake(40,yPos, 240, 60);
		[myButton setTitle:[aMessage valueForKey:@"buttonText"] forState:UIControlStateNormal];
		[myButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		UIImage *buttonImage;
		switch ([[aMessage valueForKey:@"buttonColor"] intValue]) {
			case 0: buttonImage = [UIImage imageNamed:@"button_blue.png"]; break;
			case 1: buttonImage = [UIImage imageNamed:@"button_green.png"]; break;
			case 2: buttonImage = [UIImage imageNamed:@"button_orange.png"]; break;
			case 3: buttonImage = [UIImage imageNamed:@"button_red.png"]; break;
			case 4: buttonImage = [UIImage imageNamed:@"button_yellow.png"]; break;
		}
		[myButton setBackgroundImage:buttonImage forState: UIControlStateNormal];
		
		// add targets and actions
		[myButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
		// add to a view
		[scrollView addSubview:myButton];
		[self.buttons addObject:myButton];
		//		[myButton release];
		yPos += 75;
		index += 1;
	}
	self.scrollView.contentSize = CGSizeMake(SCROLLVIEW_CONTENT_WIDTH,
											 yPos+50);
	
	
	
}

- (void) updateButtons {
	
	// Remove eisting buttons
	for (UIButton *aButton in self.buttons) {
		[aButton removeFromSuperview];
		aButton = nil;
		[aButton release];
	}
	self.buttons = nil;
	
	[self createButtons];
	
}

- (void) buttonClicked:(UIButton *)buttonPressed {
    [self sendMessage:[self.fetchedResultsController.fetchedObjects objectAtIndex:[buttonPressed tag]]];
}

- (void)sendMessage:(MessageTemplate *)message {
	
	int method = [[message valueForKey:@"deliveryMethod"] intValue];
	if (method == 0) {
	/* SEND SMS
	 */
																							
		// Make sure they can send a message
		if ([MFMessageComposeViewController canSendText]) {

			MFMessageComposeViewController *controller = [[[MFMessageComposeViewController alloc] init] autorelease];
			controller.messageComposeDelegate = self;
			
			controller.delegate = self;
			NSArray *toRecipients = [[message valueForKey:@"contactList"] componentsSeparatedByString: @","]; 
			controller.recipients = toRecipients;
			controller.body = [message valueForKey:@"messageText"];
		
			NSError *error;
			if (![[GANTracker sharedTracker] trackEvent:@"user action"
												 action:@"open SMS dialog"
												  label:[NSString stringWithFormat:@"# of recipients: %d",[toRecipients count]]
												  value:-1
											  withError:&error]) {
				// Handle error here
				NSLog(@"GoogleAnalytics error: %@",error);
			}
			

			[self presentModalViewController:controller animated:YES]; 

		} else {
			NSError *error;
			if (![[GANTracker sharedTracker] trackEvent:@"user action"
												 action:@"can't send SMS"
												  label:@""
												  value:0
											  withError:&error]) {
				// Handle error here
				NSLog(@"GoogleAnalytics error: %@",error);
			}

			// Alert can't send SMS
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Awesome!!" message:@"Can't send SMS."
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
			[alert show];
			[alert release];
		}
	
	} else {
		/* SEND Email
		 */

		MFMailComposeViewController *controller = [[[MFMailComposeViewController alloc] init] autorelease];
		controller.mailComposeDelegate = self;

		NSArray *toRecipients = [[message valueForKey:@"contactList"] componentsSeparatedByString: @","];

		[controller setToRecipients:toRecipients];
		[controller setSubject:[message valueForKey:@"messageSubject"]];
		
		NSString *emailBody = [message valueForKey:@"messageText"];
		[controller setMessageBody:emailBody isHTML:NO];
			
		NSError *error;
		if (![[GANTracker sharedTracker] trackEvent:@"user action"
											 action:@"send email"
											  label:@""
											  value:[toRecipients count]
										  withError:&error]) {
			// Handle error here
			NSLog(@"GoogleAnalytics error: %@",error);
		}

		[self presentModalViewController:controller animated:YES]; 
	
	}	
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
	switch (result) {
		case MessageComposeResultCancelled:
			NSLog(@"Cancelled");
			NSError *error;
			if (![[GANTracker sharedTracker] trackEvent:@"user action"
												 action:@"cancel SMS"
												  label:@""
												  value:-1
											  withError:&error]) {
				// Handle error here
				NSLog(@"GoogleAnalytics error: %@",error);
			}
			break;
		case MessageComposeResultFailed:
		{
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Awesome SMS" message:@"Unknown error."
																						delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
			[alert show];
			[alert release];
			break;
		}	
		case MessageComposeResultSent:
		{	
			NSError *error;
			if (![[GANTracker sharedTracker] trackEvent:@"user action"
												 action:@"send SMS"
												  label:@""
												  value:-1
											  withError:&error]) {
				// Handle error here
				NSLog(@"GoogleAnalytics error: %@",error);
			}
			[Appirater userDidSignificantEvent:YES];
			break;
		}	
		default:
			break;
	}
	
	[self dismissModalViewControllerAnimated:YES];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
		  didFinishWithResult:(MFMailComposeResult)result
						error:(NSError *)error
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)setupButtonPressed:(id)sender {
	MessageTemplateListTableViewController *messageListTableViewCon = [[MessageTemplateListTableViewController alloc] initWithNibName:nil bundle:nil];
	messageListTableViewCon.managedObjectContext = self.managedObjectContext;
	//messageListTableViewCon.hidesBottomBarWhenPushed = NO;
	[self.navigationController pushViewController:messageListTableViewCon animated:YES];
	[messageListTableViewCon release];

	
}
#define RECTLOG(rect)    (NSLog(@""  #rect @" x:%f y:%f w:%f h:%f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height ));

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self adjustViewsForOrientation:toInterfaceOrientation];
}

- (void) adjustViewsForOrientation:(UIInterfaceOrientation)orientation {
    if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
		for (UIButton *aButton in self.buttons) {
			CGRect currentFrame = aButton.frame;
			aButton.frame = CGRectMake(currentFrame.origin.x,currentFrame.origin.y, 400, 60);
		}
		
    }
    else if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
		for (UIButton *aButton in self.buttons) {
			CGRect currentFrame = aButton.frame;
			aButton.frame = CGRectMake(currentFrame.origin.x,currentFrame.origin.y, 240, 60);
		}
		
    }
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return YES;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (fetchedResultsController != nil) {
        return fetchedResultsController;
    }
    
	// Create and configure a fetch request with the Book entity.
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
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	[self updateButtons];
}



- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	
	self.scrollView = nil;
	
}


- (void)dealloc {
	
	[scrollView release]; scrollView = nil;
	
	[fetchedResultsController release];
	[managedObjectContext release];	
	[buttons release];
    [super dealloc];
}

@end
