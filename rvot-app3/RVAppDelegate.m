//
//  RVAppDelegate.m
//  rvot-app3
//
//  Created by Jordi Saludes on 08/11/11.
//  Copyright (c) 2011 UPC. All rights reserved.
//

#import "RVAppDelegate.h"
#import "Course.h"
#import "Examination.h"
#import "Issue.h"
#import "RVIssueController.h"

@implementation RVAppDelegate

@synthesize courseCode, courseName, examTitle, issueDate, selectedColumn;
@synthesize window = _window;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize managedObjectContext = __managedObjectContext;

- (void)dealloc
{
    [__persistentStoreCoordinator release];
    [__managedObjectModel release];
    [__managedObjectContext release];
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    [browser setTitle:@"assignatura" ofColumn:0];
    [browser setTitle:@"examen" ofColumn:1];
    [browser setTitle:@"curs" ofColumn:2];
    [browser setDoubleAction:@selector(newItem:)];
    
}

/**
    Returns the directory the application uses to store the Core Data store file. This code uses a directory named "rvot_app3" in the user's Library directory.
 */
- (NSURL *)applicationFilesDirectory {

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *libraryURL = [[fileManager URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject];
    return [libraryURL URLByAppendingPathComponent:@"Rvot"];
}

/**
    Creates if necessary and returns the managed object model for the application.
 */
- (NSManagedObjectModel *)managedObjectModel {
    if (__managedObjectModel) {
        return __managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"rvot_app3" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return __managedObjectModel;
}

/**
    Returns the persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (__persistentStoreCoordinator) {
        return __persistentStoreCoordinator;
    }

    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
    NSError *error = nil;
    
    NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:[NSArray arrayWithObject:NSURLIsDirectoryKey] error:&error];
        
    if (!properties) {
        BOOL ok = NO;
        if ([error code] == NSFileReadNoSuchFileError) {
            ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (!ok) {
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    else {
        if ([[properties objectForKey:NSURLIsDirectoryKey] boolValue] != YES) {
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]]; 
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
            
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    
    NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"rvot_app3.storedata"];
    NSPersistentStoreCoordinator *coordinator = [[[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom] autorelease];
    if (![coordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]) {
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    __persistentStoreCoordinator = [coordinator retain];

    return __persistentStoreCoordinator;
}

/**
    Returns the managed object context for the application (which is already
    bound to the persistent store coordinator for the application.) 
 */
- (NSManagedObjectContext *)managedObjectContext {
    if (__managedObjectContext) {
        return __managedObjectContext;
    }

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    __managedObjectContext = [[NSManagedObjectContext alloc] init];
    [__managedObjectContext setPersistentStoreCoordinator:coordinator];

    return __managedObjectContext;
}

/**
    Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
 */
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    return [[self managedObjectContext] undoManager];
}

/**
    Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
 */
- (IBAction)saveAction:(id)sender {
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }

    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {

    // Save changes in the application's managed object context before the application terminates.

    if (!__managedObjectContext) {
        return NSTerminateNow;
    }

    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }

    if (![[self managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }

    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {

        // Customize this code block to include application-specific recovery steps.              
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }

        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[[NSAlert alloc] init] autorelease];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];

        NSInteger answer = [alert runModal];
        
        if (answer == NSAlertAlternateReturn) {
            return NSTerminateCancel;
        }
    }

    return NSTerminateNow;
}

 - (id)rootItemForBrowser:(NSBrowser *)browser {
     return nil;
}


- (NSInteger)browser:(NSBrowser *)browser numberOfChildrenOfItem:(id)item {
    if (item == nil)
        return [[Course allCourses:[self managedObjectContext]] count];
    
    NSManagedObject* mitem = item;
    if ([mitem isMemberOfClass:[Course class]])
        return [[(Course*)item exams] count];
    if ([mitem isMemberOfClass:[Examination class]])
        return [[(Examination*)item issues] count];
    if ([mitem isMemberOfClass:[Issue class]])
        return 0;
    NSLog(@"No a valid class");
    return 0;
}

