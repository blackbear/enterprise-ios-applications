//
//  BuggyWhipChatAppDelegate.h
//  BuggyWhipChat
//
//  Created by James Turner on 6/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"

@interface BuggyWhipChatAppDelegate : UIResponder <UIApplicationDelegate>

@property (retain, nonatomic) UIWindow *window;

@property (readonly, retain, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, retain, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, retain, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain) RootViewController *rootViewController;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@property (retain, nonatomic) UINavigationController *navigationController;

@property (retain, nonatomic) UISplitViewController *splitViewController;

@end
