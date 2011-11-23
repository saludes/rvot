//
//  Examination.m
//  rvot-app3
//
//  Created by Jordi Saludes on 10/11/11.
//  Copyright (c) 2011 UPC. All rights reserved.
//

#import "Examination.h"
#import "Course.h"


@implementation Examination

@dynamic title;
@dynamic weigth;
@dynamic course;
@dynamic issues;

+ (Examination*)newWithTitle:(NSString*)name inContext:(NSManagedObjectContext *)context {
    Examination *exam = [NSEntityDescription insertNewObjectForEntityForName:@"Examination" inManagedObjectContext:context];
    [exam setValue:name forKey:@"title"];
    [exam setValue:[NSNumber numberWithFloat:1.0] forKey:@"weight"];
    return exam;
}

- (Issue*)issueAtIndex:(NSInteger)index inContext:(NSManagedObjectContext *)context {
    NSSortDescriptor* byDateAsc = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    return [[self.issues sortedArrayUsingDescriptors:[NSArray arrayWithObject:byDateAsc]]  objectAtIndex:index];
}
@end
