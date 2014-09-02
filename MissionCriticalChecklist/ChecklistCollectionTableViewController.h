//
//  ChecklistCollectionTableViewController.h
//  MissionCriticalChecklist
//
//  Created by Jeremy Kuzub on 2014-08-02.
//  Copyright (c) 2014 jufaintermedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddChecklistViewController.h"
#import "Checklist.h"
#import "ChecklistCollectionTableViewCell.h"
#import "AppDelegate.h"

@interface ChecklistCollectionTableViewController : UITableViewController
<AddChecklistViewControllerDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic,strong) NSFetchedResultsController *fetchedResultsController;
- (IBAction)beginEdit:(id)sender;
- (IBAction)resetChecklist:(id)sender;

@end
