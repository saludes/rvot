//
//  Issue.h
//  rvot-app3
//
//  Created by Jordi Saludes on 18/11/11.
//  Copyright (c) 2011 UPC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <Quartz/Quartz.h>

@class SHDataMatrixReader;
@class Examination, Exercise, Student;

@interface Issue : NSManagedObject {
//   CGPDFDocumentRef pdfRef;
//    IBOutlet NSProgressIndicator    *_saveProgressBar;          // Saving.
//    IBOutlet NSPanel                *_saveWindow;
//    IBOutlet NSSegmentedControl     *_editTestButton;
}

+ (Issue*)newIssueAtDate:(NSDate*)date inContext:(NSManagedObjectContext*)context;
- (void)makeCopiesTo:(NSURL*)destination;


//@property CGPDFDocumentRef pdfRef;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) id document;
@property (nonatomic, retain) Examination *exam;
@property (nonatomic, retain) NSSet *exercises;
@property (nonatomic, retain) NSSet *students;
@end

@interface Issue (CoreDataGeneratedAccessors)

- (void)addExercisesObject:(Exercise *)value;
- (void)removeExercisesObject:(Exercise *)value;
- (void)addExercises:(NSSet *)values;
- (void)removeExercises:(NSSet *)values;
- (NSUInteger)countMarkings;
- (void)removeAllMarkingsUsing:(NSManagedObjectContext*)context;

- (void)addStudentsObject:(NSManagedObject *)value;
- (void)removeStudentsObject:(NSManagedObject *)value;
- (void)addStudents:(NSSet *)values;
- (void)removeStudents:(NSSet*)values;
- (void)makeExercises:(NSUInteger)pages inContext:(NSManagedObjectContext*)context;
@end
