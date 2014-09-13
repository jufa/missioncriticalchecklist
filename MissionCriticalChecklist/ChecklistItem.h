//
//  ChecklistItem.h
//  MissionCriticalChecklist
//
//  Created by Jeremy Kuzub on 2014-08-02.
//  Copyright (c) 2014 jufaintermedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Checklist;

@interface ChecklistItem : NSManagedObject

@property (nonatomic, retain) NSNumber * checked;
@property (nonatomic, retain) NSString * detail;
@property (nonatomic, retain) NSNumber * index;
@property (nonatomic, retain) NSString * action;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * icon;
@property (nonatomic, retain) NSDate  * timestamp;
@property (nonatomic, retain) Checklist *checklist;

@end
