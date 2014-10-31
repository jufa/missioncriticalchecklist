//
//  ImportExport.m
//  MissionCriticalChecklist
//
//  Created by Jeremy Kuzub on 2014-10-20.
//  Copyright (c) 2014 jufaintermedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "ImportExport.h"
#import "ChecklistItem.h"
#import "Checklist.h"
#import "Utils.h"
//TODO: reference this for opening email extentions: https://developer.apple.com/library/ios/qa/qa1587/_index.html

#define ALERT_TITLE_CHECKLIST_EXISTS @"Checklist Exists"
#define AOD_KEEP_OLD 1
#define AOD_KEEP_NEW 2
#define AOD_KEEP_BOTH 3
#define AOD_PROMPT_USER 4


static NSMutableArray* _checklists;

@implementation ImportExport {
    // privates:
    
    NSString* checklistCollectionString;
    
};
//@synthesize checklists = _checklists;
//@synthesize fetchedResultsController = _fetchedResultsController;

+ (NSMutableArray*)checklists {
    return _checklists;
}


+ (NSString*) buildChecklistString:(Checklist*) checklist {
    
    //NSManagedObjectContext *moc = [(AppDelegate *) [[UIApplication sharedApplication] delegate] managedObjectContext];
    
    NSError *error = nil;
    NSFetchedResultsController *frc = nil;
    
    frc = [Utils checklistFetchedResultsController:frc withChecklistName:checklist.name withDelegate:self];
    
    if(![frc performFetch:&error]){
        NSLog(@"buildChecklistString: Error in fetching checklist: %@",error);
        abort();
    }

    //TODO: essentially serialize the Managed Object that matches the checklist, return an NSString
    ChecklistItem * cli;
    NSString* cls=@"";//checklistString = @"";
    
    for (id object in [frc fetchedObjects]) {
        cli = (ChecklistItem*)object;
        //NSLog(@"%@",cli.action);
        
        cls = [cls stringByAppendingString: [NSString stringWithFormat:@"--- %@ -- %@ -- %@ --\n",cli.action,cli.detail, cli.icon ]];

    }
    
    return cls;
}

+ (NSData*) buildChecklistFile {
    //TODO: build up the file using multiple calls to buildChecklistString
    
    NSError *error = nil;
    NSFetchedResultsController *frc = nil;
    
    NSString * fs = @""; //fileString;
    
    frc = [Utils checklistCollectionFetchedResultsController:frc withDelegate:self];
    
    if(![frc performFetch:&error]){
        NSLog(@"buildChecklistFile: Error in fetching checklist: %@",error);
        abort();
    }
    
    //TODO: essentially serialize the Managed Object that matches the checklist, return an NSString
    Checklist * cli;
    NSString * str;
    
    for (id object in [frc fetchedObjects]) {
        cli = (Checklist*)object;
        str = [NSString stringWithFormat:@"### %@ -- %@ -- %@ --\n",cli.name, cli.type, cli.icon];
        fs = [fs stringByAppendingString: str];
        
        fs = [fs stringByAppendingString: [ImportExport buildChecklistString:cli]];
        fs = [fs stringByAppendingString: @"\n\n"];

        
    }
    
    // Build the path, and create if needed.
    NSString* filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* fileName = @"MCC-checklists.txt";
    NSString* fileAtPath = [filePath stringByAppendingPathComponent:fileName];
    NSData * data = nil;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:fileAtPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:fileAtPath error:nil]; //TODO: error handling
    }
        
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileAtPath]) {
        [[NSFileManager defaultManager] createFileAtPath:fileAtPath contents:nil attributes:nil];
        if (![[fs dataUsingEncoding:NSUTF8StringEncoding] writeToFile:fileAtPath atomically:NO]){
            //TODO: error handling
            NSLog(@">>> ERROR <<< buildChecklistFile: Could not write file to path");
        }
        //NSFileHandle * fh = [NSFileHandle fileHandleForReadingAtPath:fileAtPath];
        data = [NSData dataWithContentsOfFile:fileAtPath];
    } else {
        //TODO: error handling
        NSLog(@">>> ERROR <<< buildChecklistFile: Could not build output file. It already exists");
    }
    
    //NSLog(fs);
    
    return data;
}

