//
//  addChecklistItemViewController.m
//  MissionCriticalChecklist
//
//  Created by Jeremy Kuzub on 2014-08-03.
//  Copyright (c) 2014 jufaintermedia. All rights reserved.
//

#import "AddChecklistItemViewController.h"

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

- (IBAction)cancel:(id)sender {
    [self.delegate addChecklistItemViewControllerDidCancel:[self currentChecklistItem]];
}

- (IBAction)save:(id)sender {
    [self.currentChecklistItem setAction:_actionField.text];
    [self.currentChecklistItem setDetail:_detailField.text];
    [self.delegate addChecklistItemViewControllerDidSave:[self currentChecklistItem]];
    
}
@end
