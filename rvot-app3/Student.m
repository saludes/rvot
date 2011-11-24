//
//  Student.m
//  rvot-app3
//
//  Created by Jordi Saludes on 19/11/11.
//  Copyright (c) 2011 UPC. All rights reserved.
//

#import "Student.h"
#import "Issue.h"
#import "Marking.h"

@implementation Student

@dynamic pID;
@dynamic lName;
@dynamic fName;
@dynamic issue;
@dynamic markings;


 + (Student*)studentwithId:(NSString*)pID lastName:(NSString*)lName firstName:(NSString*)fName inContext:(NSManagedObjectContext*)context {
    Student* student = [NSEntityDescription
                        insertNewObjectForEntityForName:@"Student"
                        inManagedObjectContext:context];
    student.lName = lName;
    student.fName = fName;
    student.pID = pID;
    return student;
}

- (NSString*)collatedFullName {
    return [NSString stringWithFormat:@"%@, %@",self.lName, self.fName]; 
}

- (NSDecimalNumber*)lastGrade {
    NSArray *marks = [self.markings sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"stamp" ascending:NO]]];
    if ([marks count] > 0)
        return [[marks objectAtIndex:0] grade];
    else
        return nil;
}
@end
