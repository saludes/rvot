//
//  Marking.h
//  rvot-app3
//
//  Created by Jordi Saludes on 23/11/11.
//  Copyright (c) 2011 UPC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Exercise, Student;

@interface Marking : NSManagedObject

@property (nonatomic, retain) NSDecimalNumber * grade;
@property (nonatomic, retain) NSDate * stamp;
@property (nonatomic, retain) Exercise *exercise;
@property (nonatomic, retain) Student *student;

@end
