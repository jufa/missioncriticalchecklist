//
//  addChecklistViewController.m
//  MissionCriticalChecklist
//
//  Created by Jeremy Kuzub on 2014-08-03.
//  Copyright (c) 2014 jufaintermedia. All rights reserved.
//

#import "AddChecklistViewController.h"
#import "UITextFieldOrdered.h"

@interface AddChecklistViewController ()

@end

@implementation AddChecklistViewController

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
    
    
}

- (void) viewDidAppear:(BOOL)animated {
    _typeField.returnKeyType = UIReturnKeyNext;
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
@end
