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
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
    //enable the check swith:
    self.check.enabled = selected;
    
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

