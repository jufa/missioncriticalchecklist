//
//  ChecklistCollectionViewController.m
//  MissionCriticalChecklist
//
//  Created by Jeremy Kuzub on 2014-08-02.
//  Copyright (c) 2014 jufaintermedia. All rights reserved.
//

#import "ChecklistCollectionViewController.h"

@interface ChecklistCollectionViewController ()

@property BOOL inReorderingOperation;
@property Checklist* checklistToEdit;

@end

@implementation ChecklistCollectionViewController


@synthesize fetchedResultsController = _fetchedResultsController;

#pragma mark -
#pragma mark  Add checklist view controller delegate implementation
-(void) addChecklistViewControllerDidCancel:(Checklist *)checklistToDelete{
    if(!self.tableView.isEditing){
        //delete managed object
        [self.managedObjectContext deleteObject:checklistToDelete];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(void) addChecklistViewControllerDidSave:(Checklist *)checklistToSave{
    
    //if we are not in editing mode, it's a new checklist inserted, if we ARE in editing mode, we are editing an existing checklist and no insertion stuff is needed:
    if(!self.tableView.isEditing){
        //assign the new items index based on last hilited cell and reflow  index values below it:
        NSIndexPath* path = [self.tableView  indexPathForSelectedRow];
        NSInteger insertAt = -1;
        if(path) insertAt = path.row+1;
        
        self.inReorderingOperation = YES;
        
        NSMutableArray *array = [[self.fetchedResultsController fetchedObjects] mutableCopy];
        
        if(insertAt == -1) insertAt = [array count];
        
        int newIndex;
        for (int i=0; i<[array count]; i++)
        {
            if(i<path.row+1) newIndex = i;
            else newIndex= i+1;
            [(NSManagedObject *)[array objectAtIndex:i] setValue:[NSNumber numberWithInt:i] forKey:@"index"];
        }
        checklistToSave.index = [NSNumber numberWithInt:insertAt];
        self.inReorderingOperation = NO;
    }
    
    //save managed object
    NSError *error = nil;
    NSManagedObjectContext *context =  self.managedObjectContext;
    if(![context save:&error]){
        //TODO: handle error:
        NSLog(@"Error saving new checklist ");
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.tableView beginUpdates];
    [self.tableView reloadData];
    [self.tableView endUpdates];
}

#pragma mark - segue management

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //segue for modal to add new checklist:
    if( [[segue identifier] isEqualToString:@"addChecklist"]) {
        AddChecklistViewController *acvc = (AddChecklistViewController*)[segue destinationViewController];
        acvc.delegate = self;
        Checklist* newChecklist = (Checklist*)[NSEntityDescription insertNewObjectForEntityForName:@"Checklist" inManagedObjectContext:[self managedObjectContext]];
        
        int insertionIndex = [[self.fetchedResultsController fetchedObjects] count]+1;
        if ([self.tableView indexPathForSelectedRow] != nil) {
            insertionIndex = [self.tableView indexPathForSelectedRow].row+1;
        }
        newChecklist.index = [NSNumber numberWithInt:insertionIndex];
        acvc.currentChecklist = newChecklist;
        acvc.mode = @"add";
    }
    //segue for modal to edit selected checklist name and type:
    if( [[segue identifier] isEqualToString:@"editChecklistDetails"]) {
        
        AddChecklistViewController *acvc = (AddChecklistViewController*)[segue destinationViewController];
        acvc.delegate = self;
        acvc.currentChecklist = self.checklistToEdit;
        acvc.mode = @"edit";
    }
    
    //segue to show a checklist:
    if ([segue.identifier isEqualToString:@"showChecklist"]) {
        
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        //NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        
        Checklist* checklist = (Checklist*)[self.fetchedResultsController objectAtIndexPath:indexPath];
        
        ChecklistViewController *cltvc = segue.destinationViewController;
        
        //pass data to checklist:
        [cltvc loadChecklist:checklist];
        
        //set the title to the name of the checklist:
        [cltvc setTitle:checklist.name];
        
        //segue will happen automatically at this point
    }
}

#pragma mark - INIT
- (id)init:(UITableViewStyle)style
{
    //self = [super init:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //allow row seletion in editing mode:
    self.tableView.allowsSelectionDuringEditing = YES;
    
    self.managedObjectContext = [(AppDelegate *) [[UIApplication sharedApplication] delegate] managedObjectContext];
    
    
    NSError *error = nil;
    if(![[self fetchedResultsController] performFetch:&error]){
        NSLog(@"Error in fetching checklist collection: %@",error);
        abort();
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    NSInteger numSec = [[self.fetchedResultsController sections]count  ];
    return numSec;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    id <NSFetchedResultsSectionInfo> secInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    NSInteger numRows = [secInfo numberOfObjects];
    return numRows;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChecklistCollectionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"Cell" forIndexPath:indexPath];
    
    // Configure the cell...
    Checklist *checklist = [self.fetchedResultsController objectAtIndexPath:indexPath];
    //cell.typeTextField.text = checklist.type;
    //cell.nameTextField.text = checklist.name;
    [cell updateWithData:checklist];
    return cell;
}

#pragma mark - User interaction

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    //TODO: add editing functionality if in edit mode:
    //check if in edit mode:
    if(self.tableView.isEditing){
        
        //how do we go from indexpath to managed object?
        self.checklistToEdit = (Checklist*)[self.fetchedResultsController objectAtIndexPath:indexPath];
        
        //segue to deitor, this time it will be prepopped:
        [self performSegueWithIdentifier: @"editChecklistDetails" sender: self];
        
    } else {
        //[tableView deselectRowAtIndexPath:indexPath animated:NO];
        [self performSegueWithIdentifier: @"showChecklist" sender: self];
        
    }
    
}


