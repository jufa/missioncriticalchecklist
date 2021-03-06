//
//  ChecklistViewController.h
//  MissionCriticalChecklist
//
//  Created by Jeremy Kuzub on 2014-08-02.
//  Copyright (c) 2014 jufaintermedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddChecklistItemViewController.h"
#import "ChecklistItem.h"
#import "ChecklistItemIcons.h"
#import "Checklist.h"
#import "ChecklistItemTableViewCell.h"
#import "Utils.h"
#import "AppDelegate.h"

@interface ChecklistViewController : UIViewController
<AddChecklistItemViewControllerDelegate, NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSString *checklistName;
@property (nonatomic, strong) Checklist *checklist;
@property (weak, nonatomic) IBOutlet UIImageView *footerImageLeft;
@property (weak, nonatomic) IBOutlet UITextField *footerTextField;
@property (weak, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewConstraintBottomSpace;
@property (weak, nonatomic) IBOutlet UILabel *checklistNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *checklistTypeLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressBarOffset;
@property (weak, nonatomic) IBOutlet UITextField *itemsSkipped;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *alertBarOffset;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *currentItemHighlightOffset;

@property (nonatomic,strong) NSFetchedResultsController *fetchedResultsController;
- (IBAction)beginEdit:(id)sender;
- (IBAction)resetChecklist:(id)sender;
- (void) loadChecklist:(Checklist*)checklist;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
