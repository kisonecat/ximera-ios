//
//  JFPagingViewController.h
//  textbook
//
//  Created by Fowler, James on 1/30/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JFSectionViewController.h"

@interface JFPagingViewController : UIViewController {
    IBOutlet JFSectionViewController *currentSectionViewController;
    IBOutlet JFSectionViewController *previousSectionViewController;
    IBOutlet JFSectionViewController *nextSectionViewController;
    
    int currentSection;
    int newCurrentSection;
    UIAlertView *alert;
    UITextField* textfield;
    UIAlertView *alertView1;
    UIButton *firstWebButton;
    NSInteger totalButton;
    //int totalButton;
    
    float* offsets;
}

@property (nonatomic, retain) IBOutlet JFSectionViewController *currentSectionViewController; 
@property (nonatomic, retain) IBOutlet JFSectionViewController *previousSectionViewController; 
@property (nonatomic, retain) IBOutlet JFSectionViewController *nextSectionViewController; 
@property int currentSection; 

//@property (nonatomic, retain) IBOutlet UIButton *firstWebButton;


@property (retain, nonatomic) IBOutlet UIButton *firstWebButton;
@property (retain, nonatomic) IBOutlet UIButton *secondButton;

@property (retain, nonatomic) IBOutlet UIButton *thirdButton;
@property (assign) NSInteger totalButton;


- (IBAction)pageDown:(id)sender;
- (IBAction)pageUp:(id)sender;
- (IBAction)paste:(id)sender;
- (IBAction)home:(id)sender;

-(IBAction)popButton;
//-(IBAction)link;

- (IBAction)link:(id)sender;

- (void) setSection: (int) newSection;
- (void) setSection: (int)newSection withOffset:(float)offset;
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end
