//
//  addChecklistItemViewController.m
//  MissionCriticalChecklist
//
//  Created by Jeremy Kuzub on 2014-08-03.
//  Copyright (c) 2014 jufaintermedia. All rights reserved.
//

#import "AddChecklistItemViewController.h"
#import "UITextFieldOrdered.h"

@interface AddChecklistItemViewController ()

@end

@implementation AddChecklistItemViewController

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
        self.navTitle.title = @"Edit Checklist Item";
        _actionField.clearsOnBeginEditing = NO;
        _detailField.clearsOnBeginEditing = NO;
    } else if ([self.mode isEqual: @"add"]) {
        self.navTitle.title = @"Add Checklist Item";
        _actionField.clearsOnBeginEditing = YES;
        _detailField.clearsOnBeginEditing = YES;
    } else {
        self.navTitle.title = @"Add or Edit Checklist Item";
    }
    
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
@end
