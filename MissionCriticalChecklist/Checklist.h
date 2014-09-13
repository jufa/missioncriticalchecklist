//
//  Checklist.h
//  MissionCriticalChecklist
//
//  Created by Jeremy Kuzub on 2014-08-27.
//  Copyright (c) 2014 jufaintermedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ChecklistItem;

@interface Checklist : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * icon;
@property (nonatomic, retain) NSNumber * index;
@property (nonatomic, retain) NSSet *checklistItems;
@end

@interface Checklist (CoreDataGeneratedAccessors)

- (void)addChecklistItemsObject:(ChecklistItem *)value;
- (void)removeChecklistItemsObject:(ChecklistItem *)value;
- (void)addChecklistItems:(NSSet *)values;
- (void)removeChecklistItems:(NSSet *)values;

@end
