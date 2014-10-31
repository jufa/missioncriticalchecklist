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
#define ALERT_TITLE_IMPORT_CHECKLISTS @"Import Checklists"
#define AOD_KEEP_OLD 1
#define AOD_KEEP_NEW 2
#define AOD_KEEP_BOTH 3
#define AOD_PROMPT_USER 4
#define AOD_USE_DEFAULT 5




@implementation ImportExport {
    //global variables for all class instance, precede by static keyword.
};

static NSURL* _importUrl;
+ (NSURL*)importUrl {
    return _importUrl;
}
static int _defaultImportAction;
+ (int)defaultImportAction {
    return _defaultImportAction;
}
static int _checklistsToImport;
+ (int)checklistsToImport {
    return _checklistsToImport;
}
static NSMutableArray* _checklists;
+ (NSMutableArray*)checklists {
    return _checklists;
}


/**
 *
 * returns a string containing the custom markdown version of the coredata checklists and their checklist items, in order
 *
 */
 
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
    
    // Build the path, and create if needed:
    NSString* filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* fileName = @"MCC-checklists.txt";
    NSString* fileAtPath = [filePath stringByAppendingPathComponent:fileName];
    NSData * data = nil;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:fileAtPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:fileAtPath error:&error]; //TODO: error handling
    }
    if(error) {
        NSLog(@"ERROR: ImportExport::buildChecklistFile: could not remove a previous local copy of checklist export file");
        return nil;
    }
        
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileAtPath]) {
        [[NSFileManager defaultManager] createFileAtPath:fileAtPath contents:nil attributes:nil];
        if (![[fs dataUsingEncoding:NSUTF8StringEncoding] writeToFile:fileAtPath atomically:NO]){
            //TODO: error handling
            NSLog(@"ERROR: ImportExport::buildChecklistFile: Could not write file to path");
        }
        data = [NSData dataWithContentsOfFile:fileAtPath];
    } else {
        //TODO: error handling
        NSLog(@"ERROR: ImportExport::buildChecklistFile: Could not build output file. It already exists");
    }
    return data;
}


//Helper function for buildChecklistFile - assembles a string of checklist items for the specified checklist:
+ (NSString*) buildChecklistString:(Checklist*) checklist {
    
    //NSManagedObjectContext *moc = [(AppDelegate *) [[UIApplication sharedApplication] delegate] managedObjectContext];
    
    NSError *error = nil;
    NSFetchedResultsController *frc = nil;
    
    frc = [Utils checklistFetchedResultsController:frc withChecklistName:checklist.name withDelegate:self];
    
    if(![frc performFetch:&error]){
        NSLog(@"buildChecklistString: Error in fetching checklist: %@",error);
        abort();
    }

    ChecklistItem * cli;
    NSString* cls=@"";
    
    for (id object in [frc fetchedObjects]) {
        cli = (ChecklistItem*)object;
        cls = [cls stringByAppendingString: [NSString stringWithFormat:@"--- %@ -- %@ -- %@ --\n",cli.action,cli.detail, cli.icon ]];
    }
    return cls;
}


+ (int) numberOfChecklistsInUrlString:(NSURL*)url {
    int count = -1;
    return count;
}



/**
 *
 * text file at URL is parsed into array of checklist and array of checklistitem objects. 
 * Because of duoicate detection and handinlg, and because posting UIALerts is non-blocking, this is implmented in a state machine pattern:
 * parseChecklistFromUrl adds all new checklists and associated items from the URL. An array of these new checklists is created for the next step:
 * duplicateChecklistCheck is then called to walk through this array of new checklists. If it finds a duplicate, it aborts and hands off control to
 * alertChecklistExists which prompts user for action. 
 * The user response handler then calls duplicateChecklistCheck with the corresponding action parameter (keep old, new or both), which updates the checklists as well as the array of new checklists.
 * then calls it again with the ask User action
 *
 */

