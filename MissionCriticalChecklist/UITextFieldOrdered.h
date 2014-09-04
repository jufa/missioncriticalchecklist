//
//  UITextFieldOrdered.h
//  MissionCriticalChecklist
//
//  Created by Jeremy Kuzub on 2014-09-03.
//  Copyright (c) 2014 jufaintermedia. All rights reserved.
//
// @brief An extension to allow forms with sequential Next Next Next.... Done behavior
// @see http://stackoverflow.com/questions/1347779
//

#import <UIKit/UIKit.h>

@interface UITextFieldOrdered : UITextField

@property (nonatomic, readwrite, assign) IBOutlet UITextField *nextField;

@end
