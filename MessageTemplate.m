// 
//  MessageTemplate.m
//  AwesomeNotifier
//
//  Created by DON SPENCE on 1/17/11.
//  Copyright 2011 Light-Media.org. All rights reserved.
//

#import "MessageTemplate.h"


@implementation MessageTemplate 

@dynamic messageText;
@dynamic messageSubject;
@dynamic deliveryMethod;
@dynamic buttonColor;
@dynamic contactList;
@dynamic buttonText;
@dynamic displayOrder;


+ (void)createDefaultsInContext:(NSManagedObjectContext *)managedObjectContext
{
	// Check the default to see if it has already been done
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	NSString *stringVal = [prefs objectForKey:@"hasDefaults"];
	
	
	if ([stringVal isEqualToString:@"done"]) {
		return;
	}
	
	// Add defaults
	MessageTemplate *newMessageTemplate1 = (MessageTemplate *)[NSEntityDescription insertNewObjectForEntityForName:@"MessageTemplate" 
																							inManagedObjectContext:managedObjectContext];
	newMessageTemplate1.deliveryMethod = [NSNumber numberWithInt:0];
	newMessageTemplate1.buttonColor = [NSNumber numberWithInt:0];
	newMessageTemplate1.displayOrder = [NSNumber numberWithInt:0];
	
	newMessageTemplate1.buttonText = @"Working on it.";
	newMessageTemplate1.messageText = @"Got the alert. I'm working on it.";
	
	MessageTemplate *newMessageTemplate2 = (MessageTemplate *)[NSEntityDescription insertNewObjectForEntityForName:@"MessageTemplate" 
																							inManagedObjectContext:managedObjectContext];
	newMessageTemplate2.deliveryMethod = [NSNumber numberWithInt:0];
	newMessageTemplate2.buttonColor = [NSNumber numberWithInt:1];
	newMessageTemplate2.displayOrder = [NSNumber numberWithInt:1];
	
	newMessageTemplate2.buttonText = @"Too busy.";
	newMessageTemplate2.messageText = @"Got the alert. Too busy to respond.";
	
	MessageTemplate *newMessageTemplate3 = (MessageTemplate *)[NSEntityDescription insertNewObjectForEntityForName:@"MessageTemplate" 
																							inManagedObjectContext:managedObjectContext];
	newMessageTemplate3.deliveryMethod = [NSNumber numberWithInt:0];
	newMessageTemplate3.buttonColor = [NSNumber numberWithInt:2];
	newMessageTemplate3.displayOrder = [NSNumber numberWithInt:2];
	
	newMessageTemplate3.buttonText = @"On my way home.";
	newMessageTemplate3.messageText = @"On my way home. Should I pick anything up?";
	
	MessageTemplate *newMessageTemplate4 = (MessageTemplate *)[NSEntityDescription insertNewObjectForEntityForName:@"MessageTemplate" 
																							inManagedObjectContext:managedObjectContext];
	newMessageTemplate4.deliveryMethod = [NSNumber numberWithInt:0];
	newMessageTemplate4.buttonColor = [NSNumber numberWithInt:3];
	newMessageTemplate4.displayOrder = [NSNumber numberWithInt:3];
	
	newMessageTemplate4.buttonText = @"Party at my place tonight!";
	newMessageTemplate4.messageText = @"Party at my place tonight!";
	
	

	// Save
	NSError *error;
	if (![managedObjectContext save:&error]) {
		// Update to handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
	
	
	// Save value to prefs
	[prefs setObject:@"done" forKey:@"hasDefaults"];
	[prefs synchronize];

}


- (void) save {
	
	
}




@end






