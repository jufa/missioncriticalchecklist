//
//  MCCTextView.m
//  MissionCriticalChecklist
//
//  Created by Jeremy Kuzub on 2014-11-07.
//  Copyright (c) 2014 jufaintermedia. All rights reserved.
//

#import "MCCTextView.h"

@implementation MCCTextView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    [super drawRect:rect];
    [self vcenter];
    
}


-(void) vcenter {
    //vertical centering
    CGFloat height = [self bounds].size.height;
    CGFloat contentheight;
    contentheight = [self sizeThatFits:CGSizeMake(self.frame.size.width, FLT_MAX)].height;
    //NSLog(@"iOS7; %f %f", height, contentheight);
    CGFloat topCorrect = (height - contentheight * [self zoomScale]) * 0.5;
    topCorrect = (topCorrect <0.0 ? 0.0 : topCorrect);
    self.contentOffset = (CGPoint){.x = 0, .y = -topCorrect};
}
@end