/*
 -(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
 return [[[self.fetchedResultsController sections] objectAtIndex:section] action];
 }
 */

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return self.tableView.isEditing; //so User can't swipt to reveal delete while in run mode
}


#pragma mark - delete cell handler
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        Checklist* checklist = (Checklist*)[self.fetchedResultsController objectAtIndexPath:indexPath];
        [self.managedObjectContext deleteObject:checklist];
        
        //now expect the FRC to trigger methods to allow table update.
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}



/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Fetch Results Controller section
-(NSFetchedResultsController*) fetchedResultsController {
    
    _fetchedResultsController = [Utils checklistCollectionFetchedResultsController:_fetchedResultsController withDelegate:self];
    
    
    /*
    if (_fetchedResultsController != nil)  {
        return _fetchedResultsController;
    }
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Checklist" inManagedObjectContext: [self managedObjectContext]];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name like %@", @"*"];
    [fetchRequest setPredicate:predicate];
    // Specify how the fetched objects should be sorted
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[self managedObjectContext] sectionNameKeyPath:nil cacheName:nil];
    _fetchedResultsController.delegate = self;
    */
    
    return _fetchedResultsController;
}

//user pressed the edit button. Put table view in reorder edit mode:
- (IBAction)beginEdit:(id)sender {
    UIButton* btn = (UIButton *)sender;
    if(self.tableView.isEditing){
        
        //[btn setTitle:@"Edit" forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"ico-edit.png"] forState:UIControlStateNormal];

        //end editing and commit changes:
        [self.tableView setEditing:NO animated:YES];
        
        
        NSError *error;
        BOOL success = [self.fetchedResultsController performFetch:&error];
        if (!success)
        {
            // Handle error
        }
        
        success = [[self managedObjectContext] save:&error];
        if (!success)
        {
            // Handle error
        }
        
        [self.tableView reloadData]; //debug
        
    } else {
        self.inReorderingOperation = NO;
        //[btn setTitle:@"Done Editing" forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"ico-editdone.png"] forState:UIControlStateNormal];

        [self.tableView setEditing:YES animated:YES];
        /*
        //set all cells into editing mode:
        NSMutableArray *cells = [[NSMutableArray alloc] init];
        for (NSInteger j = 0; j < [self.tableView numberOfSections]; ++j)
        {
            for (NSInteger i = 0; i < [self.tableView numberOfRowsInSection:j]; ++i)
            {
                [cells addObject:[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]]];
            }
        }
        
        for (ChecklistCollectionTableViewCell *cell in cells)
        {
            [cell editingModeStart];
        }
        */
        
        
    }
}

