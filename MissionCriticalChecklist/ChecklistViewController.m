//
//  ChecklistViewController.m
//  MissionCriticalChecklist
//
//  Created by Jeremy Kuzub on 2014-08-02.
//  Copyright (c) 2014 jufaintermedia. All rights reserved.
//

#import "ChecklistViewController.h"

#define PB_WIDTH 1048.0
#define PB_HEIGHT 30.0
#define PB_OFFSETX (1048.0-916.0)
#define PB_TEXTAREAWIDTH (1048.0-916.0)



@interface ChecklistViewController ()
@property BOOL inReorderingOperation;
@property ChecklistItem* checklistItemToEdit;
@property BOOL checklistComplete;
@property ChecklistItemTableViewCell* selectedCell;
@property NSIndexPath* selectedRow;
@property NSDate* startTimestamp; //TODO: implement this as a new managed object called "history". for now it is the same as the first scheckoff timestamp in the list

@end

@implementation ChecklistViewController {
    NSMutableArray *iconArray;
    BOOL editingMode;
}


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
    
   /*
    if(![[Utils checklistFetchedResultsController:self.fetchedResultsController withChecklistName:self.checklist.name withDelegate:self ] performFetch:&error]){
        NSLog(@"Error in fetching checklist: %@",error);
        abort();
    }
    */
    
    
    //establish checklist start time as earliest timestamp in checklist:
    self.startTimestamp = [self checklistFindEarliest];
    
}

-(NSDate*) checklistFindEarliest {
    NSDate* earliest;
    NSDate* current;
    ChecklistItem* cli;
    BOOL firstIter = YES;
    
    NSDateFormatter *mmddccyy = [[NSDateFormatter alloc] init];
    mmddccyy.timeStyle = NSDateFormatterNoStyle;
    mmddccyy.dateFormat = @"MM/dd/yyyy";
    //earliest = [mmddccyy dateFromString:@"12/31/9999]"];
    for (id object in [[self fetchedResultsController] fetchedObjects]) {
        cli = (ChecklistItem*)object;
        current = cli.timestamp;
        if([earliest compare:current] == NSOrderedDescending || firstIter){
            firstIter = NO;
            //current cli timestamp is earlier than our earliest or first iteration:
            earliest = [current copy];
        }
    }
    return earliest;
}

#pragma mark -
#pragma mark  Add checklist item view controller delegate implementation
-(void) addChecklistItemViewControllerDidCancel:(ChecklistItem *)checklistItemToDelete {
    if(!self.tableView.isEditing){
        //delete managed object
        [self.managedObjectContext deleteObject:checklistItemToDelete];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) addChecklistItemViewControllerDidSave:(ChecklistItem *)checklistItemToSave {
    
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
    
    [self refreshInterface];
}

#pragma mark - segue handler

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
- (id)init:(UITableViewStyle)style
{
    //self = [super initWithStyle:style];
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
    
    //rotation notification.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotate:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    //allow row seletion in editing mode:
    self.tableView.allowsSelectionDuringEditing = YES;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    iconArray = ChecklistItemIcons.iconList;
    
    self.selectedRow = nil;
    
    self.checklistComplete = YES; //init;
    
    editingMode = NO;
    
}

-(void) viewDidDisappear:(BOOL)animated
{
    //clean up notification callbacks:
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}


//called after initial load of subviews. Now we can layout anything we need to programmatically
- (void)viewDidLayoutSubviews
{
    [self refreshInterface];
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
    ChecklistItem *checklistItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    //send ChecklistItem data to the cell:
    [cell updateWithData:checklistItem AndStartTime:self.startTimestamp];
    
    //let the cell know when the checklist started:x
    //[cell setElapseTimeFrom: self.startTimestamp To:checklistItem.timestamp];
    
    
    //is the cell selected? let it know:
    if( self.selectedRow.row == indexPath.row && self.selectedRow != nil){
        [cell selected:YES];
    } else {
        [cell selected:NO];
    }
    
    //are we in editing mode? let the cell know:
    if(editingMode) [cell editingModeStart];
    else [cell editingModeEnd];
    
    
    return cell;
}



//NEVER CALLED
- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    NSLog(@"setEditing %i", editing);
    [super setEditing:editing animated:animated];
    editingMode = editing;
    
    //inform all visible cells:
    for (ChecklistItemTableViewCell *cell in [self.tableView visibleCells]) {
        //NSIndexPath *path = [self.tableView indexPathForCell:cell];
        //cell.selectionStyle = (self.editing && (path.row > 1 || path.section == 0)) ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleBlue;
        cell.editing = editing;
    }
}



