//
//  addChecklistViewController.m
//  MissionCriticalChecklist
//
//  Created by Jeremy Kuzub on 2014-08-03.
//  Copyright (c) 2014 jufaintermedia. All rights reserved.
//

#import "AddChecklistViewController.h"
#import "UITextFieldOrdered.h"
#import "UICollectionViewCellWithImage.h"

@interface AddChecklistViewController ()

@end

@implementation AddChecklistViewController {
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
    _typeField.text = [self.currentChecklist type];
    _nameField.text = [self.currentChecklist name];
    if ([self.mode isEqual: @"edit"]) {
        self.navTitle.title = @"Edit Checklist";
        _typeField.clearsOnBeginEditing = NO;
        _nameField.clearsOnBeginEditing = NO;
    } else if ([self.mode isEqual: @"add"]) {
        self.navTitle.title = @"Add Checklist";
        _typeField.clearsOnBeginEditing = YES;
        _nameField.clearsOnBeginEditing = YES;
    } else {
        self.navTitle.title = @"Add or Edit Checklist";
    }
    
    iconArray = ChecklistItemIcons.iconList;
    
    //allow selection (single) for the iconCVC:
    self.iconCollectionViewController.allowsSelection = YES;
    self.iconCollectionViewController.allowsMultipleSelection = NO;
}

- (void) viewDidAppear:(BOOL)animated {
    [_typeField becomeFirstResponder];
}

- (BOOL) textFieldShouldReturn:(UITextField *) textField {
    
    BOOL didResign = [textField resignFirstResponder];
    if (!didResign) return NO;
    
    if ([textField isKindOfClass:[UITextFieldOrdered class]])
        dispatch_async(dispatch_get_current_queue(),
                       ^ { [[(UITextFieldOrdered *)textField nextField] becomeFirstResponder]; });
    if(textField == _nameField) {
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
    [self.currentChecklist setType:_typeField.text];
    [self.currentChecklist setName:_nameField.text];
    [self.delegate addChecklistViewControllerDidSave:[self currentChecklist]];
}

- (IBAction)cancel:(id)sender {
    [self.delegate addChecklistViewControllerDidCancel:[self currentChecklist]];
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
    self.currentChecklist.icon = iconName;
    
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
