//
//  Student.h
//  rvot-app3
//
//  Created by Jordi Saludes on 19/11/11.
//  Copyright (c) 2011 UPC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Issue;

@interface Student : NSManagedObject

@property (nonatomic, retain) NSString * pID;
@property (nonatomic, retain) NSString * lName;
@property (nonatomic, retain) NSString * fName;
@property (nonatomic, retain) Issue *issue;
@property (nonatomic, retain) NSSet *markings;

- (NSString*)collatedFullName;
@end

@interface Student (CoreDataGeneratedAccessors)

+ (Student*)studentwithId:(NSString*)pID lastName:(NSString*)lName firstName:(NSString*)fName inContext:(NSManagedObjectContext*)context;
- (void)addMarkingsObject:(NSManagedObject *)value;
- (void)removeMarkingsObject:(NSManagedObject *)value;
- (void)addMarkings:(NSSet *)values;
- (void)removeMarkings:(NSSet *)values;

@end
