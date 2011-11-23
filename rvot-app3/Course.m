//
//  Course.m
//  rvot-app3
//
//  Created by Jordi Saludes on 10/11/11.
//  Copyright (c) 2011 UPC. All rights reserved.
//

#import "Course.h"


@implementation Course

@dynamic code;
@dynamic name;
@dynamic exams;


+ (NSArray*)allCourses:(NSManagedObjectContext *)context{
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    NSError *error;
    [request setEntity:[NSEntityDescription
                        entityForName:@"Course"
                        inManagedObjectContext:context]];
    return [context executeFetchRequest:request error:&error];
}

+ (Course*)withName:(NSString*)name inContext:(NSManagedObjectContext*)context {
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    NSError *error;
    [request setEntity:[NSEntityDescription entityForName:@"Course" inManagedObjectContext:context]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"name == %@", name]];
    NSArray* courses = [context executeFetchRequest:request error:&error];
    if (courses.count > 1) {
        NSLog(@"Not unique course name %@", name);
        return nil;
    } else if (courses.count == 0) {
        NSLog(@"Course with name %@ not found", name);
        return nil;
    } else {
        return [courses objectAtIndex:0];
    }
}

- (Examination*)examWithName:(NSString*)name inContext:(NSManagedObjectContext*)context {
    NSSet *exams = [self.exams filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"title == %@", name]];
    if (exams.count > 1) {
        NSLog(@"More than one exam with name %@ belongs to the course", name);
        return nil;
    } else if (exams.count == 0) {
        NSLog(@"No exams with name %@ belong to the course", name);
        return nil;
    } else {
        return (Examination*)[exams anyObject];
    }
}
@end
