//
//  JFPagingViewController.m
//  textbook
//
//  Created by Fowler, James on 1/30/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "JFPagingViewController.h"
#import "textbookAppDelegate.h"

@implementation JFPagingViewController

@synthesize previousSectionViewController, nextSectionViewController, currentSectionViewController;
@synthesize currentSection;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    // Shuffle around the three subviews

    CGFloat previousPageOrigin = 0;
    CGFloat currentPageOrigin = -self.previousSectionViewController.view.frame.size.width;
    CGFloat nextPageOrigin = -(self.previousSectionViewController.view.frame.size.width + self.currentSectionViewController.view.frame.size.width);

    // If we're in the middle, no need to reshuffle
    if (self.view.frame.origin.x == currentPageOrigin)
        return;
    
    // Make the old previous page the new current page
    if (self.view.frame.origin.x == previousPageOrigin) {
        // Swap the frames
        CGRect frame;
        frame = self.previousSectionViewController.scrollView.frame;
        self.previousSectionViewController.scrollView.frame = self.currentSectionViewController.scrollView.frame;
        self.currentSectionViewController.scrollView.frame = frame;
        self.view.frame = CGRectMake(currentPageOrigin, self.view.frame.origin.y,
                                     self.view.frame.size.width, self.view.frame.size.height );

        self.currentSection = self.previousSectionViewController.currentSection;

        // Swap the controllers
        JFSectionViewController* controller;
        controller = self.previousSectionViewController;
        self.previousSectionViewController = self.currentSectionViewController;
        self.currentSectionViewController = controller;
    }

    // Make the old previous page the new current page
    if (self.view.frame.origin.x == nextPageOrigin) {
        // Swap the frames
        CGRect frame;
        frame = self.nextSectionViewController.scrollView.frame;
        self.nextSectionViewController.scrollView.frame = self.currentSectionViewController.scrollView.frame;
        self.currentSectionViewController.scrollView.frame = frame;
        self.view.frame = CGRectMake(currentPageOrigin, self.view.frame.origin.y,
                                     self.view.frame.size.width, self.view.frame.size.height );
        
        self.currentSection = self.nextSectionViewController.currentSection;

        // Swap the controllers
        JFSectionViewController* controller;
        controller = self.nextSectionViewController;
        self.nextSectionViewController = self.currentSectionViewController;
        self.currentSectionViewController = controller;
    }

    // Now we need to tell the section view controllers to update themselves!
    textbookAppDelegate *delegate = [UIApplication sharedApplication].delegate;
    int sectionCount = [delegate sectionCount];
    
    int previousSection = (currentSection - 1 + sectionCount) % sectionCount;
    int nextSection = (currentSection + 1) % sectionCount;
    
    [previousSectionViewController setSection: previousSection];
    [nextSectionViewController setSection: nextSection];
    [self.view setNeedsDisplay];
    
    return;
}

-(void)move:(id)sender
{
	CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:self.view.superview];
    
    static CGRect originalFrame;
    
	if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
        originalFrame = [self.view frame];
        return;
	}
    
    CGFloat nextPageOrigin = 0;
    CGFloat currentPageOrigin = -self.previousSectionViewController.view.frame.size.width;
    CGFloat previousPageOrigin = -(self.previousSectionViewController.view.frame.size.width + self.currentSectionViewController.view.frame.size.width);
    
    CGPoint newOrigin = CGPointMake( originalFrame.origin.x + translatedPoint.x,
                                    originalFrame.origin.y // Only panning in the right/left direction
                                    );
    
    if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateChanged) {
        if (newOrigin.x > nextPageOrigin)
            newOrigin.x = nextPageOrigin;
        
        if (newOrigin.x < previousPageOrigin)
            newOrigin.x = previousPageOrigin;
        
        self.view.frame = CGRectMake( newOrigin.x, newOrigin.y,
                                            originalFrame.size.width, originalFrame.size.height );
        
        return;
	}
    
	if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
        // Snap to the left
        if (newOrigin.x < (previousPageOrigin + currentPageOrigin)/2)
            newOrigin.x = previousPageOrigin;
        else {
            // Snap to the right
            if (newOrigin.x >= (nextPageOrigin + currentPageOrigin)/2)
                newOrigin.x = nextPageOrigin;
            else // snap to the middle
                newOrigin.x = currentPageOrigin;
        }
        
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:.25];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		[[sender view] setFrame: CGRectMake( newOrigin.x, newOrigin.y,
                                            originalFrame.size.width, originalFrame.size.height )];
        [UIView setAnimationDelegate: self];
        [UIView setAnimationDidStopSelector: @selector(animationDidStop:finished:context:)];
        
		[UIView commitAnimations];
	}
}

- (void)setupSectionViews
{
    textbookAppDelegate *delegate = [UIApplication sharedApplication].delegate;
    int sectionCount = [delegate sectionCount];
 
    int previousSection = (currentSection - 1 + sectionCount) % sectionCount;
    int nextSection = (currentSection + 1) % sectionCount;
    
    [previousSectionViewController setSection: previousSection];
    [currentSectionViewController setSection: currentSection];
    [nextSectionViewController setSection: nextSection];
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];

    // Panning gesture
    UIPanGestureRecognizer *pan = [[[UIPanGestureRecognizer alloc] init] autorelease];
    [pan addTarget:self action:@selector(move:)];
    [self.view addGestureRecognizer: pan];
    
    self.currentSection = 0;
    [self setupSectionViews];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return NO;
}

@end
