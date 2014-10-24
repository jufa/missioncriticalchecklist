//
//  addChecklistItemViewController.m
//  MissionCriticalChecklist
//
//  Created by Jeremy Kuzub on 2014-08-03.
//  Copyright (c) 2014 jufaintermedia. All rights reserved.
//

#import "AddChecklistItemViewController.h"
#import "UITextFieldOrdered.h"
#import "UICollectionViewCellWithImage.h"

@interface AddChecklistItemViewController ()

@end

@implementation AddChecklistItemViewController {
    NSMutableArray *iconArray; //will hold string reference names of icon images
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _actionField.text = [self.currentChecklistItem action];
    _detailField.text = [self.currentChecklistItem detail];
    if ([self.mode isEqual: @"edit"]) {
        self.titleLabel.text = @"Edit Checklist Item";
        _actionField.clearsOnBeginEditing = NO;
        _detailField.clearsOnBeginEditing = NO;
    } else if ([self.mode isEqual: @"add"]) {
        self.titleLabel.text = @"Add Checklist Item";
        _actionField.clearsOnBeginEditing = YES;
        _detailField.clearsOnBeginEditing = YES;
    } else {
        self.titleLabel.text = @"Add or Edit Checklist Item";
    }
    
    iconArray = ChecklistItemIcons.iconList;
    
    //allow selection (single) for the iconCVC:
    self.iconCollectionViewController.allowsSelection = YES;
    self.iconCollectionViewController.allowsMultipleSelection = NO;
}

- (void) viewDidAppear:(BOOL)animated {
    [_actionField becomeFirstResponder];
}

- (BOOL) textFieldShouldReturn:(UITextField *) textField {
    
    BOOL didResign = [textField resignFirstResponder];
    if (!didResign) return NO;
    
    if ([textField isKindOfClass:[UITextFieldOrdered class]])
        dispatch_async(dispatch_get_current_queue(),
                       ^ { [[(UITextFieldOrdered *)textField nextField] becomeFirstResponder]; });
    if(textField == _detailField) {
        [self saveAndClose];
        
    }
    
    return YES;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void) saveAndClose {
    [self.currentChecklistItem setAction:_actionField.text];
    [self.currentChecklistItem setDetail:_detailField.text];
    [self.delegate addChecklistItemViewControllerDidSave:[self currentChecklistItem]];
}


- (IBAction)cancel:(id)sender {
    [self.delegate addChecklistItemViewControllerDidCancel:[self currentChecklistItem]];
}

- (IBAction)save:(id)sender {
    [self saveAndClose];
}

#pragma mark Collection View Methods
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [iconArray count];
}
-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCellWithImage* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    NSString *imageToLoad = [NSString stringWithFormat:@"%@.png", [iconArray objectAtIndex: indexPath.row]];
    cell.imageView.image = [UIImage imageNamed:imageToLoad];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog([NSString stringWithFormat:@"item selected is %d", indexPath.row]);
    
    //get the string name of the icon at that indexPath rox
    NSString *iconName = [iconArray objectAtIndex: indexPath.row];
    
    //set the current checklist items icon name to this:
    self.currentChecklistItem.icon = iconName;
    
    UICollectionViewCell* cell = (UICollectionViewCell*) [collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor lightGrayColor];
    
}

-(void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog([NSString stringWithFormat:@"item unselected is %d", indexPath.row]);
    
    
    NSArray *prevSelections = [collectionView indexPathsForSelectedItems];
    
    UICollectionViewCell* cellToClear;
    for(NSIndexPath* i in prevSelections){
        cellToClear = (UICollectionViewCell*) [collectionView cellForItemAtIndexPath:i];
        cellToClear.backgroundColor = [UIColor clearColor];
    }
    
    UICollectionViewCell* cell = (UICollectionViewCell*) [collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}







@end
