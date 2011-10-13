//
//  rootViewController.m
//  AwesomeNotifier
//
//  Created by DON SPENCE on 2/1/11.
//  Copyright 2011 Light-Media.org. All rights reserved.
//

#import "RootViewController.h"
#import "NotifyButtonsViewController.h"

#import "AwesomeNotifierAppDelegate.h" // for SharedAdBannerView macro

@interface RootViewController()

// Layout the Ad Banner and Content View to match the current orientation.
// The ADBannerView always animates its changes, so generally you should
// pass YES for animated, but it makes sense to pass NO in certain circumstances
// such as inside of -viewDidLoad.
- (void)layoutForCurrentOrientation:(BOOL)animated;

// A simple method that creates an ADBannerView
// Useful if you need to create the banner view in code
// such as when designing a universal binary for iPad
- (void)createADBannerView;

@end

@implementation RootViewController

@synthesize contentView,managedObjectContext;
@synthesize navigationController;

-(UIView *)contentView {
	if (!contentView) {
		contentView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	}
	return contentView;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

	NotifyButtonsViewController *buttonViewCon = [[NotifyButtonsViewController alloc] initWithNibName:nil bundle:nil];
	self.navigationController = [[UINavigationController alloc] initWithRootViewController:buttonViewCon];
	
	self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.6f green:0.2f blue:0.0 alpha:0.8];
		
	buttonViewCon.managedObjectContext = self.managedObjectContext;
	[buttonViewCon release];
	
	[self.contentView addSubview:self.navigationController.view];
	[self.view addSubview:self.contentView];
	
	ADBannerView *adBanner = SharedAdBannerView;
	
	// set the required content sizes for this ad banner (necessary for nib-based AdBannerViews) in order to be
	// compatible for iOS 4.2 and previous versions
	adBanner.requiredContentSizeIdentifiers = (&ADBannerContentSizeIdentifierPortrait != nil) ?
	[NSSet setWithObjects:ADBannerContentSizeIdentifierPortrait, ADBannerContentSizeIdentifierLandscape, nil] : 
	[NSSet setWithObjects:ADBannerContentSizeIdentifier320x50, ADBannerContentSizeIdentifier480x32, nil];
	
	// set the delegate to self, so that we are notified of ad responses
	adBanner.delegate = self;
	
    [self.view addSubview:adBanner];
	
	//	[self createADBannerView];
    [self layoutForCurrentOrientation:NO];

}

- (void) viewWillAppear:(BOOL)animated {
	[self layoutForCurrentOrientation:NO];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    //return YES;
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self layoutForCurrentOrientation:YES];
	for (UIViewController *vc in self.navigationController.viewControllers) { 
		[vc adjustViewsForOrientation:toInterfaceOrientation];
	}	
}

