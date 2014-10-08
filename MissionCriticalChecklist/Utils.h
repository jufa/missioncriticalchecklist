//
//  Utils.h
//  MissionCriticalChecklist
//
//  Created by Jeremy Kuzub on 2014-09-13.
//  Copyright (c) 2014 jufaintermedia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utils : NSObject
+ (CGFloat)measureHeightOfUITextView:(UITextView *)textView;
+ (int)getTotalRows:(UITableView*)tableView;
@end
