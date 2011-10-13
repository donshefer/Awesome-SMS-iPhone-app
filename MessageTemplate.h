//
//  MessageTemplate.h
//  AwesomeNotifier
//
//  Created by DON SPENCE on 1/17/11.
//  Copyright 2011 Light-Media.org. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface MessageTemplate :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * buttonColor;
@property (nonatomic, retain) NSString * buttonText;
@property (nonatomic, retain) NSString * contactList;
@property (nonatomic, retain) NSNumber * deliveryMethod;
@property (nonatomic, retain) NSString * messageText;
@property (nonatomic, retain) NSString * messageSubject;
@property (nonatomic, retain) NSNumber * displayOrder;


@end

