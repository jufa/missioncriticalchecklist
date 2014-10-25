//
//  ImportExport.h
//  MissionCriticalChecklist
//
//  Created by Jeremy Kuzub on 2014-10-20.
//  Copyright (c) 2014 jufaintermedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Checklist.h"
#import "ChecklistItem.h"

//TODO: reference this for opening email extentions: https://developer.apple.com/library/ios/qa/qa1587/_index.html

@interface ImportExport:NSObject <NSFetchedResultsControllerDelegate>

//public instance variables:
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
//@property (nonatomic,strong) NSFetchedResultsController *fetchedResultsController;


//public instance methods:
//TODO: essentially serialize the Managed Object that matches the checklist, return an NSString
+ (NSString*) buildChecklistString:(Checklist*) checklist;

//TODO: build up the file using multiple calls to buildChecklistString
+ (NSData*) buildChecklistFile;

+  (NSFileHandle*) buildChecklistJSON;

//TODO: populate the managed object with data from a file
//Q: what about duplicates? how is one defined? checksum?
-(void) addChecklistsFromFile:(NSFileHandle*) file;



@end