NSArray* sortAscending(NSString* key);



NSArray* sortAscending(NSString* key) {
    return [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:key ascending:YES]];
}

- (NSManagedObject*)selectedInBrowser {
    //NSBrowser* browser = [self browser];
    NSInteger column = [browser selectedColumn];
    if (column < 0) return nil;
    id selected = [browser selectedCellInColumn:0];
    if (!selected) return nil;
    Course* course = [Course withName:[selected stringValue] inContext:self.managedObjectContext];
    if (column == 0) return (NSManagedObject*)course;
    
    selected = [browser selectedCellInColumn:1];
    if (!selected) return nil;
    Examination* exam = [course examWithName:[selected stringValue] inContext:self.managedObjectContext];
    if (column  == 1) return (NSManagedObject*)exam;
    
    Issue* issue = [exam issueAtIndex:[browser selectedRowInColumn:2] inContext:self.managedObjectContext];
    if (column == 2) return (NSManagedObject*)issue;
    NSLog(@"No such column");
    return nil;
}


- (id)browser:(NSBrowser *)browser child:(NSInteger)index ofItem:(id)item {
    NSManagedObject* mitem = item;
    
    if (mitem == nil) // Root
        return [[Course allCourses:[self managedObjectContext]] objectAtIndex:index];
    
    if ([mitem isMemberOfClass:[Course class]]) 
        return [[[(Course*)mitem exams] sortedArrayUsingDescriptors:sortAscending(@"title")] objectAtIndex:index];
    
    if ([mitem isMemberOfClass:[Examination class]])
    return [(Examination*)mitem issueAtIndex:index inContext:[self managedObjectContext]];
    
    return nil; // Issue
}

- (BOOL)browser:(NSBrowser *)browser isLeafItem:(id)item {
    NSManagedObject* mitem = item;
    if (item == nil)
        return NO;
    return !([mitem isMemberOfClass:[Course class]] || [mitem isMemberOfClass:[Examination class]]);
}

- (id)browser:(NSBrowser *)browser objectValueForItem:(id)item {
    NSManagedObject* mitem = item;
    if (mitem == nil)
        return @"none";
    if ([mitem isMemberOfClass:[Course class]])
        return ((Course*)mitem).name;
    if ([mitem isMemberOfClass:[Examination class]])
        return ((Examination*)mitem).title;
    if ([mitem isMemberOfClass:[Issue class]])
        return ((Issue*)mitem).date;
    NSLog(@"Not a valid class");
    return nil;
}



- (IBAction)createCourse:(id)sender{    
    [NSApp beginSheet:coursePanel
       modalForWindow:[self window]
    modalDelegate:self
       didEndSelector:@selector(courseDidEndSheet:returnCode:contextInfo:)
          contextInfo:nil];
}


- (void)courseDidEndSheet:(NSWindow*)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {
    if (returnCode != NSOKButton) return;
    
    NSError **err;
    NSManagedObject* course = [NSEntityDescription
                               insertNewObjectForEntityForName:@"Course"
                               inManagedObjectContext:[self managedObjectContext]];
    [course setValue:courseName forKey:@"name"] ;
    [course setValue:courseCode forKey:@"code"];
    [[self managedObjectContext] save: err];
    if (err != noErr) NSLog(@"course save error");
}

- (void)examDidEndSheet:(NSWindow*)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {
    if (returnCode != NSOKButton) return;
    
    NSManagedObjectContext* context = [self managedObjectContext];
    NSError **err;
    Examination* exam = [Examination newWithTitle:examTitle inContext:context];
    NSString* parentname = [[[browser selectedCells] objectAtIndex:0] stringValue];
    Course* parent = [Course withName:parentname inContext:context];
    exam.course = parent;
    [context save: err];
    if (err != noErr) NSLog(@"exam save error");
}


