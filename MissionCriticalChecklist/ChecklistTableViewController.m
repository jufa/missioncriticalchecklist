//
//  ChecklistTableViewController.m
//  MissionCriticalChecklist
//
//  Created by Jeremy Kuzub on 2014-08-02.
//  Copyright (c) 2014 jufaintermedia. All rights reserved.
//

#import "ChecklistTableViewController.h"


@interface ChecklistTableViewController ()

@property BOOL inReorderingOperation;
@property ChecklistItem* checklistItemToEdit;

@end

@implementation ChecklistTableViewController


@synthesize fetchedResultsController = _fetchedResultsController;

#pragma mark - initialization methods
-(void)loadChecklist:(Checklist *)checklist {
    
    self.checklistName = checklist.name;
    self.checklist = checklist;
    
    self.managedObjectContext = [(AppDelegate *) [[UIApplication sharedApplication] delegate] managedObjectContext];


    NSError *error = nil;
    if(![[self fetchedResultsController] performFetch:&error]){
        NSLog(@"Error in fetching checklist: %@",error);
        abort();
    }
}

#pragma mark -
#pragma mark  Add checklist item view controller delegate implementation
-(void) addChecklistItemViewControllerDidCancel:(ChecklistItem *)checklistItemToDelete{
    if(!self.tableView.isEditing){
        //delete managed object
        [self.managedObjectContext deleteObject:checklistItemToDelete];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) addChecklistItemViewControllerDidSave:(ChecklistItem *)checklistItemToSave{
    
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
        
        checklistItemToSave.index = [NSNumber numberWithInt:insertAt];
        
        
        self.inReorderingOperation = NO;
    }
    //save managed object
    NSError *error = nil;
    NSManagedObjectContext *context =  self.managedObjectContext;
    if(![context save:&error]){
        NSLog(@"Error saving new checklist item");
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.tableView reloadData];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //segue for modal to add new checklistItem:
    if( [[segue identifier] isEqualToString:@"addChecklistItem"]) {
        AddChecklistItemViewController *acvc = (AddChecklistItemViewController*)[segue destinationViewController];
        acvc.delegate = self;
        ChecklistItem* newChecklistItem = (ChecklistItem*)[NSEntityDescription insertNewObjectForEntityForName:@"ChecklistItem" inManagedObjectContext:[self managedObjectContext]];
        
        int insertionIndex = [[self.fetchedResultsController fetchedObjects] count]+1;
        if ([self.tableView indexPathForSelectedRow] != nil) {
            insertionIndex = [self.tableView indexPathForSelectedRow].row+1;
        }
        //set up inital properties:
        newChecklistItem.index = [NSNumber numberWithInt:insertionIndex];
        
        //must use the mutable set method. it will automatically dispatch the right event to ensure inverse relationship is set
        NSMutableSet *cli = [self.checklist mutableSetValueForKey:@"checklistItems"];
        [cli addObject:newChecklistItem];
        acvc.mode = @"add";
        acvc.currentChecklistItem = newChecklistItem;
    }
    //segue for modal to edit selected checklist name and type:
    if( [[segue identifier] isEqualToString:@"editChecklistItemDetails"]) {
        
        AddChecklistItemViewController *acvc = (AddChecklistItemViewController*)[segue destinationViewController];
        acvc.delegate = self;
        acvc.currentChecklistItem = self.checklistItemToEdit;
        acvc.mode = @"edit";
    }

    if( [[segue identifier] isEqualToString:@"showChecklist"]) {
        NSError *error = nil;
        if(![[self fetchedResultsController] performFetch:&error]){
            NSLog(@"Error in fetching checklist: %@",error);
            abort();
        }
    }
}

#pragma mark - INIT
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    //for some reason this goes out of scope on function exit:
    if (self) {
        // Custom initialization
        self.managedObjectContext = [(AppDelegate *) [[UIApplication sharedApplication] delegate] managedObjectContext];
        }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //allow row seletion in editing mode:
    self.tableView.allowsSelectionDuringEditing = YES;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)getNumberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> secInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [secInfo numberOfObjects];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [[self.fetchedResultsController sections]count  ];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self getNumberOfRowsInSection:section];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChecklistItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"Cell" forIndexPath:indexPath];
    
    // Configure the cell...
    ChecklistItem *checklistItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.actionTextField.text = checklistItem.action;
    cell.detailTextField.text = checklistItem.detail;//NSString stringWithFormat:@"%@",checklistItem.index];
    //switch:
    [cell.check setOn:checklistItem.checked.boolValue animated:NO];
    [cell setTimestamp:checklistItem.timestamp];
    return cell;
}

