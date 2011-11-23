//
//  Course.h
//  rvot-app3
//
//  Created by Jordi Saludes on 10/11/11.
//  Copyright (c) 2011 UPC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Examination.h"


@interface Course : NSManagedObject

@property (nonatomic) int16_t code;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *exams;
@end

@interface Course (CoreDataGeneratedAccessors)

+ (NSArray*)allCourses:(NSManagedObjectContext*)context;
+ (Course*)withName:(NSString*)name inContext:(NSManagedObjectContext*)context;
- (Examination*)examWithName:(NSString*)name inContext:(NSManagedObjectContext*)context;
- (void)addExamsObject:(NSManagedObject *)value;
- (void)removeExamsObject:(NSManagedObject *)value;
- (void)addExams:(NSSet *)values;
- (void)removeExams:(NSSet *)values;

@end
