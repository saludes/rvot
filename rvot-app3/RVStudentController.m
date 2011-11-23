//
//  RVStudentController.m
//  rvot-app3
//
//  Created by Jordi Saludes on 19/11/11.
//  Copyright (c) 2011 UPC. All rights reserved.
//

#import "RVStudentController.h"
#import <Cocoa/Cocoa.h>
#import "Student.h"
#import "RVAppDelegate.h"
#import "Issue.h"
#import "Student.h"

@implementation RVStudentController
@synthesize issue;


- (NSInteger)readFromURL:(NSURL *)url error:(NSError **)outError {
    //Issue* issue =(Issue*)[parent selectedInBrowser];
    if (!issue || ![issue isMemberOfClass:[Issue class]]) {
        NSLog(@"Issue not set");
        return -1;
    }
    NSString *contents = [NSString stringWithContentsOfURL:url 
                                    encoding:NSUTF8StringEncoding error:outError];
    if ( nil == contents ) return NO;
    
    NSCharacterSet *endline = [NSCharacterSet characterSetWithCharactersInString:@"\n\r"];

    NSScanner *lineScanner = [NSScanner localizedScannerWithString:contents];
    NSString* line;
    NSInteger nRecords = 0;    
    while ([lineScanner scanUpToCharactersFromSet:endline intoString:&line]) {
        if (nRecords++ <= 0) continue;
        NSLog(@"Line is: %@", line);
        NSString *idFd, *lNameFd, *fNameFd;
        NSScanner *fieldScanner = [NSScanner localizedScannerWithString:line];
        //[fieldScanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@";"]];
        if (![fieldScanner scanUpToString:@";" intoString:&idFd]) {
            NSLog(@"No pID field for line %ld", nRecords);
            return -1;
        }
        [fieldScanner setScanLocation:[fieldScanner scanLocation]+1];
        if(![fieldScanner scanUpToString:@";" intoString:&fNameFd]) {
            NSLog(@"No first name for line %ld", nRecords);
            return -1;
        }
        [fieldScanner setScanLocation:[fieldScanner scanLocation]+1];
        if (![fieldScanner scanUpToString:@";" intoString:&lNameFd]) {
            NSLog(@"No last name for line %ld", nRecords);
            return -1;
        }
        Student *student = [Student studentwithId:idFd lastName:lNameFd firstName:fNameFd inContext:self.managedObjectContext];
        student.issue = issue;
        
        NSError **err;
        [self.managedObjectContext save: err];
        if (err != noErr) NSLog(@"student save error");
    }
    return nRecords;
}



- (IBAction)loadStudents:(id)sender {
    NSError **err;

    issue = [parent selectedIssue];
    NSOpenPanel *dialog = [NSOpenPanel openPanel];
    [dialog setAllowedFileTypes:[NSArray arrayWithObject:@"csv"]];
    [dialog setAllowsMultipleSelection:NO];
    [dialog setDirectoryURL:[NSURL fileURLWithPath: NSHomeDirectory()]];
    if ([dialog runModal] != NSFileHandlingPanelOKButton) return;
        
    if ([self.arrangedObjects count] > 0) {
        NSLog(@"about to remove all %lu students", [self.arrangedObjects count]);
        [self removeObjects:self.arrangedObjects];
        [self.managedObjectContext save:err];
        if (err != noErr) NSLog(@"error removing all students");
    }
  
    if ([self readFromURL:[[dialog URLs] objectAtIndex:0] error:err] < 0) {
        if (*err)
            NSLog(@"CSV loading failed. Error %@", *err);
        else
            NSLog(@"CSV loading failed (but no error)");

    }

    [self viewStudents:self];
}

- (IBAction)viewStudents:(id)sender {
    issue = [issueCtrl selectedIssue];
    [self prepareContent];
    [window makeKeyAndOrderFront:self];
}

- (NSArray *)arrangedObjects {
    
    if (issue)
        return [issue.students sortedArrayUsingDescriptors:
         [NSArray arrayWithObject:
          [NSSortDescriptor sortDescriptorWithKey:@"lName" ascending:YES]]];
    else
        return [NSArray array];
  }

@end
