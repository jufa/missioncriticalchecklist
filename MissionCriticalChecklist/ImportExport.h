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

@interface ImportExport:NSObject <NSFetchedResultsControllerDelegate, UIAlertViewDelegate>
//Export:
+(NSData*) buildChecklistFile;

//Import:
+(void) promptImportChecklistsFromUrl:(NSURL*)url;
@end



