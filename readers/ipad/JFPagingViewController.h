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
    
     IBOutlet UIProgressView *myProgressView;
    
    int currentSection;
    int newCurrentSection;
    UIAlertView *alert;
    UITextField* textfield;
    UIAlertView *alertView1;

    NSMutableArray *weblinks;
    NSMutableArray *weblinks1;
    
    
    UIAlertView *webMenuAlertView;
    //int totalButton;
    
    float* offsets;
}

@property (nonatomic, retain) IBOutlet JFSectionViewController *currentSectionViewController; 
@property (nonatomic, retain) IBOutlet JFSectionViewController *previousSectionViewController; 
@property (nonatomic, retain) IBOutlet JFSectionViewController *nextSectionViewController; 
@property int currentSection; 



- (IBAction)pageDown:(id)sender;
- (IBAction)pageUp:(id)sender;
- (IBAction)paste:(id)sender;
- (IBAction)home:(id)sender;
- (IBAction)clicksnap:(id)sender;


-(IBAction)linkMenu:(id)sender;
-(IBAction)popButton;




- (void) setSection: (int) newSection;
- (void) setSection: (int)newSection withOffset:(float)offset;
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

- (void) refresh;

@end