+ (NSFileHandle*) buildChecklistJSON {
    
    
    NSManagedObjectContext *moc = [(AppDelegate *) [[UIApplication sharedApplication] delegate] managedObjectContext];
    
    
    
    NSError *error = nil;
    NSFetchedResultsController *frc = nil;
    
    frc = [Utils checklistCollectionFetchedResultsController:frc withDelegate:self];
    
    if(![frc performFetch:&error]){
        NSLog(@"buildChecklistFile: Error in fetching checklist: %@",error);
        abort();
    }
    
    //NSEntityDescription *entity = [NSEntityDescription entityForName:@"Checklist" inManagedObjectContext: moc];
    
    //NSMutableDictionary *fields = [NSMutableDictionary dictionary];
    
    Checklist* cli;
    
    for (id object in [frc fetchedObjects]) {
        cli = (Checklist*)object;
        //[fields setObject:attributeValue forKey:attributeName];
    }
    /*
    for (NSAttributeDescription *attribute in [entity properties]) {
        NSString *attributeName = attribute.name;
        NSLog(@"attribute.name = %@", attributeName);
        id attributeValue = [moc valueForKey:attributeName];
        if (attributeValue) {
            [fields setObject:attributeValue forKey:attributeName];
        }
    }
     */
    //NSLog(fields);
    return nil;
}



