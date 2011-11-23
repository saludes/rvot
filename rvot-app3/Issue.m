//
//  Issue.m
//  rvot-app3
//
//  Created by Jordi Saludes on 18/11/11.
//  Copyright (c) 2011 UPC. All rights reserved.
//

#import "Issue.h"
#import "Examination.h"
#import "Exercise.h"
#import "Student.h"
#import <Quartz/Quartz.h>
//#import "dmtx.h"
#import "SHDataMatrixWriter.h"
#import "SHDataMatrixReader.h"
#include <stdio.h>


@implementation Issue

//@synthesize pdfRef;
@dynamic date;
@dynamic document;
@dynamic exam;
@dynamic exercises;
@dynamic students;


+ (Issue*)newIssueAtDate:(NSDate*)date inContext:(NSManagedObjectContext*)context {
    Issue* issue = [NSEntityDescription insertNewObjectForEntityForName:@"Issue" inManagedObjectContext:context];
    [issue setValue:date forKey:@"date"];
    return issue;
}


- (void)makeCopiesTo:(NSURL*)destination {
    
    //NSAutoreleasePool * ARP = [[NSAutoreleasePool alloc] init];
    
    SHDataMatrixWriter *dmtxWriter = [SHDataMatrixWriter sharedDataMatrixWriter];


    
    CGPDFDocumentRef pdfRef = CGPDFDocumentCreateWithURL ((CFURLRef)self.document);
    size_t nPages = CGPDFDocumentGetNumberOfPages(pdfRef);
    size_t k;
    
    /* metaInfo = {kCGPDFContextTitle: CFSTR("Copies for " + srcPath),
            kCGPDFContextCreator: CFSTR("Jordi")}
    TODO */
         
    CGContextRef pdfContext = CGPDFContextCreateWithURL((CFURLRef)destination, NULL, NULL);
	/* progresBar.setIndeterminate_(False)
	progresBar.setMinValue_(0)
	progresBar.setMaxValue_(len(students))
	progresBar.setHidden_(False)
     
	dateFormat = NSDateFormatter.alloc().initWithDateFormat_allowNaturalLanguage_("%d-%m-%Y", False)
    TODO */
	
    NSEnumerator *students =
         [[self.students sortedArrayUsingDescriptors:
           [NSArray arrayWithObjects:
                [NSSortDescriptor sortDescriptorWithKey:@"lName" ascending:YES],
                [NSSortDescriptor sortDescriptorWithKey:@"fName" ascending:YES], nil]]
          objectEnumerator];
    Student* aStudent;
    
    while (aStudent = [students nextObject])
    	for (k=0; k < nPages; k++) {
			NSString* code = [NSString stringWithFormat:@"%@$%@$%d",
                              aStudent.pID,
                              [self.date descriptionWithCalendarFormat:@"%Y%m%d" timeZone:nil locale:nil],
                               k]; 
            NSImage *image = [dmtxWriter encodeBarcodeToImage:code];
            NSBitmapImageRep *rep = [[NSBitmapImageRep alloc] initWithData:[image TIFFRepresentation]];
            CGImageRef dmImg = [rep CGImage];

            
			CGContextBeginPage(pdfContext, NULL);
			//drawPage(pdfContext, page, dmImage, info)
                        
            CGFloat h  =  792.0;
            size_t imgWidth = CGImageGetWidth(dmImg);
            size_t imgHeight = CGImageGetHeight(dmImg);
            CGRect dmRect = CGRectMake (20, h - 10 - imgHeight,imgWidth,imgHeight);

            CGContextDrawImage (pdfContext, dmRect, dmImg);

            CGContextTranslateCTM (pdfContext, 0, -50);
            CGContextDrawPDFPage(pdfContext, CGPDFDocumentGetPage(pdfRef, k+1));
            
            // Initialize a rectangular path.
            CGMutablePathRef path = CGPathCreateMutable();
            CGRect bounds = CGRectMake(30 + imgWidth, 600.0, 200.0, 200.0);
            CGPathAddRect(path, NULL, bounds);
            
            // Initialize an attributed string.
           CFMutableAttributedStringRef attrString =
                    CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
           CFAttributedStringReplaceString (attrString,
                                            CFRangeMake(0, 0), (CFStringRef)[NSString stringWithFormat:@"%@, %@", aStudent.lName, aStudent.fName]);
           
           // Create a color and add it as an attribute to the string.
           /* CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
           CGFloat components[] = { 1.0, 0.0, 0.0, 0.8 };
           CGColorRef red = CGColorCreate(rgbColorSpace, components);
           CGColorSpaceRelease(rgbColorSpace);
           CFAttributedStringSetAttribute(attrString, CFRangeMake(0, 50),
                                          kCTForegroundColorAttributeName, red);
           */
           // Create the framesetter with the attributed string.
           CTFramesetterRef framesetter =
           CTFramesetterCreateWithAttributedString(attrString);
           CFRelease(attrString);
           
           // Create the frame and draw it into the graphics context
           CTFrameRef frame = CTFramesetterCreateFrame(framesetter,
                                                       CFRangeMake(0, 0), path, NULL);
           CFRelease(framesetter);
           CTFrameDraw(frame, pdfContext);
           CFRelease(frame);

                                        
            //CGAffineTransform myTextTransform =  CGAffineTransformMakeRotation(10*n/180.*3.1416)
            //CGContextSetTextMatrix (context, myTextTransform)
            //CGContextShowTextAtPoint(pdfContext, 100., 100., "foo", 3);
            
			CGContextEndPage(pdfContext);
            
            [rep release];
            /* progresBar.incrementBy_(1.0)
            progresBar.displayIfNeeded()
             */
        };

    CGPDFContextClose(pdfContext);
    // progresBar.setHidden_(True)
}


- (void)makeExercises:(NSUInteger)pages inContext:(NSManagedObjectContext *)context {
    for (int k=0; k < pages; k++) {
        Exercise *exerc = [NSEntityDescription
                            insertNewObjectForEntityForName:@"Exercise" inManagedObjectContext:context];
        exerc.page = [NSNumber numberWithInt:k];
        [self addExercisesObject:exerc];
    }
    
    NSError **error;
    [context save:error];
    if (error != noErr) NSLog(@"error saving new exercise");

}


- (NSUInteger)countMarkings {
    NSEnumerator *exercEnum = [self.exercises objectEnumerator];
    Exercise *anExercise;

    int nMarkings = 0;
    while (anExercise = [exercEnum nextObject])
        nMarkings += [anExercise.markings count];
    
    return nMarkings;
}


- (void)removeAllMarkingsUsing:(NSManagedObjectContext*)context {
        
        
    // Remove them
    NSEnumerator *exercEnum = [self.exercises objectEnumerator];
    Exercise *anExercise;
    while (anExercise = [exercEnum nextObject])
        [anExercise removeMarkings:[anExercise markings]];
    NSError **error;
    [context save:error];
    if (error != noErr)
        NSLog(@"failed removing old markings.");

}
@end