- (void)issueDidEndSheet:(IssuePanel*)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {
    if (returnCode != NSOKButton) return;
    
    NSError **err;
    NSManagedObjectContext *context = [self managedObjectContext];
    Issue* issue = [Issue newIssueAtDate:issueDate inContext:context];
    NSString* pName = [[[browser selectedCells] objectAtIndex:0] stringValue];
    NSString* ppName = [[browser selectedCellInColumn:0] stringValue];
    Course* pp = [Course withName:ppName inContext:context];
    Examination* p = [pp examWithName:pName inContext:context];
    issue.exam = p;
    [context save:err];
    if (err != noErr) NSLog(@"issue save error");
}

- (IBAction)acceptDialog:(id)sender {
	[NSApp endSheet:[sender window] returnCode:NSOKButton];
    [[sender window] orderOut:self];

}

- (IBAction)cancelDialog:(id)sender {
    [NSApp endSheet:[sender window] returnCode:NSCancelButton];
    [[sender window] orderOut:self];
}


-(IBAction)newItem:(id)sender {
    Issue* issue;
    switch ([(NSBrowser*)sender selectedColumn]) {
        case 0:  // New Examination
            [NSApp beginSheet:examPanel modalForWindow:[self window] modalDelegate:self didEndSelector:@selector(examDidEndSheet:returnCode:contextInfo:) contextInfo:nil];
            return;
        case 1: // New issue
            [NSApp beginSheet:issuePanel modalForWindow:[self window] modalDelegate:self didEndSelector:@selector(issueDidEndSheet:returnCode:contextInfo:) contextInfo:nil];
            return;
        case 2: // Open pdf panel
            issue = (Issue*)[self selectedInBrowser];
            NSLog(@"Selected issue for date %@", issue.date);
            if (!issue.document) 
                [self setNewDocument:self];
            else
                [self openPdfPanelFor:issue making:NO];
    }
    NSLog(@"Selected column %ld", [(NSBrowser*)sender selectedColumn]);
    [_window displayIfNeeded];
}


- (IBAction) refreshBrowserView:(id)sender {
    NSString* wTitle = @"";
    switch (browser.selectedColumn) {
        case 2: // Issue column
            wTitle = [NSString stringWithFormat: @" / %@", [[browser selectedCellInColumn:2] stringValue]];
        case 1:
            wTitle = [NSString stringWithFormat:@" / %@%@", [[browser selectedCellInColumn:1] stringValue], wTitle];
        case 0: // Course column
            wTitle = [NSString stringWithFormat:@"%@%@", [[browser selectedCellInColumn:0] stringValue], wTitle];
        }
    [newCourseBtn setEnabled:(browser.selectedColumn == 0)];
    [[self window] setTitle:wTitle];
}

- (void)openPdfPanelFor:(Issue*)issue making:(BOOL)make {
    PDFDocument     *pdfDoc;
    
    // Create PDFDocument.
    pdfDoc = [[PDFDocument alloc] initWithURL: issue.document];
        // Set document.
    [docView setDocument: pdfDoc];
    
    // Set issue exercises
    if (make) {
        [issue makeExercises:[pdfDoc pageCount] inContext:self.managedObjectContext];
    }
    
    [pdfDoc release];
    
    // Default display mode.
    [docView setAutoScales: YES];
    [docWindow orderFront:self]; 
    
}   


- (IBAction)makeCopies:(id)sender  {
    Issue* issue = (Issue*)[self selectedInBrowser];
    if (!issue) return;
    
    NSSavePanel *dialog = [NSSavePanel savePanel];
    [dialog setTitle:@"Save copies into"];
    [dialog setAllowedFileTypes:[NSArray arrayWithObject:@"pdf"]];
    [dialog setDirectoryURL:[NSURL fileURLWithPath: NSHomeDirectory()]];
    if ([dialog runModal] != NSFileHandlingPanelOKButton) return;
    NSLog(@"About to make copies to %@", [dialog URL]);
    [issue makeCopiesTo:[dialog URL]];
}

