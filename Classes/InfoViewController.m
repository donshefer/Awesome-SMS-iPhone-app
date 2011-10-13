//
//  infoViewController.m
//  AwesomeNotifier
//
//  Created by DON SPENCE on 1/25/11.
//  Copyright 2011 Light-Media.org. All rights reserved.
//

#import "InfoViewController.h"
#import "GANTracker.h"
#import "UIDevice-Hardware.h"


@implementation InfoViewController

@synthesize appNameLabel,appVersionLabel,appName,appVersion;
@synthesize delegate;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.appNameLabel.text = self.appName;
	self.appVersionLabel.text = [NSString stringWithFormat:@"Version %@",self.appVersion];
 
	UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																							 target:self action:@selector(closeWindow)];
	self.navigationItem.rightBarButtonItem = doneButtonItem;
	
	[[GANTracker sharedTracker] trackPageview:@"/info_screen" withError:nil];

}

- (void) closeWindow {
	[self.delegate infoViewController:self done:YES];
}

- (NSString *)appName {
	if (!appName) {
		appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
	}
	return appName;
}

- (NSString *)appVersion {
	if (!appVersion) {
		appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
	}
	return appVersion;
}

#define APP_ID		418754607

- (void) openRateMe
{
	NSError *error;
	if (![[GANTracker sharedTracker] trackEvent:@"user action"
										 action:@"open rate me"
										  label:@""
										  value:-1
									  withError:&error]) {
		// Handle error here
		NSLog(@"GoogleAnalytics error: %@",error);
	}
		
	//NSLog(@"openRateMe");

	NSString *templateReviewURL = @"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=APP_ID&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software";

	NSString *reviewURL = [templateReviewURL stringByReplacingOccurrencesOfString:@"APP_ID" withString:[NSString stringWithFormat:@"%d", APP_ID]];

	// open link to rate this app in appstore app 
	NSURL *url = [ [ NSURL alloc ] initWithString:reviewURL];
	BOOL result = [[UIApplication sharedApplication] openURL:url];
	//NSLog(@"result: %d",result);
}

- (void) openFeedback
{
	NSError *error;
	if (![[GANTracker sharedTracker] trackEvent:@"user action"
										 action:@"open support"
										  label:@""
										  value:-1
									  withError:&error]) {
		// Handle error here
		NSLog(@"GoogleAnalytics error: %@",error);
	}
	
	MFMailComposeViewController *controller = [[[MFMailComposeViewController alloc] init] autorelease];
	controller.mailComposeDelegate = self;
	
	NSArray *toRecipients = [NSArray arrayWithObjects:@"info@light-media.org",nil];
	[controller setToRecipients:toRecipients];
	
	[controller setSubject:@"App Feedback"];
	
	NSString *emailBody = [NSString stringWithFormat:@"\n\n\n\n\n%@ v%@\n%@ iOS %@",self.appName,self.appVersion,[[UIDevice currentDevice] platformString],[[UIDevice currentDevice] systemVersion]];
	[controller setMessageBody:emailBody isHTML:NO];
	
	
	[self presentModalViewController:controller animated:YES]; 
	
}
// MFMailComposeViewControllerDelegate Delegate methods
- (void)mailComposeController:(MFMailComposeViewController *)controller
		  didFinishWithResult:(MFMailComposeResult)result
						error:(NSError *)error
{
    [self dismissModalViewControllerAnimated:YES];
}




// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return YES;
}
- (void) adjustViewsForOrientation:(UIInterfaceOrientation)orientation {
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {	
	[appNameLabel release];
	[appVersionLabel release];
	[appName release];
	[appVersion release];
	
    [super dealloc];
}


@end
