//
//  RootViewController.h
//  BuggyWhipChat
//
//  Created by James Turner on 6/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TwitterAPI.h"

@class DetailViewController;

#import <CoreData/CoreData.h>

@interface RootViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (retain, nonatomic) IBOutlet DetailViewController *detailViewController;

@property (retain, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (retain, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
