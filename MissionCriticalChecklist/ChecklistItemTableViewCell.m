//
//  ChecklistItemTableViewCell.m
//  MissionCriticalChecklist
//
//  Created by Jeremy Kuzub on 2014-08-03.
//  Copyright (c) 2014 jufaintermedia. All rights reserved.
//

#import "ChecklistItemTableViewCell.h"

@implementation ChecklistItemTableViewCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // @see: http://justabunchoftyping.com/fix-for-ios7-uitextview-issues
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

-(void) updateWithData:(ChecklistItem *)checklistItem{
    
     // Configure the cell...
     self.actionTextField.text = checklistItem.action;
     [self setDetailText:checklistItem.detail];
     
     //switch:
     //[cell.check setOn:checklistItem.checked.boolValue animated:NO];
     //[cell.checkLeft setOn:checklistItem.checked.boolValue animated:NO];
     [self setTimestamp:checklistItem.timestamp];
     
     //image:
     NSString *imageToLoad = [NSString stringWithFormat:@"%@.png", checklistItem.icon];
     self.icon.image = [UIImage imageNamed:imageToLoad];
     
     //backgrounds:
     if(checklistItem.checked.boolValue == YES) [self setMode:@"complete"];
     if(checklistItem.checked.boolValue == NO) [self setMode:@"incomplete"];
     
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    //enable the check swith:
    self.check.enabled = selected;
    self.checkLeft.enabled = selected;
    
}

-(void) setMode:(NSString*)mode {
    NSString* suffix;
    
    if ([mode isEqualToString:@"incomplete"]) {
        suffix = @"grey";
    } else if ([mode isEqualToString:@"complete"]) {
        suffix = @"green";
    } else if ([mode isEqualToString:@"skipped"]) {
        suffix = @"blue";
    }
        
    //set left and right switch background images:
    self.backgroundLeft.image = [UIImage imageNamed: [NSString stringWithFormat:@"cli-bg-left-%@", suffix]];
    
    self.backgroundRight.image = [UIImage imageNamed: [NSString stringWithFormat:@"cli-bg-right-%@", suffix]];
    
}

-(void) setDetailText:(NSString*)text{
    self.detailTextField.text = text;
}


-(void) editingModeStart {
    [self.check setHidden:YES];
    [self.checkLeft setHidden:YES];
}

-(void) editingModeEnd {
    [self.check setHidden:NO];
    [self.checkLeft setHidden:NO];
}

-(void) reset {
    [self.check setOn: NO];
    [self.checkLeft setOn: NO];
}

-(void) setTimestamp:(NSDate*)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"hh:mm:ss"];
    NSString *stringFromDate = [formatter stringFromDate:date];
    self.timeStamp.text = stringFromDate;
}
-(void)selected:(BOOL)selected {
    self.checkButtonRight.enabled = selected;
    self.checkButtonLeft.enabled = selected;
}

- (IBAction)checkToggled:(id)sender {
}
@end

