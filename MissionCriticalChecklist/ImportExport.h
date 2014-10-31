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

@interface ImportExport:NSObject <NSFetchedResultsControllerDelegate, UIAlertViewDelegate>

//public instance variables:
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
//@property (nonatomic,strong) NSFetchedResultsController *fetchedResultsController;
//@property (nonatomic,strong) NSMutableArray * checklists;


//public instance methods:
//TODO: essentially serialize the Managed Object that matches the checklist, return an NSString
+(NSString*) buildChecklistString:(Checklist*) checklist;

+(NSFileHandle*) buildChecklistJSON;

//returns true if ManagedObject is updated:
+(BOOL) importChecklistsFromURL:(NSURL*) url;

+(void) parseChecklistFromUrl:(NSURL*)url;

+ (NSData*) buildChecklistFile;

+(NSMutableArray*)checklists;

+(void) alertChecklistExists:(Checklist*)checklist;

+ (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

+(void) duplicateChecklistCheck:(int)actionOnDuplicates;


@end



