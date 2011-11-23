//
//  RVIssueController.h
//  rvot-app3
//
//  Created by Jordi Saludes on 20/11/11.
//  Copyright (c) 2011 UPC. All rights reserved.
//

#import <AppKit/AppKit.h>
#import <Quartz/Quartz.h>
@class Issue;
@class RVAppDelegate, SHDataMatrixReader, Student;

@interface RVIssueController : NSObjectController {
    IBOutlet RVAppDelegate* app;
    IBOutlet NSWindow   *progressPanel;
    IBOutlet NSProgressIndicator *pBar;
    IBOutlet NSProgressIndicator *pSpin;
    IBOutlet NSTextField *pLabel;
}

- (void) tagAnnotationsFrom:(NSURL*)source into:(NSURL*)destination;
- (Student*) readStudentIn:(NSPDFImageRep*)rep forExercise:(int*)nExerc using:(SHDataMatrixReader*)reader;
- (Issue*) selectedIssue;
- (NSArray*) issueStudents;
- (void) markURL:(NSURL*)source;
- (NSNumber*)getMarkFromPage:(PDFPage*)page;
- (void)writeCSVtoURL:(NSURL*)dest;
@end