+(BOOL) importChecklistsFromURL:(NSURL*) url {
    
    //what state is the application in?
    // + newly loaded?
    // + at collectionview
    // + at checklist?
    // we need to know and change appropriately!
    
    
    
    if (url == nil) return NO;  //&& [url isFileURL
    
    NSArray * checklistItems;
    NSArray * checklistEntries; //i.e. column data
    BOOL checklistExists; //flag for checklist already existing in Managed Object Context
    int i = 0;
    int checklistItemIndex;
    NSManagedObjectContext *moc = [(AppDelegate *) [[UIApplication sharedApplication] delegate] managedObjectContext];
    BOOL addCurrentChecklist = NO;
    int currentChecklistItemInsertionIndex = 0;
    Checklist * newChecklist;
    const int CHECKLIST_INFO_INDEX = 0;
    
    
    //get list of existing checklists: will be needed for duplicate checks:
    NSError *error = nil;
    NSFetchedResultsController *frc = nil;
    Checklist * cl;
    
    frc = [Utils checklistCollectionFetchedResultsController:frc withDelegate:self];
    
    if(![frc performFetch:&error]){
        //TODO: handle error
        NSLog(@"buildChecklistFile: Error in fetching checklist: %@",error);
        abort();
    }

    //get file string:
    NSError * err;
    
    NSString *str = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error: &err]; //needs indirect reference to error obj
    //TODO: error handling:
    if(err)NSLog(@"ERROR: importChecklistsFromURL -> Error converting url to string");
    
    //create array of checklist strings, 1 checklist per array item:
    NSArray * checklists = [str componentsSeparatedByString:@"###"];
    
    
    for (NSString * cliString in checklists){
        if(i++ == 0) continue; //see http://stackoverflow.com/questions/8906221 - the first element will be nil since "###" is a separator with nothing ahead of it.
        if(cliString == nil) continue;
        checklistItems = [cliString componentsSeparatedByString:@"---"];
        checklistItemIndex=0;
        
        //split checklist by checklistItem lines, extract checklist info
        for (NSString * checklistItem in checklistItems) {
            checklistEntries = [checklistItem componentsSeparatedByString:@"--"];
            
            //check if parsing a checklist info line:
            if(checklistItemIndex++ == CHECKLIST_INFO_INDEX) {
                addCurrentChecklist = NO;
                //check if this checklist already exists:
                checklistExists = NO;
                for (id object in [frc fetchedObjects]) {
                    cl = (Checklist*)object;
                    if( [[self trimWhitespace: checklistEntries[0]] isEqualToString:cl.name]){
                        //Checklists already exists, we need to stop and prompt for overwrite:
                        checklistExists = YES;
                        
                        
                    } else {
                        ;
                    }
                }
                
                if(checklistExists){
                    //we need to know what to do:
                    NSLog(@"ALREADY exists: %@",checklistEntries[0]);
                    //[self alertChecklistExists:[self trimWhitespace: checklistEntries[0]] ];
                }
                
                //check if this checklist already exists based on name+type strings:
                if (!checklistExists) {
                    
                    //no. add it:
                    
                    NSLog(@"NEW ITEM:  %@ as %@",checklistEntries[0], cl.name);
                    
                    addCurrentChecklist = YES;
                    currentChecklistItemInsertionIndex = 0; //we are starting to insert new checklist
                    
                    //refresh frc info since a previous insert may have been done:

                    if(![frc performFetch:&error]){
                        //TODO: handle error
                        NSLog(@"buildChecklistFile: Error in fetching checklist: %@",error);
                        abort();
                    }
                    
                    //add it to the MOC:
                    
                    newChecklist = (Checklist*)[NSEntityDescription insertNewObjectForEntityForName:@"Checklist" inManagedObjectContext:moc];
                    
                    // first populate the cl:
                    newChecklist.name = [self trimWhitespace:checklistEntries[0]];
                    newChecklist.type = [self trimWhitespace:checklistEntries[1]];
                    newChecklist.icon = [self trimWhitespace:checklistEntries[2]];
                    //assign the new items index based on last hilited cell and reflow  index values below it:
                    NSInteger insertAt = -1;
                    
                    NSMutableArray *array = [[frc fetchedObjects] mutableCopy];
                    
                    insertAt = [array count];
                    
                    newChecklist.index = [NSNumber numberWithInt:insertAt];
                    
                    //save managed object
                    NSError *error = nil;
                    if(![moc save:&error]){
                        //TODO: handle error:
                        NSLog(@"Error saving new checklist ");
                    }
                }
            } else {
            //we are on a checklist item line, lets add it to MOC
                if(addCurrentChecklist ==  YES) {
                    ChecklistItem* cli = (ChecklistItem*)[NSEntityDescription insertNewObjectForEntityForName:@"ChecklistItem" inManagedObjectContext:moc];
                    cli.action = [self trimWhitespace:checklistEntries[0]];
                    cli.detail = [self trimWhitespace:checklistEntries[1]];
                    cli.icon = [self trimWhitespace:checklistEntries[2]];
                    cli.checked = [NSNumber numberWithBool:NO];
                    cli.index = [NSNumber numberWithInt: currentChecklistItemInsertionIndex++];
                    //must use the mutable set method. it will automatically dispatch the right event to ensure inverse relationship is set:
                    NSMutableSet *checklistRelationship = [newChecklist mutableSetValueForKey:@"checklistItems"];
                    [checklistRelationship addObject:cli];
                    
                    //save managed object
                    NSError *error = nil;
                    if(![moc save:&error])
                    {
                        //TODO: handle error:
                        NSLog(@"Error saving new checklist ");
                    }
                }
            }
        }
    }
    return YES; //TODO: return NO if MOC unmodified
}

/**
 *
 * text file at URL is parsed into array of checklist and array of checklistitem objects. 
 *
 */
