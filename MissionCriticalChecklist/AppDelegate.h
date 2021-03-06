//
//  AppDelegate.h
//  MissionCriticalChecklist
//
//  Created by Jeremy Kuzub on 2014-08-02.
//  Copyright (c) 2014 jufaintermedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImportExport.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) NSURL * fileImportUrl;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
