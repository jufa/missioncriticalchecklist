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
    NSLog(fields);
    return nil;
}


-(void) addChecklistsFromFile:(NSFileHandle*) file {
    //populate the mamaged object with data from a file
    
    //what about duplicates? how is one defined? checksum?
    
    //TODO: Register a file extention/mime type so that when opened, ithis app will have the appropriate intercept. i.e. intents
}


@end

