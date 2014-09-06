//
//  addChecklistItemViewController.h
//  MissionCriticalChecklist
//
//  Created by Jeremy Kuzub on 2014-08-03.
//  Copyright (c) 2014 jufaintermedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChecklistItem.h"

@protocol AddChecklistItemViewControllerDelegate;

@interface AddChecklistItemViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *actionField;
@property (weak, nonatomic) IBOutlet UITextField *detailField;
@property (weak, nonatomic) IBOutlet UINavigationItem *navTitle;

@property (weak,nonatomic) id <AddChecklistItemViewControllerDelegate> delegate;

@property (strong,nonatomic) ChecklistItem *currentChecklistItem;
@property (strong,nonatomic) NSString *mode;

- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;

@end


//define the protocol requirements for the delegate:
@protocol AddChecklistItemViewControllerDelegate

-(void) addChecklistItemViewControllerDidSave:(ChecklistItem *) checklistItemToSave;
-(void) addChecklistItemViewControllerDidCancel:(ChecklistItem *) checklistItemToDelete;


@end
