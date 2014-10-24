//
//  ChecklistCollectionViewController.h
//  MissionCriticalChecklist
//
//  Created by Jeremy Kuzub on 2014-08-02.
//  Copyright (c) 2014 jufaintermedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddChecklistViewController.h"
#import "Checklist.h"
#import "ChecklistCollectionTableViewCell.h"
#import "ChecklistViewController.h"
#import "AppDelegate.h"

@interface ChecklistCollectionViewController : UIViewController
<AddChecklistViewControllerDelegate, NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic,strong) NSFetchedResultsController *fetchedResultsController;
- (IBAction)beginEdit:(id)sender;
- (IBAction)resetChecklist:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tableView;


@end
