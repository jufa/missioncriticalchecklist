//
//  ChecklistItemTableViewCell.m
//  MissionCriticalChecklist
//
//  Created by Jeremy Kuzub on 2014-08-03.
//  Copyright (c) 2014 jufaintermedia. All rights reserved.
//

#import "ChecklistItemTableViewCell.h"

@implementation ChecklistItemTableViewCell {
    BOOL editing;
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // @see: http://justabunchoftyping.com/fix-for-ios7-uitextview-issues
        editing = NO;
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

-(void) updateWithData:(ChecklistItem *)checklistItem AndStartTime:(NSDate*)startTime{
    
     // Configure the cell...
     self.actionTextField.text = checklistItem.action;
     [self setDetailText:checklistItem.detail];

     [self setTimestamp:checklistItem.timestamp AndStartTime:startTime];
     
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
    editing = YES;
    [self hideBackgrounds:editing];
}

-(void) editingModeEnd {
    editing = NO;
    [self hideBackgrounds:editing];
}

-(void) hideBackgrounds:(BOOL)hidden {
    self.backgroundLeft.hidden = hidden;
    self.backgroundRight.hidden = hidden;
}

-(void) reset {
    [self.check setOn: NO];
    [self.checkLeft setOn: NO];
}

-(void) setTimestamp:(NSDate*)date AndStartTime:(NSDate*)startDate {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"hh:mm:ss"];
    NSString *stringFromDate = [formatter stringFromDate:date];
    self.timeStamp.text = stringFromDate;
    
    [self setElapseTimeFrom:date To:startDate];
}

//TODO: implement this:
-(void) setElapseTimeFrom:(NSDate*)startDate To:(NSDate*)endDate {
    if(startDate == nil) {
        NSLog(@"startdate is nil");
    };
    if(endDate == nil) {
        NSLog(@"enddate is nil");
    };
    if(startDate == nil || endDate == nil) return;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"(hh:mm:ss)"];
    NSString *stringFromDate = [formatter stringFromDate:startDate];
    self.timeStamp.text = stringFromDate;
    
    //calc diff:
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit
                                               fromDate:endDate
                                                 toDate:startDate
                                                options:0];
    
    NSLog(@"Difference in date components (sec to year): %li %li %li %li %li %li", (long)components.second, (long)components.minute, (long)components.hour, (long)components.day, (long)components.month, (long)components.year);
    

    if(components.hour > 0){
            self.elapseTimeStamp.text = [NSString stringWithFormat:@"+%d:%02d:%02d",components.hour, components.minute, components.second];
    } else {
            self.elapseTimeStamp.text = [NSString stringWithFormat:@"+%02d:%02d",components.minute, components.second];
    }
    
}


-(void)selected:(BOOL)selected {
    self.checkButtonRight.enabled = selected;
    self.checkButtonLeft.enabled = selected;
}

- (IBAction)checkToggled:(id)sender {
}
@end

