//
//  ChecklistTableViewController.h
//  MissionCriticalChecklist
//
//  Created by Jeremy Kuzub on 2014-08-02.
//  Copyright (c) 2014 jufaintermedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddChecklistItemViewController.h"
#import "ChecklistItem.h"
#import "Checklist.h"
#import "ChecklistItemTableViewCell.h"
#import "AppDelegate.h"

@interface ChecklistTableViewController : UITableViewController
<AddChecklistItemViewControllerDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSString *checklistName;
@property (nonatomic, strong) Checklist *checklist;


@property (nonatomic,strong) NSFetchedResultsController *fetchedResultsController;
- (IBAction)beginEdit:(id)sender;
- (IBAction)resetChecklist:(id)sender;
- (void) loadChecklist:(Checklist*)checklist;
@end
