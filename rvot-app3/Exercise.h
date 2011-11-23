//
//  Exercise.h
//  rvot-app3
//
//  Created by Jordi Saludes on 18/11/11.
//  Copyright (c) 2011 UPC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Issue;

@interface Exercise : NSManagedObject
@property (nonatomic, retain) NSNumber * page;
@property (nonatomic, retain) Issue *issue;
@property (nonatomic, retain) NSSet *markings;


@end



@interface Exercise (CoreDataGeneratedAccessors)

- (void)addMarkingsObject:(NSManagedObject *)value;
- (void)removeMarkingsObject:(NSManagedObject *)value;
- (void)addMarkings:(NSSet *)values;
- (void)removeMarkings:(NSSet *)values;

@end
