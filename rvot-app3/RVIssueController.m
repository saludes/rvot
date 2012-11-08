//
//  RVIssueController.m
//  rvot-app3
//
//  Created by Jordi Saludes on 20/11/11.
//  Copyright (c) 2011 UPC. All rights reserved.
//

#import "RVIssueController.h"
#import "Issue.h"
#import "Exercise.h"
#import "Student.h"
#import "RVAppDelegate.h"
#import "SHDataMatrixReader.h"
#import "Marking.h"


@implementation RVIssueController


- (Issue*)selectedIssue {
    Issue* issue = (Issue*)[app selectedInBrowser];
    if ([issue isMemberOfClass:[Issue class]]) {
        return issue;
    }
    return nil;
}

- (NSArray*)issueStudents {
    Issue *issue = [self selectedIssue];
    if (issue)
        return [issue.students sortedArrayUsingDescriptors:
                    [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"lName" ascending:YES]]];
    else    
        return [NSArray array];
}


- (Student*)readStudentIn:(NSPDFImageRep*)rep forExercise:(int*)nExerc using:(SHDataMatrixReader*)reader {
#define RELBOX (0.2)
#define WRITEPNG 0
    Issue *issue = self.selectedIssue;
    NSAssert(issue, @"No issue selected");
    CGFloat h = [rep bounds].size.height;
    NSString* issueFmtDate = [issue.date descriptionWithCalendarFormat:@"%Y%m%d" timeZone:nil locale:nil];
    NSRect srcRect = NSMakeRect( 0.,h*(1-RELBOX),h*RELBOX, h*RELBOX); //NSMakeRect(10.0, 670.0, BOX, BOX);
    NSRect trgRect = NSMakeRect(0.0, 0.0, h*RELBOX, h*RELBOX);
    NSImage* srcImg = [[NSImage alloc] initWithSize:[rep size]];
    NSImage* dmtxImg = [[NSImage alloc] initWithSize:trgRect.size];
    [srcImg addRepresentation:rep];
    [dmtxImg lockFocus];
    [srcImg drawInRect:trgRect fromRect:srcRect operation:NSCompositeCopy fraction:1.0];
    [dmtxImg unlockFocus];
    
    
     
#if (WRITEPNG == 1)
    NSBitmapImageRep *bmpImageRep = [[NSBitmapImageRep alloc]initWithData:[dmtxImg TIFFRepresentation]];
    [dmtxImg addRepresentation:bmpImageRep];
    NSData *data = [bmpImageRep representationUsingType: NSPNGFileType properties: nil];
    [data writeToFile: @"/Users/saludes/Desktop/crop.png" atomically: NO];
    [bmpImageRep release];
#endif
    
    NSString * decodedMessage = [reader decodeBarcodeFromImage:dmtxImg];
    [dmtxImg release];
    [srcImg release];
    if (!decodedMessage) return nil;
    NSArray *fields = [decodedMessage componentsSeparatedByString:@"$"];
    NSString *pID  = [fields objectAtIndex:0];
    NSAssert([issueFmtDate compare:[fields objectAtIndex:1]]==NSOrderedSame, @"Not in this issue!");
    *nExerc = [[fields objectAtIndex:2] intValue];
    
    NSSet *filtered = [[NSSet setWithArray:[self issueStudents]] filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"pID == %@", pID]];
    NSAssert([filtered count] == 1, @"Not a unique pID %@ or nonexistent.", pID);
    return [filtered anyObject];
}


