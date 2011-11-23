//
//  RVAppDelegate.h
//  rvot-app3
//
//  Created by Jordi Saludes on 08/11/11.
//  Copyright (c) 2011 UPC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

@class Issue;
@class RVStudentController, RVIssueController;




@interface IssuePanel : NSPanel {
@private
    IBOutlet NSDatePicker* dateField;
}
-(NSDate*)date;
@end

@interface CourseController : NSObjectController {
@private
      IBOutlet NSWindow *coursePanel;
}
@end





@interface RVAppDelegate : NSObject <NSApplicationDelegate> {
    IBOutlet NSBrowser  *browser;
    IBOutlet NSWindow   *coursePanel;
    IBOutlet NSWindow   *examPanel;
    IBOutlet NSWindow   *issuePanel;
    IBOutlet NSButton   *newCourseBtn;
    IBOutlet NSWindow   *docWindow;
    IBOutlet PDFView    *docView;
    IBOutlet RVStudentController *StudentCtrl;
    IBOutlet RVIssueController   *IssueCtrl;
    NSString* courseName;
    NSNumber* courseCode;
    NSString* examTitle;
    NSDate*   issueDate;
}

@property (readwrite, copy) NSNumber *selectedColumn;
@property (readwrite, copy) NSString *courseName;
@property (readwrite, copy) NSNumber *courseCode;
@property (readwrite, copy) NSString *examTitle;
@property (readwrite, copy) NSDate   *issueDate;
@property (assign) IBOutlet NSWindow *window;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (Issue*)selectedIssue;
- (NSManagedObject*)selectedInBrowser;
- (IBAction)setNewDocument:(id)sender;
- (IBAction)makeCopies:(id)sender;
- (IBAction)saveAction:(id)sender;
- (IBAction)acceptDialog:(id)sender;
- (IBAction)cancelDialog:(id)sender;
- (IBAction)createCourse:(id)sender;
- (IBAction)newItem:(id)sender;
- (IBAction)refreshBrowserView:(id)sender;
- (IBAction)tagAnnotations:(id)sender;
- (IBAction)markIssue:(id)sender;
- (NSURL*)askPdfURL;
- (void)openPdfPanelFor:(Issue*)issue making:(BOOL)make;
- (void)courseDidEndSheet:(NSWindow*)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;
- (void)examDidEndSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;
- (void)issueDidEndSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;
- (BOOL)validateMenuItem:(id)item;
@end

//@interface IsCourseColumn : NSValueTransformer 
//@end
