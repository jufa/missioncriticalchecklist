//
//  addChecklistViewController.h
//  MissionCriticalChecklist
//
//  Created by Jeremy Kuzub on 2014-08-03.
//  Copyright (c) 2014 jufaintermedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Checklist.h"
#import "ChecklistItemIcons.h"


@protocol AddChecklistViewControllerDelegate;

@interface AddChecklistViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *typeField;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;

@property (weak, nonatomic) IBOutlet UINavigationItem *navTitle;

@property (weak,nonatomic) id <AddChecklistViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UICollectionView *iconCollectionViewController;
@property (strong,nonatomic) Checklist *currentChecklist;
@property (strong, nonatomic) NSString *mode;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;

@end


//define the protocol requirements for the delegate:
@protocol AddChecklistViewControllerDelegate

-(void) addChecklistViewControllerDidSave:(Checklist *) checklistToSave;
-(void) addChecklistViewControllerDidCancel:(Checklist *) checklistToDelete;


@end