- (IBAction)resetChecklist:(id)sender {
    
    
    NSMutableArray *array = [[self.fetchedResultsController fetchedObjects] mutableCopy];
    
    
    for (int i=0; i<[array count]; i++)
    {
        [(NSManagedObject *)[array objectAtIndex:i] setValue:[NSNumber numberWithBool:NO] forKey:@"checked"];
        [(NSManagedObject *)[array objectAtIndex:i] setValue:nil forKey:@"timestamp"];
    }
    
    
    //and resave the whole managed object context:
    NSError *error;
    [self.managedObjectContext save:&error];
    
    [self.tableView reloadData];
    
    
}

-(void) controllerWillChangeContent:(NSFetchedResultsController *)controller{
    [self.tableView beginUpdates];
    
}

-(void) controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

-(void) controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath{
    
    UITableView *tableView = self.tableView;
    
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObjects:newIndexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete: {
            //update indices below deleted item:
            
            self.inReorderingOperation = YES;
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            NSMutableArray *array = [[self.fetchedResultsController fetchedObjects] mutableCopy];
            
            //int newIndex;
            for (int i=0; i<[array count]; i++)
            {
                [(NSManagedObject *)[array objectAtIndex:i] setValue:[NSNumber numberWithInt:(i)] forKey:@"index"];
            }
            self.inReorderingOperation = NO;
            
            [tableView reloadData]; //debug
           
        }
            break;
        case NSFetchedResultsChangeUpdate: {
            
            Checklist* cli = [self.fetchedResultsController objectAtIndexPath:indexPath];
            ChecklistCollectionTableViewCell  *cell = (ChecklistCollectionTableViewCell*) [tableView cellForRowAtIndexPath:indexPath];
            cell.typeTextField.text = cli.type;
            cell.nameTextField.text = cli.name;
        }
            break;
            
        case NSFetchedResultsChangeMove:
            if(!self.inReorderingOperation){
                //[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                //[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
            break;
    }
    
}

-(void) controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    ;
}



- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    
    
    self.inReorderingOperation = YES;
    
    NSMutableArray *array = [[self.fetchedResultsController fetchedObjects] mutableCopy];
    id objectToMove = [array objectAtIndex:fromIndexPath.row];
    [array removeObjectAtIndex:fromIndexPath.row];
    [array insertObject:objectToMove atIndex:toIndexPath.row];
    
    
    for (int i=0; i<[array count]; i++)
    {
        [(NSManagedObject *)[array objectAtIndex:i] setValue:[NSNumber numberWithInt:i] forKey:@"index"];
    }
    
    
    self.inReorderingOperation = NO;
    
    
    
}


#pragma mark ChecklistCell section


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    /*
     if ([indexPath compare:selectedIndexPath] == NSOrderedSame) {
     return 80;
     }
     */
    return 96;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark - mail export handling

-(IBAction)exportChecklistCollectionByEmail:(id)sender {
    
    //build checklist string test. TODO: implement:
    
    NSData * attachmentData = [ImportExport buildChecklistFile];
    
    // Email Subject
    NSString *emailTitle = @"MCC Exported Checklist Collection";
    // Email Content
    NSString *messageBody = @"See attached";
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:@"jeremykuzub@gmail.com"];
    //toRecipents = [NSArray arrayWithObjects: self.emailField.text, nil];
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
        mc.mailComposeDelegate = self;
        [mc setSubject:emailTitle];
        [mc setMessageBody:messageBody isHTML:NO];
        [mc setToRecipients:toRecipents];
        [mc addAttachmentData:attachmentData mimeType:@"text/plain" fileName:[NSString stringWithFormat:@"MCC-ChecklistExport-%@.txt",[Utils nowAsString]]];
        mc.modalPresentationStyle = UIModalPresentationFormSheet;
        
        // Present mail view controller on screen
        [self presentViewController:mc animated:YES completion:nil];

    } else {
        //TODO: handle error
        NSLog(@">>>>ERROR<<<< exportChecklistCollectionByEmail: cannot send email from this device. Mail may not be configured.");
    }
}


//TODO: error and success handling for mailout:
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}


@end
