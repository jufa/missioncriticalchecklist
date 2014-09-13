//
//  ChecklistIcons.m
//  MissionCriticalChecklist
//
//  Created by Jeremy Kuzub on 2014-09-13.
//  Copyright (c) 2014 jufaintermedia. All rights reserved.
//

#import "ChecklistItemIcons.h"

@implementation ChecklistItemIcons

static NSMutableArray* _iconList;

+(NSMutableArray*) iconList {
    @synchronized (self) {
        if(_iconList == nil){
            //load in the icons using the plist file of their file names:
            //path to the plist (in the application bundle)
            NSString *path = [[NSBundle mainBundle] pathForResource:
                              @"ChecklistItemIcons" ofType:@"plist"];
            
            // Build the array from the plist
            _iconList = [[NSMutableArray alloc] initWithContentsOfFile:path];
        }
        return _iconList;
    }
    
}

@end
