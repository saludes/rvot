//
//  RVStudentController.h
//  rvot-app3
//
//  Created by Jordi Saludes on 19/11/11.
//  Copyright (c) 2011 UPC. All rights reserved.
//

#import <AppKit/AppKit.h>
@class  RVAppDelegate;
@class RVIssueController;
@class Issue;

@interface RVStudentController : NSArrayController {
    IBOutlet RVAppDelegate *parent;
    IBOutlet NSWindow      *window;
    IBOutlet RVIssueController *issueCtrl;
    Issue* issue;
}

@property (readwrite, copy) Issue *issue;

- (IBAction)loadStudents:(id)sender;
- (IBAction)viewStudents:(id)sender;
- (NSArray *)arrangedObjects;

@end
