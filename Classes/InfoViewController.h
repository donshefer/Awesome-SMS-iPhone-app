//
//  infoViewController.h
//  AwesomeNotifier
//
//  Created by DON SPENCE on 1/25/11.
//  Copyright 2011 Light-Media.org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@protocol InfoScreenDelegate;


@interface InfoViewController : UIViewController <MFMailComposeViewControllerDelegate>
{
	id <InfoScreenDelegate> *delegate;
	
	IBOutlet UILabel *appNameLabel;
	IBOutlet UILabel *appVersionLabel;
	
	NSString *appName;
	NSString *appVersion;
}

@property (retain) id <InfoScreenDelegate> *delegate;

@property (nonatomic, retain) IBOutlet UILabel *appNameLabel;
@property (nonatomic, retain) IBOutlet UILabel *appVersionLabel;

@property (retain) NSString *appName;
@property (retain) NSString *appVersion;

- (IBAction) openRateMe;
- (IBAction) openFeedback;

@end

@protocol InfoScreenDelegate <NSObject>
- (void)infoViewController:(InfoViewController *)controller
					  done:(BOOL)done;
@end