- (void)createADBannerView
{
    // --- WARNING ---
    // If you are planning on creating banner views at runtime in order to support iOS targets that don't support the iAd framework
    // then you will need to modify this method to do runtime checks for the symbols provided by the iAd framework
    // and you will need to weaklink iAd.framework in your project's target settings.
    // See the iPad Programming Guide, Creating a Universal Application for more information.
    // http://developer.apple.com/iphone/library/documentation/general/conceptual/iPadProgrammingGuide/Introduction/Introduction.html
    // --- WARNING ---
	
    ADBannerView *adBanner = SharedAdBannerView;
	
	// Depending on our orientation when this method is called, we set our initial content size.
    // If you only support portrait or landscape orientations, then you can remove this check and
    // select either ADBannerContentSizeIdentifierPortrait (if portrait only) or ADBannerContentSizeIdentifierLandscape (if landscape only).
	NSString *contentSize;
	if (&ADBannerContentSizeIdentifierPortrait != nil)
	{
		contentSize = UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? ADBannerContentSizeIdentifierPortrait : ADBannerContentSizeIdentifierLandscape;
	}
	else
	{
		// user the older sizes 
		contentSize = UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? ADBannerContentSizeIdentifier320x50 : ADBannerContentSizeIdentifier480x32;
    }

	// Calculate the intial location for the banner.
    // We want this banner to be at the bottom of the view controller, but placed
    // offscreen to ensure that the user won't see the banner until its ready.
    // We'll be informed when we have an ad to show because -bannerViewDidLoadAd: will be called.
    CGRect frame;
    frame.size = [ADBannerView sizeFromBannerContentSizeIdentifier:contentSize];
    frame.origin = CGPointMake(0.0f, CGRectGetMaxY(self.view.bounds));
    
    // Now set the banner view's frame
	adBanner.frame = frame;
	
    // Set the delegate to self, so that we are notified of ad responses.
	adBanner.delegate = self;
	
    // Set the autoresizing mask so that the banner is pinned to the bottom
    adBanner.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin;
	
	// Since we support all orientations in this view controller, support portrait and landscape content sizes.
    // If you only supported landscape or portrait, you could remove the other from this set
	adBanner.requiredContentSizeIdentifiers =
	(&ADBannerContentSizeIdentifierPortrait != nil) ?
	[NSSet setWithObjects:ADBannerContentSizeIdentifierPortrait, ADBannerContentSizeIdentifierLandscape, nil] : 
	[NSSet setWithObjects:ADBannerContentSizeIdentifier320x50, ADBannerContentSizeIdentifier480x32, nil];
	
    // At this point the ad banner is now be visible and looking for an ad.
    [self.view addSubview:adBanner];
}

- (void)layoutForCurrentOrientation:(BOOL)animated
{
    ADBannerView *adBanner = SharedAdBannerView;
	
	CGFloat animationDuration = animated ? 0.4f : 0.0f;
    // by default content consumes the entire view area
    CGRect contentFrame = self.view.bounds;
    // the banner still needs to be adjusted further, but this is a reasonable starting point
    // the y value will need to be adjusted by the banner height to get the final position
	CGPoint bannerOrigin = CGPointMake(CGRectGetMinX(contentFrame), CGRectGetMaxY(contentFrame));
    CGFloat bannerHeight = 0.0f;
    
    // First, setup the banner's content size and adjustment based on the current orientation
	if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
		adBanner.currentContentSizeIdentifier = (&ADBannerContentSizeIdentifierLandscape != nil) ? ADBannerContentSizeIdentifierLandscape : ADBannerContentSizeIdentifier480x32;
    else
        adBanner.currentContentSizeIdentifier = (&ADBannerContentSizeIdentifierPortrait != nil) ? ADBannerContentSizeIdentifierPortrait : ADBannerContentSizeIdentifier320x50; 
    bannerHeight = adBanner.bounds.size.height;
	
    // Depending on if the banner has been loaded, we adjust the content frame and banner location
    // to accomodate the ad being on or off screen.
    // This layout is for an ad at the bottom of the view.
    if (adBanner.bannerLoaded)
    {
        contentFrame.size.height -= bannerHeight;
		bannerOrigin.y -= bannerHeight;
    }
    else
    {
		bannerOrigin.y += bannerHeight;
    }
    
    // And finally animate the changes, running layout for the content view if required.
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         self.contentView.frame = contentFrame;
                         [self.contentView layoutIfNeeded];
                         adBanner.frame = CGRectMake(bannerOrigin.x, bannerOrigin.y, adBanner.frame.size.width, adBanner.frame.size.height);
                     }];

}

#pragma mark -
#pragma mark ADBannerViewDelegate methods

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    [self layoutForCurrentOrientation:YES];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    [self layoutForCurrentOrientation:YES];
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
	
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
	ADBannerView *adBanner = SharedAdBannerView;
	adBanner.delegate = nil;
	[adBanner removeFromSuperview];

	self.contentView = nil;
}


- (void)dealloc {
	ADBannerView *adBanner = SharedAdBannerView;
	adBanner.delegate = nil;
	[adBanner removeFromSuperview];

	[navigationController release];
	[contentView release];
	[managedObjectContext release];
    [super dealloc];
}


@end