+ (void) parseChecklistFromUrl:(NSURL*)url {
    
    if (url == nil) return;  //&& [url isFileURL
    
    _checklists = [[NSMutableArray alloc] init];
    //checklistItems = [[NSMutableArray alloc] init];
    
    NSArray * checklistItemsArray;
    NSArray * checklistEntries; //i.e. column data
    int i = 0;
    int checklistIndex;
    int checklistItemIndex;
    int currentChecklistItemInsertionIndex = 0;
    const int CHECKLIST_INFO_INDEX = 0;

    NSManagedObjectContext *moc = [(AppDelegate *) [[UIApplication sharedApplication] delegate] managedObjectContext];
    
    //run the frc to get a count of existing checklists so we know where to start our index number for the new ones:
    NSFetchedResultsController * frc;
    NSError * error;
    frc = [Utils checklistCollectionFetchedResultsController:frc withDelegate:self];
    if(![frc performFetch: &error]){
        //TODO: handle error
        NSLog(@"buildChecklistFile: Error in fetching checklist: %@", error);
        abort();
    }
    checklistIndex = [[frc fetchedObjects] count];
    
    
    //get file string:
    NSError * err;
    
    NSString *str = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error: &err]; //needs indirect reference to error obj
    //TODO: error handling:
    if(err)NSLog(@"ERROR: importChecklistsFromURL -> Error converting url to string");
    
    //create array of checklist strings, 1 checklist per array item:
    NSArray * checklistsArray = [str componentsSeparatedByString:@"###"];
    
    
    for (NSString * cliString in checklistsArray){
        if(i++ == 0) continue; //see http://stackoverflow.com/questions/8906221 - the first element will be nil since "###" is a separator with nothing ahead of it.
        if(cliString == nil) continue;
        checklistItemsArray = [cliString componentsSeparatedByString:@"---"];
        checklistItemIndex=0;
        Checklist * newChecklist;
        
        //split checklist by checklistItem lines, extract checklist info
        for (NSString * checklistItem in checklistItemsArray) {
            checklistEntries = [checklistItem componentsSeparatedByString:@"--"];
            
            //check if parsing a checklist info line:
            if(checklistItemIndex++ == CHECKLIST_INFO_INDEX) {
                // first populate the cl:
                newChecklist = (Checklist*)[NSEntityDescription insertNewObjectForEntityForName:@"Checklist" inManagedObjectContext:moc];
                newChecklist.name = [self trimWhitespace:checklistEntries[0]];
                newChecklist.type = [self trimWhitespace:checklistEntries[1]];
                newChecklist.icon = [self trimWhitespace:checklistEntries[2]];
                newChecklist.index = [NSNumber numberWithInt:checklistIndex++];
                [_checklists addObject:newChecklist];
                //reset the enumeration index for checklistItems:
                currentChecklistItemInsertionIndex=0;
            } else {
                //we are on a checklist item line
                ChecklistItem* cli = (ChecklistItem*)[NSEntityDescription insertNewObjectForEntityForName:@"ChecklistItem" inManagedObjectContext:moc];
                cli.action = [self trimWhitespace:checklistEntries[0]];
                cli.detail = [self trimWhitespace:checklistEntries[1]];
                cli.icon = [self trimWhitespace:checklistEntries[2]];
                cli.checked = [NSNumber numberWithBool:NO];
                cli.index = [NSNumber numberWithInt: currentChecklistItemInsertionIndex++];
                //must use the mutable set method. it will automatically dispatch the right event to ensure inverse relationship is set:
                NSMutableSet *checklistRelationship = [newChecklist mutableSetValueForKey:@"checklistItems"];
                [checklistRelationship addObject:cli];
                //[checklistItems addObject:cli];
            }
        }
    }
    //save managed object
    if(![moc save:&error])
    {
        //TODO: handle error:
        NSLog(@"Error saving new checklist ");
    }

    //NSLog(@"Checklists: %d %@",[checklists count], checklists);
    //NSLog(@"Checklist Items: %@",checklistItems);
    
    //check for duplicates:
    [self duplicateChecklistCheck:AOD_PROMPT_USER];
}

