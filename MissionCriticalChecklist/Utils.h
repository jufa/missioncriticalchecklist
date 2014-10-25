//
//  Utils.h
//  MissionCriticalChecklist
//
//  Created by Jeremy Kuzub on 2014-09-13.
//  Copyright (c) 2014 jufaintermedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"

@interface Utils : NSObject
@property (weak,nonatomic) NSManagedObjectContext * moc;

+ (CGFloat)measureHeightOfUITextView:(UITextView *)textView;

+ (int)getTotalRows:(UITableView*)tableView;

+ (NSFetchedResultsController*) checklistFetchedResultsController:(NSFetchedResultsController*)fetchedResultsController withChecklistName:(NSString*)checklistName withDelegate:(id)delegate;

+ (NSFetchedResultsController*) checklistCollectionFetchedResultsController:(NSFetchedResultsController*)fetchedResultsController withDelegate:(id)delegate;

+ (NSString*)nowAsString;
@end
