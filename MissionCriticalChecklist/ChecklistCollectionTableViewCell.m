//
//  ChecklistItemTableViewCell.m
//  MissionCriticalChecklist
//
//  Created by Jeremy Kuzub on 2014-08-03.
//  Copyright (c) 2014 jufaintermedia. All rights reserved.
//

#import "ChecklistCollectionTableViewCell.h"

@implementation ChecklistCollectionTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        UIView *bgView = [[UIView alloc] init];
        [bgView setBackgroundColor:[UIColor redColor]];
        [self setSelectedBackgroundView: bgView];
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

//TODO: use this as main view update, rmv from parent
-(void) updateWithData:(Checklist *)checklist{
    
    // Configure the cell...
    self.typeTextField.text = [NSString stringWithFormat:@"%@. %@", checklist.index, checklist.type];
    //[self setDetailText:checklistItem.detail];
    self.nameTextField.text = checklist.name;

    //[self setTimestamp:checklistItem.timestamp];
    
    //image:
    NSString *imageToLoad = [NSString stringWithFormat:@"%@.png", checklist.icon];
    self.icon.image = [UIImage imageNamed:imageToLoad];
    
    //backgrounds:
    //if(checklistItem.checked.boolValue == YES) [self setMode:@"complete"];
    //if(checklistItem.checked.boolValue == NO) [self setMode:@"incomplete"];
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
    //enable the check swith:
    self.check.enabled = selected;
    
}

//TODO: finish backgrounds
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
    //self.backgroundLeft.image = [UIImage imageNamed: [NSString stringWithFormat:@"cli-bg-left-%@", suffix]];
    
    //self.backgroundRight.image = [UIImage imageNamed: [NSString stringWithFormat:@"cli-bg-right-%@", suffix]];
    
}

-(void) editingModeStart {
    [self.check setHidden:YES];
}

-(void) editingModeEnd {
    [self.check setHidden:NO];
}

-(void) reset {
    [self.check setOn: NO];
}

-(void) setTimestamp:(NSDate*)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"hh:mm:ss"];
    NSString *stringFromDate = [formatter stringFromDate:date];
    self.timeStamp.text = stringFromDate;
}


- (IBAction)checkToggled:(id)sender {
}
@end

