//
//  Examination.h
//  rvot-app3
//
//  Created by Jordi Saludes on 10/11/11.
//  Copyright (c) 2011 UPC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Issue.h"

@class Course;

@interface Examination : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * weigth;
@property (nonatomic, retain) Course *course;
@property (nonatomic, retain) NSSet *issues;
@end

@interface Examination (CoreDataGeneratedAccessors)
+ (Examination*)newWithTitle:(NSString*)title inContext:(NSManagedObjectContext*)context;
- (Issue*)issueAtIndex:(NSInteger)index inContext:(NSManagedObjectContext*)context;
- (void)addIssuesObject:(NSManagedObject*)value;
- (void)removeIssuesObject:(NSManagedObject *)value;
- (void)addIssues:(NSSet *)values;
- (void)removeIssues:(NSSet *)values;

@end
