//
//  MessageTemplateDetailViewController.m
//  AwesomeNotifier
//
//  Created by DON SPENCE on 1/17/11.
//  Copyright 2011 Light-Media.org. All rights reserved.
//

#import "MessageTemplateDetailViewController.h"
#import "GANTracker.h"


@implementation MessageTemplateDetailViewController

@synthesize buttonLabelField,toField,subjectField,buttonColorControl,methodControl,messageField,maxCharLabel;
@synthesize messageTemplate,managedObjectContext,scrollView,subjectLabel,messageLabel;

#define SCROLLVIEW_HEIGHT_PORTRAIT 448
#define SCROLLVIEW_WIDTH_PORTRAIT  320

#define SCROLLVIEW_HEIGHT_LANDSCAPE 298
#define SCROLLVIEW_WIDTH_LANDSCAPE  480

#define SCROLLVIEW_CONTENT_HEIGHT 690 //original 720
#define SCROLLVIEW_CONTENT_WIDTH  320


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	
	// LeftButton in Navigation Bar
	UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(backButtonPushed:)];
	self.navigationItem.leftBarButtonItem = leftBarButton;
	[leftBarButton release]; 
	
	// Add keyboard notifications
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector (keyboardWillShow:)
												 name: UIKeyboardWillShowNotification object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector (keyboardWillHide:)
												 name: UIKeyboardWillHideNotification object:nil];	
	
	

	// Setup content size
	self.scrollView.contentSize = CGSizeMake(SCROLLVIEW_CONTENT_WIDTH,
											 SCROLLVIEW_CONTENT_HEIGHT);
	
    [super viewDidLoad];
	[self loadData];
	
	[self setHiddenState];
	
	[[GANTracker sharedTracker] trackPageview:@"/edit_message_detail" withError:nil];
	
}

- (void)viewDidUnload {
	
	managedObjectContext= nil;
	messageTemplate = nil;
	buttonLabelField = nil;
	toField = nil;
	buttonColorControl = nil;
	methodControl = nil;
	messageField = nil;
	maxCharLabel = nil;
	scrollView = nil;
	subjectField = nil;
	subjectLabel = nil;
	messageLabel = nil;
	
	[super viewDidUnload];
}

- (void) backButtonPushed: (id)sender  {
	
	//NSLog(@"backButtonPushed");

	switch (currentField) {
		case 1:
			[buttonLabelField resignFirstResponder];
			currentField = 0;
			break;
		case 2:
			[toField resignFirstResponder];
			[subjectField resignFirstResponder];
			currentField = 0;
			break;
		case 3:
			[messageField resignFirstResponder];
			currentField = 0;
			break;
		default:
			[self saveData];
			[self.navigationController popViewControllerAnimated:YES];
			break;
	}
	
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void) loadData
{
	self.buttonLabelField.text = self.messageTemplate.buttonText;
	self.toField.text = self.messageTemplate.contactList;
	self.buttonColorControl.selectedSegmentIndex = [self.messageTemplate.buttonColor intValue];
	self.methodControl.selectedSegmentIndex = [self.messageTemplate.deliveryMethod intValue];
	self.messageField.text = self.messageTemplate.messageText;	
	self.subjectField.text = self.messageTemplate.messageSubject;	
}

