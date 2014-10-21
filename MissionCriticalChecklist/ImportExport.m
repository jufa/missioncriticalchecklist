//
//  ImportExport.m
//  MissionCriticalChecklist
//
//  Created by Jeremy Kuzub on 2014-10-20.
//  Copyright (c) 2014 jufaintermedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImportExport.h"

//TODO: reference this for opening email extentions: https://developer.apple.com/library/ios/qa/qa1587/_index.html


@implementation ImportExport {
    // private instance variables:
}


-(NSString*) buildChecklistString:(Checklist*) checklist {
    //TODO: essentially serialize the Managed Object that matches the checklist, return an NSString
    return nil;
}

- (NSFileHandle*) createChecklistFile {
    //TODO: build up the file using multiple calls to buildChecklistString
    return nil;
}

-(void) addChecklistsFromFile:(NSFileHandle*) file {
    //populate the mamaged object with data from a file
    
    //what about duplicates? how is one defined? checksum?
    
    //TODO: Register a file extention/mime type so that when opened, ithis app will have the appropriate intercept. i.e. intents
}


@end

