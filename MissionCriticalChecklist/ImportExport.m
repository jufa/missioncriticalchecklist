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
#import "Utils.h";
//TODO: reference this for opening email extentions: https://developer.apple.com/library/ios/qa/qa1587/_index.html


@implementation ImportExport {
    // private instance variables:
    
    NSString* checklistCollectionString;
};

//@synthesize fetchedResultsController = _fetchedResultsController;


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
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Checklist" inManagedObjectContext: moc];
    
    NSMutableDictionary *fields = [NSMutableDictionary dictionary];
    
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


-(void) addChecklistsFromFile:(NSFileHandle*) file {
    //populate the mamaged object with data from a file
    
    //what about duplicates? how is one defined? checksum?
    
    //TODO: Register a file extention/mime type so that when opened, ithis app will have the appropriate intercept. i.e. intents
}

+(BOOL) importChecklistsFromURL:(NSURL*) url {
    
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
                    if( [[ImportExport trimWhitespace: checklistEntries[0]] isEqualToString:cl.name]){
                        NSLog(@"ALREADY exists: %@ as %@",checklistEntries[0], cl.name);
                        checklistExists = YES;
                    } else {
                        ;
                    }
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


//helper to remove leading and trailing whitespace from a string;
//TODO: put in utils.m?
+ (NSString*)trimWhitespace:(NSString*)str {
    return [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

@end

