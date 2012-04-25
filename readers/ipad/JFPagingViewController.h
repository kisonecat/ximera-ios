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
}

@property (nonatomic, retain) IBOutlet JFSectionViewController *currentSectionViewController; 
@property (nonatomic, retain) IBOutlet JFSectionViewController *previousSectionViewController; 
@property (nonatomic, retain) IBOutlet JFSectionViewController *nextSectionViewController; 
@property int currentSection; 

- (IBAction)pageDown:(id)sender;
- (IBAction)pageUp:(id)sender;
- (IBAction)paste:(id)sender;

@end
