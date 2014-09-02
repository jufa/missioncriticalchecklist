//
//  ChecklistCollectionTableViewCell.h
//  MissionCriticalChecklist
//
//  Created by Jeremy Kuzub on 2014-08-03.
//  Copyright (c) 2014 jufaintermedia. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ChecklistCollectionTableViewCellDelegate;
@interface ChecklistCollectionTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextField *typeTextField;
@property (weak, nonatomic) IBOutlet UITextView *nameTextField;
@property (weak, nonatomic) IBOutlet UISwitch *check;
@property (weak, nonatomic) IBOutlet UITextField *timeStamp;
@property NSInteger index;
- (IBAction)checkToggled:(id)sender;
-(void)editingModeStart;
-(void)editingModeEnd;
-(void)reset;
-(void)setTimestamp:(NSDate *)date;

@end

@protocol ChecklistCollectionTableViewCellDelegate
-(void)checkDidToggle:BOOL;


@end