#pragma mark - User interaction

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //check if in edit mode:
    if(self.tableView.isEditing){
        
        //how do we go from indexpath to managed object?
        self.checklistItemToEdit = (ChecklistItem*)[self.fetchedResultsController objectAtIndexPath:indexPath];
        
        //segue to deitor, this time it will be prepopped:
        [self performSegueWithIdentifier: @"editChecklistItemDetails" sender: self];
        
    } else {
        ;
        
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



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        //[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        ChecklistItem* checklistItem = (ChecklistItem*)[self.fetchedResultsController objectAtIndexPath:indexPath];
        [self.managedObjectContext deleteObject:checklistItem];
        
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
    if (_fetchedResultsController != nil)  {
        [NSFetchedResultsController deleteCacheWithName:@"root"];
        return _fetchedResultsController;
    }
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ChecklistItem" inManagedObjectContext: [self managedObjectContext]];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"action like %@ and checklist like %@", @"*", self.checklist.name];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"checklist.name == %@",self.checklist.name];
    [fetchRequest setPredicate:predicate];
    // Specify how the fetched objects should be sorted
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[self managedObjectContext] sectionNameKeyPath:nil cacheName:nil];
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}

//user pressed the edit button. Put table view in reorder edit mode:
- (IBAction)beginEdit:(id)sender {
    UIButton* btn = (UIButton *)sender;
    if(self.tableView.isEditing){
        
        [btn setTitle:@"Edit" forState:UIControlStateNormal];
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
        
        //set all cells into editing mode:
        NSMutableArray *cells = [[NSMutableArray alloc] init];
        for (NSInteger j = 0; j < [self.tableView numberOfSections]; ++j)
        {
            for (NSInteger i = 0; i < [self.tableView numberOfRowsInSection:j]; ++i)
            {
                [cells addObject:[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]]];
            }
        }
        for (ChecklistItemTableViewCell *cell in cells)
        {
            [cell editingModeEnd];
        }
        
        
        [self.tableView reloadData]; //debug
        
    } else {
        self.inReorderingOperation = NO;
        [btn setTitle:@"Done Editing" forState:UIControlStateNormal];
        [self.tableView setEditing:YES animated:YES];
        
        //set all cells into editing mode:
        NSMutableArray *cells = [[NSMutableArray alloc] init];
        for (NSInteger j = 0; j < [self.tableView numberOfSections]; ++j)
        {
            for (NSInteger i = 0; i < [self.tableView numberOfRowsInSection:j]; ++i)
            {
                [cells addObject:[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]]];
            }
        }
        for (ChecklistItemTableViewCell *cell in cells)
        {
            [cell editingModeStart];
        }
        
        
        
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
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeUpdate: {
            
            ChecklistItem* cli = [self.fetchedResultsController objectAtIndexPath:indexPath];
            ChecklistItemTableViewCell  *cell = (ChecklistItemTableViewCell*) [tableView cellForRowAtIndexPath:indexPath];
            cell.actionTextField.text = cli.action;
            cell.detailTextField.text = cli.detail;
            [cell.check setOn: cli.checked.boolValue];
            [cell setTimestamp:cli.timestamp];
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


#pragma mark -
#pragma mark ChecklistCell section

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    /*
     if ([indexPath compare:selectedIndexPath] == NSOrderedSame) {
        return 80;
    }
     */
    return 80;
}


- (IBAction)checkedOff:(id)sender {

    //what switch? get reference so we can determine state.
    UISwitch *sw = (UISwitch *)sender;
    
    //how weird is this?! We need the index of the switch:
    //see : http://stackoverflow.com/questions/23265291/access-uiswitch-in-prototype-cell
    
    //CGPoint pointInTable = [sw convertPoint:sw.bounds.origin toView:self.tableView];
    //NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:pointInTable];
    
    //alternatively we can just grab the selected row, since the row has to have been selected in order to toggle the switch.
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];

    //ok, so now we know the index of the checked item, lets  update that in the managed object
    ChecklistItem* cli = [[_fetchedResultsController fetchedObjects] objectAtIndex:indexPath.row];
    
    //change the switch setting
    cli.checked = [NSNumber numberWithBool:sw.isOn];
    
    cli.timestamp = [NSDate date];

    //and resave the whole managed object context:
    NSError *error;
    [self.managedObjectContext save:&error];
    
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

@end