// Override to support conditional editing of the table view.

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.tableView.isEditing; //so User can't swipt to reveal delete while in run mode
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    ChecklistItemTableViewCell* cell = (ChecklistItemTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    
    ChecklistItemTableViewCell* prevCell = (ChecklistItemTableViewCell*)[self.tableView cellForRowAtIndexPath:self.selectedRow];
    
    //check if in edit mode:
    if(self.tableView.isEditing){
        
        //how do we go from indexpath to managed object?
        self.checklistItemToEdit = (ChecklistItem*)[self.fetchedResultsController objectAtIndexPath:indexPath];
        
        //segue to deitor, this time it will be prepopped:
        [self performSegueWithIdentifier: @"editChecklistItemDetails" sender: self];
        
    } else {
        
        //make sure to do this first, as the user may select the same cell!
        if(prevCell){
            [prevCell selected: NO];
        }
        [cell selected:YES];
        
        //[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
        self.selectedCell = cell;
        self.selectedRow = indexPath;
    }
}


/*
 -(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
 return [[[self.fetchedResultsController sections] objectAtIndex:section] action];
 }
 */




// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        //[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        ChecklistItem* checklistItem = (ChecklistItem*)[self.fetchedResultsController objectAtIndexPath:indexPath];
        [self.managedObjectContext deleteObject:checklistItem]; // we let the FRC callbacks handle tableview update.
        
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

- (void)tableViewEditing:(BOOL)mode {
    editingMode = mode;
    //update visible cells:
    for (ChecklistItemTableViewCell *cell in [self.tableView visibleCells]) {
        //NSIndexPath *path = [self.tableView indexPathForCell:cell];
        //cell.selectionStyle = (self.editing && (path.row > 1 || path.section == 0)) ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleBlue;
        if(editingMode)[cell editingModeStart];
        else [cell editingModeEnd];
    }
}


#pragma mark - User interaction
- (IBAction)checklistsClick:(id)sender {
    //get a ref to the parent navigator and pop me off the view stack:
    UINavigationController *navController = self.navigationController;
    [navController popViewControllerAnimated:YES];
}

//user pressed the edit button. Put table view in reorder edit mode:
- (IBAction)beginEdit:(id)sender {
    NSLog(@"begineEdit. In editing mode?: %i",self.tableView.isEditing);
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
    }
    [self tableViewEditing:self.tableView.isEditing];
}





#pragma mark - Fetch Results Controller section

-(NSFetchedResultsController*) fetchedResultsController {
    
    _fetchedResultsController = [Utils checklistFetchedResultsController:_fetchedResultsController withChecklistName:self.checklist.name withDelegate:self];
    
    /*
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
     */
    
    return _fetchedResultsController;
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

            [cell updateWithData:cli AndStartTime:self.startTimestamp];
            /*
             ChecklistItemTableViewCell  *cell = (ChecklistItemTableViewCell*) [tableView cellForRowAtIndexPath:indexPath];
            cell.actionTextField.text = cli.action;
            cell.detailTextField.text = cli.detail;
            [cell.check setOn: cli.checked.boolValue animated:YES];
            [cell.checkLeft setOn: cli.checked.boolValue animated:YES];
            [cell setTimestamp:cli.timestamp AndStartTime:self.startTimestamp];
            
            
            //cell background:
            if(cli.checked.boolValue == YES) [cell setMode:@"complete"];
            if(cli.checked.boolValue == NO) [cell setMode:@"incomplete"];
             */
            
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
    return 80;
    
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
    
    //reset earliestChecklistCheckoff value:
    self.startTimestamp = nil;
    
    [self.tableView reloadData];
    [self refreshInterface];
    
    
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
    
    //TODO: how much of the following should be moved into the fetchedResultsController's change callback block?
    
    //hilite next task item, scroll the view:
    NSIndexPath *currRow = self.tableView.indexPathForSelectedRow;
    if(currRow.row < [Utils getTotalRows:self.tableView] - 1 ) {
        NSIndexPath *nextRow = [NSIndexPath  indexPathForRow:currRow.row + 1 inSection:currRow.section];
        //NSLog(@"newIndexPath: %@", newIndexPath);
        [self.tableView selectRowAtIndexPath:nextRow animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    }

    //update footer:
    [self refreshInterface];
    
}

-(IBAction)clicked:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    /* this is just silly, fortunately not needed.
    UIButton* btn = (UIButton*)sender;
    CGPoint center = btn.center;
    CGPoint rootViewPoint = [btn.superview convertPoint:center toView:self.tableView];
    NSIndexPath *indexPathOfButton = [self.tableView indexPathForRowAtPoint:rootViewPoint];
    
    //if(indexPath != indexPathOfButton) return;
    */
    //ok, so now we know the index of the checked item, lets  update that in the managed object
    ChecklistItem* cli = [[_fetchedResultsController fetchedObjects] objectAtIndex:indexPath.row];
    
    //change the switch setting
    //cli.checked = [NSNumber numberWithBool:sw.isOn];
    cli.checked = [NSNumber numberWithBool:!cli.checked.boolValue];
    
    cli.timestamp = [NSDate date];
    
    if(self.startTimestamp == nil) {
        self.startTimestamp  = [self checklistFindEarliest];
    };
    
    //and resave the whole managed object context:
    NSError *error;
    [self.managedObjectContext save:&error];
    
    //TODO: how much of the following should be moved into the fetchedResultsController's change callback block?
    
    //hilite next task item, scroll the view:
    NSIndexPath *currRow = self.tableView.indexPathForSelectedRow;
    if(currRow.row < [Utils getTotalRows:self.tableView] - 1 ) {
        NSIndexPath *nextRow = [NSIndexPath  indexPathForRow:currRow.row + 1 inSection:currRow.section];
        //NSLog(@"newIndexPath: %@", newIndexPath);
        [self.tableView selectRowAtIndexPath:nextRow animated:YES scrollPosition:UITableViewScrollPositionMiddle];
        //call event handler manually, since it is not called automatically:
        //self.selectedRow = nextRow;
        [self tableView:self.tableView didSelectRowAtIndexPath:nextRow];
        
    }
    
    //update footer:
    [self refreshInterface];

}

