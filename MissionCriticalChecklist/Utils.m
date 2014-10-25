//
//  Utils.m
//  MissionCriticalChecklist
//
//  Created by Jeremy Kuzub on 2014-09-13.
//  Copyright (c) 2014 jufaintermedia. All rights reserved.
//

#import "Utils.h"

@implementation Utils
@synthesize moc;

+ (CGFloat)measureHeightOfUITextView:(UITextView *)textView
{
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
        // @See: http://stackoverflow.com/questions/19046969
        // This is the code for iOS 7. contentSize no longer returns the correct value, so
        // we have to calculate it.
        //
        // This is partly borrowed from HPGrowingTextView, but I've replaced the
        // magic fudge factors with the calculated values (having worked out where
        // they came from)
        
        [textView.layoutManager ensureLayoutForTextContainer:textView.textContainer];
        
        CGRect frame = textView.bounds;
        
        // Take account of the padding added around the text.
        
        UIEdgeInsets textContainerInsets = textView.textContainerInset;
        UIEdgeInsets contentInsets = textView.contentInset;
        
        CGFloat leftRightPadding = textContainerInsets.left + textContainerInsets.right + textView.textContainer.lineFragmentPadding * 2 + contentInsets.left + contentInsets.right;
        CGFloat topBottomPadding = textContainerInsets.top + textContainerInsets.bottom + contentInsets.top + contentInsets.bottom;
        
        frame.size.width -= leftRightPadding;
        frame.size.height -= topBottomPadding;
        
        NSString *textToMeasure = textView.text;
        if ([textToMeasure hasSuffix:@"\n"])
        {
            textToMeasure = [NSString stringWithFormat:@"%@-", textView.text];
        }
        
        // NSString class method: boundingRectWithSize:options:attributes:context is
        // available only on ios7.0 sdk.
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
        
        NSDictionary *attributes = @{ NSFontAttributeName: textView.font, NSParagraphStyleAttributeName : paragraphStyle };
        
        CGRect size = [textToMeasure boundingRectWithSize:CGSizeMake(CGRectGetWidth(frame), MAXFLOAT)
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:attributes
                                                  context:nil];
        
        CGFloat measuredHeight = ceilf(CGRectGetHeight(size) + topBottomPadding);
        return measuredHeight;
    }
    else
    {
        return textView.contentSize.height;
    }
}

+ (int)getTotalRows:(UITableView *)tableView {
    int r = 0;
    int sMax = [tableView numberOfSections];
    for(int section = 0; section < sMax; section++){
        r = r + [tableView numberOfRowsInSection:section];
    }
    return r;
}

#pragma mark - fetched results controllers and managed object handling

//Checklist:

+(NSFetchedResultsController*) checklistFetchedResultsController:(NSFetchedResultsController*)fetchedResultsController
    withChecklistName:(NSString*)checklistName
    withDelegate:(id)delegate
{
    NSManagedObjectContext * context = [(AppDelegate *) [[UIApplication sharedApplication] delegate] managedObjectContext];
    
    if (fetchedResultsController != nil)  {
        [NSFetchedResultsController deleteCacheWithName:@"root"];
        return fetchedResultsController;
    }
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ChecklistItem" inManagedObjectContext: context];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"action like %@ and checklist like %@", @"*", self.checklist.name];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"checklist.name == %@",checklistName];
    [fetchRequest setPredicate:predicate];
    // Specify how the fetched objects should be sorted
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    fetchedResultsController.delegate = delegate;
    
    return fetchedResultsController;
}


//Checklist Collection:

+(NSFetchedResultsController*) checklistCollectionFetchedResultsController:(NSFetchedResultsController*)fetchedResultsController withDelegate:(id)delegate
{
    NSManagedObjectContext * context = [(AppDelegate *) [[UIApplication sharedApplication] delegate] managedObjectContext];
    
    if (fetchedResultsController != nil)  {
        [NSFetchedResultsController deleteCacheWithName:@"root"];
        return fetchedResultsController;
    }
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Checklist" inManagedObjectContext: context];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"action like %@ and checklist like %@", @"*", self.checklist.name];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name like %@", @"*"];
    [fetchRequest setPredicate:predicate];
    // Specify how the fetched objects should be sorted
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    fetchedResultsController.delegate = delegate;
    
    return fetchedResultsController;
}

+ (NSString*)nowAsString {
    NSString * now;
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.timeStyle = NSDateFormatterNoStyle;
    df.dateFormat = @"yyyyMMMdd-hhmmss";
    NSDate * nowDate = [[NSDate alloc] init]; //'now' when using default init
    now = [df stringFromDate:nowDate];
    return now;
}


@end
