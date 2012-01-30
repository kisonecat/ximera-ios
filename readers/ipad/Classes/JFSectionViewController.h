//
//  JFSectionViewController.h
//  textbook
//
//  Created by Fowler, James on 1/27/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface JFSectionViewController : UIViewController  <UIScrollViewDelegate> {
    UIView*			content;
    UIScrollView * scrollView;
}

@property (nonatomic, retain) IBOutlet UIScrollView * scrollView;
@property (nonatomic, retain) IBOutlet UIView* content;

@end
