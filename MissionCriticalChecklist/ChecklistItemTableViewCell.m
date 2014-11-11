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
    BOOL _currentSelection;
    BOOL _realttimeTimestamp;
    BOOL _skipped;
    NSTimer * _elapseTimer;
    
    checklistItemCompletionState _completionState; //enum
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // @see: http://justabunchoftyping.com/fix-for-ios7-uitextview-issues
        editing = NO;
        _currentSelection = NO;
        _completionState = CLI_INCOMPLETE;
        _elapseTimer = nil;
    }
    return self;
}


- (void)awakeFromNib
{
    // Initialization code
    
}


-(void) updateWithData:(ChecklistItem *)checklistItem AndStartTime:(NSDate*)startTime AndSelectedTime:(NSTimeInterval)selectedTime{
    
     // Configure the cell...
    self.actionTextField.text = [NSString stringWithFormat:@"%d. %@", checklistItem.index.intValue+1, checklistItem.action];
    //NSLog(@"new start time: %@",startTime);
    
    [self setDetailText:checklistItem.detail];

    [self setTimestamp:checklistItem.timestamp AndStartTime:startTime AndSelectedTime:selectedTime];
    
    //image:
    NSString *imageToLoad = [NSString stringWithFormat:@"%@.png", checklistItem.icon];
    self.icon.image = [UIImage imageNamed:imageToLoad];
     
    //backgrounds:
    if ( checklistItem.checked.boolValue == YES) _completionState = CLI_COMPLETE;
    else _completionState = CLI_INCOMPLETE;
    if ( checklistItem.skipped.boolValue == YES) _completionState = CLI_SKIPPED; //this overrides incomplete since it is bad to skip!
    
    [self refreshButtons];
    
    //centre - needs to be done for any cells that are out of scroll view:
    [self.actionTextField vcenter];
    [self.detailTextField vcenter];
    
}


-(BOOL)isCurrentSelection{
    return _currentSelection;
}

- (void)setCurrentSelection:(BOOL)newVal
{
    [self setSelected:newVal animated:NO];
    // Configure the view for the selected state
    //enable the check swith:
    _currentSelection = newVal;
    self.checkButtonLeft.enabled = newVal;
    self.checkButtonRight.enabled = newVal;
    [self refreshButtons]; //refresh
}


-(void) refreshButtons {
    //TODO: skipped indication
    NSString* suffix;
    
    checklistItemCompletionState mode = _completionState;
    
    if (mode == CLI_INCOMPLETE) {
        suffix = @"grey";
        [self hideTimestamps:NO];
    } else if (mode == CLI_COMPLETE) {
        suffix = @"green";
        [self hideTimestamps:NO];
    } else if (mode == CLI_SKIPPED) {
        suffix = @"red";
        [self hideTimestamps:NO];
    }
    
    //override if selected:
    if(_currentSelection && _completionState != CLI_COMPLETE) {
        //suffix = @"blue";
        [self hideTimestamps:NO];
    }
    
    //TODO: transition animation?
    
    //realtimeTimestamp Update:
    
    
    //set left and right switch background images:
    self.backgroundLeft.image = [UIImage imageNamed: [NSString stringWithFormat:@"cli-bg-left-%@", suffix]];
    self.backgroundRight.image = [UIImage imageNamed: [NSString stringWithFormat:@"cli-bg-right-%@", suffix]];
    
}

-(void) hideTimestamps:(BOOL)hidden {
    self.timeStamp.hidden = hidden;
    self.elapseTimeStamp.hidden = hidden;
    
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
    [self hideTimestamps:hidden];
    
}


-(void) setTimestamp:(NSDate*)date AndStartTime:(NSDate*)startDate AndSelectedTime:(NSTimeInterval)selectedTime {

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"hh:mm:ss"];
    NSString *stringFromDate = [formatter stringFromDate:date];
    self.timeStamp.text = stringFromDate;
    if (USE_TIME_TO_COMPLETE) {
        [self updateSelectedTime:selectedTime];
    } else {
        [self setElapseTimeFrom:date To:startDate];
    }

}


-(void) setElapseTimeFrom:(NSDate*)startDate To:(NSDate*)endDate {
    if(startDate == nil) {
        //NSLog(@"startdate is nil");
    };
    if(endDate == nil) {
        //NSLog(@"enddate is nil");
    };
    if(startDate == nil || endDate == nil){
        self.elapseTimeStamp.text=@"";
        return;
    }
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
    
    if(components.hour > 0){
            self.elapseTimeStamp.text = [NSString stringWithFormat:@"+%d:%02d:%02d",components.hour, components.minute, components.second];
    } else {
            self.elapseTimeStamp.text = [NSString stringWithFormat:@"+%02d:%02d",components.minute, components.second];
    }    
}

//when selected, there is a running elapsetime. This updates only that section
-(void) updateSelectedTime:(NSTimeInterval)selectedTime {
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:selectedTime];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    NSString *formattedDate = [dateFormatter stringFromDate:date];
    //NSLog(@"+mm:ss %@", formattedDate);
    
    self.elapseTimeStamp.text = [NSString stringWithFormat:@"+%@", formattedDate];
}



-(void)selected:(BOOL)selected {
    self.checkButtonRight.enabled = selected;
    self.checkButtonLeft.enabled = selected;
}

- (IBAction)checkToggled:(id)sender {
}


@end

