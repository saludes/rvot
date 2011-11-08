//
//  RVAppDelegate.h
//  rvot-app3
//
//  Created by Jordi Saludes on 08/11/11.
//  Copyright (c) 2011 UPC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface RVAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)saveAction:(id)sender;

@end