- (void)tagAnnotationsFrom:(NSURL*)source into:(NSURL*)targetURL {
    Issue *issue = self.selectedIssue;
    PDFDocument *doc = [[PDFDocument alloc] initWithURL:source];
    NSLog(@"About to tag document with %lu pages.", [doc pageCount]);
    NSAssert([doc pageCount]%2 == 0, @"Odd number of pages");
    
    SHDataMatrixReader *reader = [SHDataMatrixReader sharedDataMatrixReader];
    
    
    NSData* data = [NSData dataWithContentsOfURL:source];
    NSPDFImageRep* pdfRep = [NSPDFImageRep imageRepWithData:data];
    
    NSMutableDictionary* destinations = [NSMutableDictionary
                                         dictionaryWithCapacity:[issue.students count]];
    
    [pBar setMaxValue:doc.pageCount];
    [pLabel setStringValue:@"What page?"];
    [progressPanel makeKeyAndOrderFront:self];
    [pBar startAnimation:self];
    
    NSPoint tagPoint = NSMakePoint(10.0, 730.0); // Put destination here on page
    for (int k=0; k < doc.pageCount; k += 2) {
        PDFPage *page = [doc pageAtIndex:k];
        int nExerc;
        [pdfRep setCurrentPage:k];
        //[pBar displayIfNeeded];
        Student* aStudent = [self readStudentIn:pdfRep forExercise:&nExerc using:reader];
        if (aStudent) {
            NSLog(@"Got '%@' at page %d.", [aStudent collatedFullName], k+1);
            [pLabel setStringValue:[aStudent collatedFullName]];
            PDFDestination *aDest = [[PDFDestination alloc] initWithPage:page atPoint:tagPoint];
            NSAssert(aDest, @"No PDF destination");
            [destinations setValue:aDest forKey:[aStudent collatedFullName]];
        } else {
            NSLog(@"No datamatrix at page %d.", k+1);
        }
        //[pBar incrementBy:2.0];
        [pBar setDoubleValue:k];
        [progressPanel displayIfNeeded];
    }
    [pBar stopAnimation:self];
    NSArray* allPids = [[destinations allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    [pSpin startAnimation:self];
    NSEnumerator *studentEnum = [allPids objectEnumerator];;
    PDFOutline *outline = [[PDFOutline alloc] init];
    NSString *aName;
    [doc setOutlineRoot:outline];
    while (aName = [studentEnum nextObject]) {
        PDFOutline *child = [[PDFOutline alloc] init];
        [outline insertChild:child atIndex:[outline numberOfChildren]];
        [child setLabel:aName];
        [child setDestination:[destinations objectForKey:aName]];
    }
    [doc writeToURL:targetURL];
    [pSpin stopAnimation:self];
    [progressPanel orderOut:self];
    [outline release];
    [doc release];
}

- (void) markURL:(NSURL*)source {
    Issue *issue = self.selectedIssue;
    NSAssert(issue.exercises, @"No exercises set for this issue.");
        
    
    PDFDocument *doc = [[PDFDocument alloc] initWithURL:source];
    NSLog(@"About to mark document with %lu pages.", [doc pageCount]);
    NSAssert([doc pageCount]%2 == 0, @"Odd number of pages");
    
    SHDataMatrixReader *reader = [SHDataMatrixReader sharedDataMatrixReader];
    
    
    NSData* data = [NSData dataWithContentsOfURL:source];
    NSPDFImageRep* pdfRep = [NSPDFImageRep imageRepWithData:data];
    NSArray *exercises = [issue.exercises
                         sortedArrayUsingDescriptors:
                            [NSArray arrayWithObject:
                                [NSSortDescriptor sortDescriptorWithKey:@"page" ascending:YES]]];
    
    [pBar setMaxValue:doc.pageCount];
    [pLabel setStringValue:@"What page?"];
    [progressPanel makeKeyAndOrderFront:self];
    [pBar startAnimation:self];
    
    for (int k=0; k < doc.pageCount; k += 2) {
        int nExercise;
        PDFPage *page = [doc pageAtIndex:k];
        [pdfRep setCurrentPage:k];        
        Student* aStudent = [self readStudentIn:pdfRep forExercise:&nExercise using:reader];
        if (!aStudent) {
            NSLog(@"No student in page. Skipping.");
            continue;
        }
        NSNumber *mark = [self getMarkFromPage:page];
        if (!mark) {
            NSAlert *alert = [NSAlert alertWithMessageText:@"No mark found" defaultButton:nil alternateButton: nil otherButton:nil informativeTextWithFormat:@"No marking at page %d for  '%@'", k+1, [aStudent collatedFullName]];
            [alert runModal];
            continue;
        }
        
        Marking* marking = [NSEntityDescription
                                    insertNewObjectForEntityForName:@"Marking"
                                   inManagedObjectContext:app.managedObjectContext];
        NSError *err;
        marking.student = aStudent;
        marking.exercise = [exercises objectAtIndex:nExercise];
        marking.grade = [NSDecimalNumber decimalNumberWithDecimal:[mark decimalValue]];
        marking.stamp = [NSDate date];
      
        [app.managedObjectContext save:&err];
        if (err != noErr) NSLog(@"marking save error");

        [pBar setDoubleValue:k];
        [pLabel setStringValue:[NSString stringWithFormat:@"Marking #%d for %@", nExercise+1, [aStudent collatedFullName]]];
        [progressPanel displayIfNeeded];
    }
    [pBar stopAnimation:self];
    [progressPanel orderOut:self];
    [doc release];
}


- (NSNumber*)getMarkFromPage:(PDFPage*)page {
    float mark;
    NSEnumerator* annotations = [[page annotations] objectEnumerator];
    PDFAnnotation* aNote;
    while (aNote = [annotations nextObject]) {
        if ([aNote.type compare:@"Text"] != NSOrderedSame) continue;
        if([[NSScanner scannerWithString:aNote.contents] scanFloat:&mark]) { // annotation mark
            NSAssert(aNote.bounds.origin.y > 600.0 , @"Mark-like annotation not at page top.");
            return [NSNumber numberWithFloat:mark];
        }
    }
    return nil; // No marking found
}


- (void)writeCSVtoURL:(NSURL*)dest {
    NSEnumerator *exercises = [self.selectedIssue.exercises objectEnumerator];
    Exercise *anExercise;
    NSError **error;
    [[NSFileManager defaultManager] createFileAtPath:[dest path] contents:nil attributes:nil];
    NSFileHandle *handle = [NSFileHandle fileHandleForWritingToURL:dest error:error];
    
    while (anExercise = [exercises nextObject]) {
        NSEnumerator *markings = [anExercise.markings objectEnumerator];
        Marking *aMarking;
        while (aMarking = [markings nextObject]) {
            NSString *row = [NSString localizedStringWithFormat:@"\"%@\";%@;%@;\"%@\"\n",
             aMarking.student.pID, aMarking.exercise.page, aMarking.grade, aMarking.stamp];
            [handle writeData:[NSData dataWithBytes:[row cStringUsingEncoding:NSUTF8StringEncoding] length:[row length]]];
            //NSLog(@"Row %d: %@", ++k, row);
        }
    }
    [handle synchronizeFile];
    [handle closeFile];
    NSLog(@"CSV file closed");
}

@end