#pragma mark - Rotation detection

//so this is used as specified in viewDidLoad.
// See: http://programming.mvergel.com/2012/11/ios-didrotatefrominterfaceorientation.html#.VEHf-yldVro
-(void) didRotate:(NSNotification *)notification  {
    [self refreshInterface];
}

- (void) refreshInterface {
    self.checklistNameLabel.text = self.checklist.name;
    self.checklistTypeLabel.text = self.checklist.type;
    
    [self updateProgress];
    //TODO: more may be added later
}



#pragma mark - Footer Management

/**
 *
 * @brief refreshes the progress bar view for the checklist
 *
 */
- (void) updateProgress {
    // find out how finished we are
    // go through all items
    int totalItems = [[_fetchedResultsController fetchedObjects] count];
    ChecklistItem* cli;
    int checkedItems = 0;
    for (int i = 0; i < totalItems; i++){
        cli = [[_fetchedResultsController fetchedObjects] objectAtIndex:i];
        if (cli.checked.boolValue == YES) {
            checkedItems++;
        }
    }
    
    //load appropriate bar image:
    NSString *imageName;
    if(totalItems == checkedItems) {
        imageName = @"progress-green";
        self.checklistComplete = YES;
    } else {
        imageName = @"progress-yellow";
        if(self.checklistComplete){
            self.checklistComplete = NO;
        }
    }
    
    [self.footerImageLeft setImage:[UIImage imageNamed:imageName]];

    
    //translate fraction complete to x frame offset for progress indicator:
    
    float offset = 0.0;
    if(totalItems>0) {
        offset = (float)checkedItems/(float)totalItems;
    }
    /*
    CGRect newFrame = self.footerImageLeft.frame;
    newFrame.origin.x = offset * (self.view.frame.size.width - PB_TEXTAREAWIDTH) - PB_WIDTH;
    newFrame.size.width = PB_WIDTH;
    newFrame.size.height = PB_HEIGHT;
    self.footerImageLeft.frame = newFrame;
    */
    //[self.progressBarOffset setConstant: (1.0 - offset) * (self.view.frame.size.width - PB_TEXTAREAWIDTH) + PB_TEXTAREAWIDTH];
    
    float target = (1.0 - offset) * (self.view.frame.size.width - PB_TEXTAREAWIDTH) + PB_TEXTAREAWIDTH;

    [self.view layoutIfNeeded];
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.progressBarOffset.constant = target;
                         [self.view layoutIfNeeded]; // Called on parent view
                     }];
    
    // text update:
    NSString *footerString;
    footerString = [NSString stringWithFormat:@"%d/%d COMPLETE", checkedItems, totalItems];
    self.footerTextField.text = footerString;
}

#pragma mark - NextChecklist
- (IBAction)nextChecklist:(id)sender {
    
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