- (void) saveData
{
	
	if (self.buttonLabelField.text == nil) { messageTemplate.buttonText = @"";
	} else { messageTemplate.buttonText = [NSString stringWithString:self.buttonLabelField.text]; }
	
	if (self.toField.text == nil) {	messageTemplate.contactList = @"";
	} else { messageTemplate.contactList = [NSString stringWithString:self.toField.text]; }
	
	if (self.messageField.text == nil) {	messageTemplate.messageText = @"";
	} else { messageTemplate.messageText = [NSString stringWithString:self.messageField.text];}
	
	if (self.subjectField.text == nil) {	messageTemplate.messageSubject = @"";
	} else { messageTemplate.messageSubject = [NSString stringWithString:self.subjectField.text];}
	
	messageTemplate.buttonColor = [NSNumber numberWithInt:self.buttonColorControl.selectedSegmentIndex];
	messageTemplate.deliveryMethod = [NSNumber numberWithInt:self.methodControl.selectedSegmentIndex];
	
	
	NSError *error;
	if (![self.managedObjectContext save:&error]) {
		// Update to handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
	//NSLog(@"Saved object: %@",messageTemplate);
}



-(void) keyboardWillShow: (NSNotification *)notif 
{
	// If keyboard is visible, return
	if (keyboardVisible) 
	{
		NSLog(@"Keyboard is already visible. Ignoring notification.");
		return;
	}
	
	// Get the size of the keyboard.
	NSDictionary* info = [notif userInfo];
	NSValue* aValue = [info objectForKey:UIKeyboardBoundsUserInfoKey];
	CGSize keyboardSize = [aValue CGRectValue].size;
	
	// Save the current location so we can restore
	// when keyboard is dismissed
	offset = scrollView.contentOffset;
	
	// Resize the scroll view to make room for the keyboard
	CGRect viewFrame = scrollView.frame;
	viewFrame.size.height -= keyboardSize.height;
	scrollView.frame = viewFrame;
	//NSLog(@"currentField %d",currentField);

	CGPoint newOffset;
	if (UIDeviceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
		// portrait
		switch (currentField) {
			case 1:
				newOffset = CGPointMake(0.0f,0.0f);
				break;
			case 2:
				newOffset = CGPointMake(0.0f,35.0f);
 				break;
			default:
				if (self.methodControl.selectedSegmentIndex == 0) {
					newOffset = CGPointMake(0.0f,(keyboardSize.height-31.0f));
				} else {
					newOffset = CGPointMake(0.0f,keyboardSize.height+7.0f);
				}
				break;
		} // end switch
	} else {
		// landscpe
		switch (currentField) {
			case 1:
				newOffset = CGPointMake(0.0f,0.0f);
				break;
			case 2:
				newOffset = CGPointMake(0.0f,140.0f);
				break;
			default:
				if (self.methodControl.selectedSegmentIndex == 0) {
					newOffset = CGPointMake(0.0f,(keyboardSize.height+19.0f)); // -31
				} else {
					newOffset = CGPointMake(0.0f,keyboardSize.height+57.0f);
				}
				break;
		} //end switch
	} // end if	

	[scrollView setContentOffset:newOffset animated:YES];  
	// Keyboard is now visible
	keyboardVisible = YES;
}
#define RECTLOG(rect)    (NSLog(@""  #rect @" x:%f y:%f w:%f h:%f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height ));

-(void) keyboardWillHide: (NSNotification *)notif 
{
	// Is the keyboard already shown
	if (!keyboardVisible) 
	{
		NSLog(@"Keyboard is already hidden. Ignoring notification.");
		return;
	}

	// Reset the height of the scroll view to its original value
	UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
	if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
		scrollView.frame = CGRectMake(0, 0, SCROLLVIEW_WIDTH_LANDSCAPE, SCROLLVIEW_HEIGHT_LANDSCAPE);
    }
    else if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
		scrollView.frame = CGRectMake(0, 0, SCROLLVIEW_WIDTH_PORTRAIT, SCROLLVIEW_HEIGHT_PORTRAIT);
    }	
	
	
	// Reset the scrollview to previous location
	[scrollView setContentOffset:offset animated:YES];  
	
	// Keyboard is no longer visible
	keyboardVisible = NO;	
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	
	currentField = [textField tag];
	//NSLog(@"set current tag to: %d",[textField tag]);
	return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
	
	/*	if (textField == nameTextField) {
	 recipe.name = nameTextField.text;
	 self.navigationItem.title = recipe.name;
	 }
	 else if (textField == overviewTextField) {
	 recipe.overview = overviewTextField.text;
	 }
	 else if (textField == prepTimeTextField) {
	 recipe.prepTime = prepTimeTextField.text;
	 }
	 */
	return YES;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	currentField = 0;
	return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextField *)textField {
	
	/*	if (textField == nameTextField) {
	 recipe.name = nameTextField.text;
	 self.navigationItem.title = recipe.name;
	 }
	 else if (textField == overviewTextField) {
	 recipe.overview = overviewTextField.text;
	 }
	 else if (textField == prepTimeTextField) {
	 recipe.prepTime = prepTimeTextField.text;
	 }
	 */
	return YES;
}
- (BOOL)textViewShouldBeginEditing:(UITextField *)textField {
	
	currentField = [textField tag];
	return YES;
}

