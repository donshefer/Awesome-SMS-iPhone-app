//
//  MessageTemplateDetailViewController.h
//  AwesomeNotifier
//
//  Created by DON SPENCE on 1/17/11.
//  Copyright 2011 Light-Media.org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "MessageTemplate.h"


@interface MessageTemplateDetailViewController : UIViewController <UIScrollViewDelegate,UITextFieldDelegate,UITextViewDelegate,ABPeoplePickerNavigationControllerDelegate>
{
	NSManagedObjectContext *managedObjectContext;
	MessageTemplate *messageTemplate;
	
	UITextField *buttonLabelField;
	UITextField	*toField;
	UITextField	*subjectField;
	UISegmentedControl *buttonColorControl;
	UISegmentedControl *methodControl;
	UITextView *messageField;
	UILabel *maxCharLabel;
	UILabel *subjectLabel;
	UILabel *messageLabel;
	
	UIScrollView *scrollView;
	BOOL keyboardVisible;
	CGPoint        offset;
	
	int currentField;	
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) IBOutlet UITextField *buttonLabelField;
@property (nonatomic, retain) IBOutlet UITextField *toField;
@property (nonatomic, retain) IBOutlet UITextField *subjectField;
@property (nonatomic, retain) IBOutlet UISegmentedControl *buttonColorControl;
@property (nonatomic, retain) IBOutlet UISegmentedControl *methodControl;
@property (nonatomic, retain) IBOutlet UITextView *messageField;
@property (nonatomic, retain) IBOutlet UILabel *maxCharLabel;
@property (nonatomic, retain) IBOutlet UILabel *subjectLabel;
@property (nonatomic, retain) IBOutlet UILabel *messageLabel;

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

@property (retain) MessageTemplate *messageTemplate;

- (void) loadData;
- (void) saveData;
- (void) backButtonPushed: (id)sender;
- (IBAction) methodSegmentedControlIndexChanged;
- (IBAction) addContact:(id)sender;

@end

