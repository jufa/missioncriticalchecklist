//
//  ChecklistItemTableViewCell.h
//  MissionCriticalChecklist
//
//  Created by Jeremy Kuzub on 2014-08-03.
//  Copyright (c) 2014 jufaintermedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Utils.h"
@protocol ChecklistItemTableViewCellDelegate;
@interface ChecklistItemTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextField *actionTextField;
@property (weak, nonatomic) IBOutlet UITextView *detailTextField;
@property (weak, nonatomic) IBOutlet UISwitch *check;
@property (weak, nonatomic) IBOutlet UITextField *timeStamp;
@property NSInteger index;
@property (weak, nonatomic) IBOutlet UIImageView *icon;
- (IBAction)checkToggled:(id)sender;
-(void)editingModeStart;
-(void)editingModeEnd;
-(void)reset;
-(void)setTimestamp:(NSDate *)date;
-(void)setDetailText:(NSString*)text;

@end

@protocol ChecklistItemTableViewCellDelegate
-(void)checkDidToggle:BOOL;


@end