+ (void) parseChecklistFromUrl {
    
    NSURL* url = _importUrl;
    
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
    
    //check for duplicates:
    if(_defaultImportAction == AOD_PROMPT_USER) {
        [self duplicateChecklistCheck:AOD_PROMPT_USER];
    } else {
        while ([_checklists count] > 0) {
            [self duplicateChecklistCheck:AOD_USE_DEFAULT];
        }
    }
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
        NSLog(@"ERROR: ImportExport::duplicateChecklistCheck: cannot perform fetch of checklistCollections" );
        return;
    }
    
    int currentAction = actionOnDuplicates;
    if(_defaultImportAction != AOD_PROMPT_USER) currentAction = _defaultImportAction;
    if([_checklists count] == 0) return;//TODO: send success alert to user here with number of checklists imported.
    NSLog(@"checklists left: %d",[_checklists count]);
    for (id object in [frc fetchedObjects]) {
        Checklist* clExisting = (Checklist*)object;
        if(clExisting.objectID == clNew.objectID) continue;
        if([clExisting.name isEqualToString:clNew.name]){
            if([clExisting.type isEqualToString:clNew.type]){
                switch (currentAction) {
                    case AOD_KEEP_OLD:
                        [_checklists removeLastObject];
                        [moc deleteObject:clNew];
                        break;
                    case AOD_KEEP_NEW:
                        [_checklists removeLastObject];
                        [moc deleteObject:clExisting];
                        break;
                    case AOD_KEEP_BOTH:
                        [_checklists removeLastObject];
                        break;
                    case AOD_PROMPT_USER:
                        //call the popup to get user prompt:
                        [self alertChecklistExists:clNew];
                        break;
                    default:
                        break;
                }
                return;
            }
        }
    }
}




#pragma mark - alerts
+ (void) promptImportChecklistsFromUrl:(NSURL*)url {
    _importUrl = url;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: ALERT_TITLE_IMPORT_CHECKLISTS
                                                    message:[NSString stringWithFormat:@"Importing %d new Checklists. Select your default action if duplicates are found:",[ImportExport numberOfChecklistsInUrlString:url]]
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel Import"
                                          otherButtonTitles:nil];
    [alert addButtonWithTitle:@"Keep Existing"];
    [alert addButtonWithTitle:@"Keep New"];
    [alert addButtonWithTitle:@"Keep Both"];
    [alert addButtonWithTitle:@"Ask for Each"];
    [alert show];
}



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
    if([alertView.title isEqualToString:ALERT_TITLE_CHECKLIST_EXISTS]){
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
        [ImportExport duplicateChecklistCheck:AOD_PROMPT_USER];
        //alert dismiss is automatic...
    } else if ([alertView.title isEqualToString:ALERT_TITLE_IMPORT_CHECKLISTS]) {
        NSLog(@"button: %d",buttonIndex);
        switch (buttonIndex) {
            case 1:
                NSLog(@"KEEP OLD BY DEFAULT");
                _defaultImportAction = AOD_KEEP_OLD;
                break;
            case 2:
                NSLog(@"KEEP NEW BY DEFAULT");
                _defaultImportAction = AOD_KEEP_NEW;
                break;
            case 3:
                NSLog(@"KEEP BOTH BY DEFAULT");
                _defaultImportAction = AOD_KEEP_BOTH;
                break;
            case 4:
                NSLog(@"KEEP BOTH BY DEFAULT");
                _defaultImportAction = AOD_PROMPT_USER;
                break;
            default:
                break;
        }
        [ImportExport parseChecklistFromUrl]; //start importing
    }
}


#pragma mark - helper methods

//remove leading and trailing whitespace from a string;
+ (NSString*)trimWhitespace:(NSString*)str {
    NSString * trimmed = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if([trimmed isEqualToString:@"(nil)"]) trimmed = @"";
    return trimmed;
}



//TODO: complete if JSON interface required
+ (NSFileHandle*) buildChecklistJSON {
    //NSManagedObjectContext *moc = [(AppDelegate *) [[UIApplication sharedApplication] delegate] managedObjectContext];
    NSError *error = nil;
    NSFetchedResultsController *frc = nil;
    frc = [Utils checklistCollectionFetchedResultsController:frc withDelegate:self];
    if(![frc performFetch:&error]){
        NSLog(@"ERROR: ImportExport::buildChecklistJSON: Error in fetching checklist: %@",error);
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

@end