#define MAX_LENGTH 160

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)aString {
	
	if (self.methodControl.selectedSegmentIndex == 0) {
		// SMS
		
		self.maxCharLabel.text = [NSString stringWithFormat:@"%d of %d chars",(self.messageField.text.length + 1),MAX_LENGTH];

		
		NSUInteger newLength = (self.messageField.text.length + 1) + aString.length - range.length;
		return (newLength > MAX_LENGTH) ? NO : YES;

		
//		if (totalChar >= MAX_LENGTH && range.length == 0) {
//			return NO;
//		} else {
//			return YES;
//		}
		
	
	} else {
		// EMAIL
		self.maxCharLabel.text = @"";
		return YES;
	}	
}

- (IBAction) methodSegmentedControlIndexChanged {
	
	if (self.methodControl.selectedSegmentIndex == 0) {
		// SMS
		if (MAX_LENGTH < [self.messageField.text length]) {
			self.messageField.text = [self.messageField.text substringToIndex:MAX_LENGTH];
		}
		self.maxCharLabel.text = [NSString stringWithFormat:@"%d of %d chars",self.messageField.text.length,MAX_LENGTH];
	} else {
		// EMAIL
		self.maxCharLabel.text = @"";
	}	
	
	[self setHiddenState];
}

- (void) setHiddenState {

	if (self.methodControl.selectedSegmentIndex == 0) {
		// SMS
		self.subjectField.hidden = YES;
		self.subjectLabel.hidden = YES;
		self.messageField.frame = CGRectMake(self.messageField.frame.origin.x,222,self.messageField.frame.size.width,self.messageField.frame.size.height);
		self.messageLabel.frame = CGRectMake(20,190,87,24);
		self.maxCharLabel.frame = CGRectMake(190,354,157,21);
	} else {
		// Email
		self.messageField.frame = CGRectMake(self.messageField.frame.origin.x,260,self.messageField.frame.size.width,self.messageField.frame.size.height);
		self.messageLabel.frame = CGRectMake(20,228,87,24);
		self.maxCharLabel.frame = CGRectMake(190,392,157,21);
 		self.subjectField.hidden = NO;
		self.subjectLabel.hidden = NO;
	}
	
}

/*
 *  Add Contact methods
 */
- (IBAction)addContact:(id)sender {
	//NSLog(@"Add contact button pressed.");
	ABPeoplePickerNavigationController *picker =
	[[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
	
	if (self.methodControl.selectedSegmentIndex == 0) {
		// SMS
		picker.displayedProperties = [NSArray arrayWithObjects:[NSNumber numberWithInt:kABPersonPhoneProperty],[NSNumber numberWithInt:kABPersonFirstNameProperty],nil];
	} else {
		// Email
		picker.displayedProperties = [NSArray arrayWithObjects:[NSNumber numberWithInt:kABPersonEmailProperty],[NSNumber numberWithInt:kABPersonFirstNameProperty],nil];
	}
	
	
	

    [self presentModalViewController:picker animated:YES];
    [picker release];
	
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    [self dismissModalViewControllerAnimated:YES];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    return YES;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier{
	
	ABMultiValueRef newProperty = ABRecordCopyValue(person,property);
	NSString *newValue = (NSString *)ABMultiValueCopyValueAtIndex(newProperty,identifier);
	
	if ([self.toField.text length] == 0) {
		self.toField.text = [NSString stringWithFormat:@"%@",newValue];
		
	} else {
		self.toField.text = [NSString stringWithFormat:@"%@,%@",self.toField.text,newValue];
		
	}
	[newValue release];
	
    [self dismissModalViewControllerAnimated:YES];
	
    return NO;
}

- (void) adjustViewsForOrientation:(UIInterfaceOrientation)orientation {
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)dealloc {
	
	
	[scrollView release]; scrollView = nil;
	
	[managedObjectContext release];
	[messageTemplate release];
	[buttonLabelField release];
	[toField release];
	[buttonColorControl release];
	[methodControl release];
	[messageField release];
	[maxCharLabel release];
	[subjectField release];
	[subjectLabel release];
	[messageLabel release];
	
    [super dealloc];
}


@end


	
