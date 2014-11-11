//
//  ChecklistItemTableViewCell.h
//  MissionCriticalChecklist
//
//  Created by Jeremy Kuzub on 2014-08-03.
//  Copyright (c) 2014 jufaintermedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Utils.h"
#import "ChecklistItem.h"
#import "MCCTextView.h"

#define USE_TIME_TO_COMPLETE YES  //if YES, will display, when cheked off, the time required to complete the task, if NO, will show the time elapsed from the first item in the checklist being checked off (legacy) 

@protocol ChecklistItemTableViewCellDelegate;
@interface ChecklistItemTableViewCell : UITableViewCell

typedef enum checklistItemCompletionState
{
    CLI_INCOMPLETE,
    CLI_COMPLETE,
    CLI_SKIPPED,
    CLI_UNSPECIFIED
} checklistItemCompletionState;


@property (weak, nonatomic) IBOutlet MCCTextView *actionTextField;
@property (weak, nonatomic) IBOutlet MCCTextView *detailTextField;
@property (weak, nonatomic) IBOutlet UISwitch *check;
@property (weak, nonatomic) IBOutlet UISwitch *checkLeft;
@property (weak, nonatomic) IBOutlet UITextField *timeStamp;
@property (weak, nonatomic) IBOutlet UITextField *elapseTimeStamp;
@property NSInteger index;
@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundLeft;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundRight;
- (IBAction) checkToggled:(id)sender;
-(void) editingModeStart;
-(void) editingModeEnd;
-(void) setTimestamp:(NSDate*)date AndStartTime:(NSDate*)startDate AndSelectedTime:(NSTimeInterval)selectedTime;
-(void) setDetailText:(NSString*)text;
-(void) refreshButtons;
-(void) updateWithData:(ChecklistItem*)checklistItem AndStartTime:(NSDate*)startTime AndSelectedTime:(NSTimeInterval)selectedTime;
-(void) setElapseTimeFrom:(NSDate*)startDate To:(NSDate*)endDate;
-(void) updateSelectedTime:(NSTimeInterval)selectedTime;
@property (weak, nonatomic) IBOutlet UIButton *checkButtonRight;
@property (weak, nonatomic) IBOutlet UIButton *checkButtonLeft;
@property (readwrite, getter=isCurrentSelection) BOOL currentSelection;

@end

@protocol ChecklistItemTableViewCellDelegate
-(void)checkDidToggle:BOOL;


@end