//helper function to be called when a list of checklists is loaded into this class' Checklists array
+(void) duplicateChecklistCheck:(int)actionOnDuplicates {
    
    NSManagedObjectContext *moc = [(AppDelegate *) [[UIApplication sharedApplication] delegate] managedObjectContext];
    
    NSFetchedResultsController * frc;
    NSError * error;
    
    //pop off array:
    Checklist* clNew = (Checklist*)[_checklists lastObject];
    
    
    //check to see if name and type match an existing checklist in the moc:
    frc = [Utils checklistCollectionFetchedResultsController:frc withDelegate:self];
    
    if(![frc performFetch: &error]){
        //TODO: handle error
        //NSLog(@"buildChecklistFile: Error in fetching checklist: %@", error);
        abort();
    }
    
    int currentAction = actionOnDuplicates;
    NSLog(@"_checklists count : %d",[_checklists count]);
    if([_checklists count] == 0) return;//we've gone through all the new checklists to check for duplicates.
    for (id object in [frc fetchedObjects]) {
        Checklist* clExisting = (Checklist*)object;
        if(clExisting.objectID == clNew.objectID) continue;
        if([clExisting.name isEqualToString:clNew.name]){
            if([clExisting.type isEqualToString:clNew.type]){
                if (currentAction == AOD_KEEP_OLD) {
                    //remove it from the array of newly imported cl's:
                    [_checklists removeLastObject];
                    //delete clNew from moc
                    [moc deleteObject:clNew];
                    currentAction = AOD_PROMPT_USER;
                } else if (actionOnDuplicates == AOD_KEEP_NEW) {
                    //delete clExisting from moc
                    [moc deleteObject:clExisting];
                    [_checklists removeLastObject];
                    currentAction = AOD_PROMPT_USER;
                } else if (currentAction == AOD_KEEP_BOTH) {
                    //do nothing, nothing!
                    [_checklists removeLastObject];
                    currentAction = AOD_PROMPT_USER;
                } else if (currentAction == AOD_PROMPT_USER) {
                    //call the popup to get user prompt:
                    [self alertChecklistExists:clNew];
                    return; //because hey, pop-ups are not blocking, so we let the pop u call this funtion again with instructions
                }
            }
        }
    }
}


#pragma mark - alerts
+ (void) alertChecklistExists:(Checklist*)checklist {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: ALERT_TITLE_CHECKLIST_EXISTS
                                                    message:[NSString stringWithFormat:@"NAME: %@\nTYPE: %@",checklist.name, checklist.type]
                                                     delegate:self
                                            cancelButtonTitle:nil
                                            otherButtonTitles:nil];
    [alert addButtonWithTitle:@"Keep Existing"];
    [alert addButtonWithTitle:@"Keep New"];
    [alert addButtonWithTitle:@"Keep Both"];
    
    [alert show];
}

//alert response handler
+ (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    //if ([title isEqualToString: ALERT_TITLE_CHECKLIST_EXISTS]) {
        //NSLog(@"selected button is: %@", [alertView buttonTitleAtIndex:buttonIndex]);
    //}
    
    switch (buttonIndex) {
        case 0:
            NSLog(@"KEEP EXISTING");
            [ImportExport duplicateChecklistCheck:AOD_KEEP_OLD];
            break;
        case 1:
            NSLog(@"KEEP NEW");
            [ImportExport duplicateChecklistCheck:AOD_KEEP_NEW];
            break;
        case 2:
            NSLog(@"KEEP BOTH");
            [ImportExport duplicateChecklistCheck:AOD_KEEP_BOTH];
            break;
        default:
            break;
    }
    //[ImportExport duplicateChecklistCheck:AOD_PROMPT_USER];
    
    //dismiss is automatic...
    
}


#pragma mark - helper methods

//remove leading and trailing whitespace from a string;
+ (NSString*)trimWhitespace:(NSString*)str {
    NSString * trimmed = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if([trimmed isEqualToString:@"(nil)"]) trimmed = @"";
    return trimmed;
}

@end