- (BOOL)validateMenuItem:(id)item {
    // NSLog(@"Menu item:%@", [item title]);
    Issue* issue = [self selectedIssue];
    if (issue) {
        if (issue.document && [[item title] rangeOfString:@"copies"].location != NSNotFound) return YES;
        if ([[item title] rangeOfString:@"annotations"].location != NSNotFound) return YES;
        if (issue.document && [[item title] rangeOfString:@"Markings"].location != NSNotFound) return YES;
        return YES;
    }
    return NO;
}

- (Issue*)selectedIssue {
    Issue* issue = (Issue*)[self selectedInBrowser];
    if (issue && [issue isMemberOfClass:[Issue class]])
        return issue;
    else
        return nil;
}

- (NSURL*)askPdfURL {
    NSOpenPanel *dialog = [NSOpenPanel openPanel];
    [dialog setAllowedFileTypes:[NSArray arrayWithObject:@"pdf"]];
    [dialog setAllowsMultipleSelection:NO];
    [dialog setDirectoryURL:[NSURL fileURLWithPath: NSHomeDirectory()]];
    if ([dialog runModal] == NSFileHandlingPanelOKButton)
        return [[dialog URLs] objectAtIndex:0];
    return nil;
}


- (IBAction)tagAnnotations:(id)sender {
    Issue* issue = [self selectedIssue];
    if (!issue) return;
    NSURL *source = [self askPdfURL];
    if (!source) return;
    
    NSURL *destination = [NSURL URLWithString:
            [NSString
                stringWithFormat:@"%@-tagged.pdf",
             [[source URLByDeletingPathExtension] absoluteString]]];
    NSLog(@"About to tag into %@", destination);
    [IssueCtrl tagAnnotationsFrom:source into:destination];
}

- (IBAction)markIssue:(id)sender {
    Issue* issue = self.selectedIssue;
    if ([issue countMarkings] > 0) {        
        NSAlert *alert = [[[NSAlert alloc] init] autorelease];
        [alert setMessageText:@"Existing markings"];
        [alert
         setInformativeText:[NSString
                             stringWithFormat:@"This issue has already %d markings. Remove them?", 
                             [issue countMarkings]]];
        [alert addButtonWithTitle:@"Remove"];
        [alert addButtonWithTitle:@"Cancel marking"]; 
        [alert addButtonWithTitle:@"Add to them"];
        switch ([alert runModal]) {
            case NSAlertFirstButtonReturn: // Remove
                [issue removeAllMarkingsUsing:self.managedObjectContext];
                break;
            case NSAlertSecondButtonReturn: // Cancel
                return;
            case NSAlertThirdButtonReturn: // Add to them
                break;
        }
    }
    
    NSURL *source = [self askPdfURL];
    if (!source) return;
    [IssueCtrl markURL:source];
    
    NSSavePanel *dialog = [NSSavePanel savePanel];
    [dialog setTitle:@"Save markings into"];
    [dialog setAllowedFileTypes:[NSArray arrayWithObject:@"csv"]];
    [dialog setDirectoryURL:[NSURL fileURLWithPath: NSHomeDirectory()]];
    if ([dialog runModal] != NSFileHandlingPanelOKButton) return;
    NSLog(@"About to save markings into %@", [dialog URL]);
    [IssueCtrl writeCSVtoURL:[dialog URL]];
}


- (IBAction)setNewDocument:(id)sender {
    NSURL* url = [self askPdfURL];
    if (!url) return;
    self.selectedIssue.document = url;
    [self openPdfPanelFor:self.selectedIssue making:YES];
    
    NSError **err;
    [self.managedObjectContext save:err];
    if (err != noErr) NSLog(@"issue save error when setting PDF document");
    
    NSLog(@"PDF document set to %@", self.selectedIssue.document);    
}

@end



/*@implementation IsCourseColumn
+ (Class)transformValueClass { return [NSNumber class]; }
+ (BOOL)allowsReverseTransformation {return NO; }
- (id)transformedValue:(id)value { NSLog(@"Column is %d", [value intValue]); return [NSNumber numberWithBool: ([value intValue] == 0)]; }
@end
*/

