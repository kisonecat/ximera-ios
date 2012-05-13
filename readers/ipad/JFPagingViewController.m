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
    /*
     This operation takes care of wich sections are kept as the prev/curr/next one after you slide right/left
     This is executed after the pan animation has finished and it is intended to keep the section in the middle 
     as the current one. 
     NEW: now it preserves the last place when you go back to the last section you were looking at
            YAY! It only took me forever to figure this out. -D
          Also cleaned out the code layout, I dislike empty if statements and returning in a void procedure
     */
 //   CGFloat previousPageOrigin = 0;
    CGFloat currentPageOrigin = -self.previousSectionViewController.view.frame.size.width;
    
    // If we're in the middle, no need to reshuffle
    if (newCurrentSection != currentSection){
        //Record the offset of the current section.
        offsets[self.currentSection] = self.currentSectionViewController.scrollView.contentOffset.y/
                                       self.currentSectionViewController.view.frame.size.height;
        
        //Record the starting positions
        CGFloat prevStart, currStart, nextStart;
        prevStart = self.previousSectionViewController.scrollView.frame.origin.x;
        currStart = self.currentSectionViewController.scrollView.frame.origin.x;
        nextStart = self.nextSectionViewController.scrollView.frame.origin.x;
       
        //get section count for the correct refresh
        textbookAppDelegate *delegate = [UIApplication sharedApplication].delegate;
        int sectionCount = [delegate sectionCount];
        
        if (currentSection-newCurrentSection==1 || (currentSection==0 && newCurrentSection==sectionCount-1)) {
            //MOVED ONE SECTION DOWN!
            // Make the old previous page the new current page
            // set the current section
            self.currentSection = self.previousSectionViewController.currentSection;
            
            // Swap the controllers (shift to right)
            JFSectionViewController *controller;
            controller = self.previousSectionViewController;
            self.previousSectionViewController = self.nextSectionViewController;
            self.nextSectionViewController = self.currentSectionViewController;
            self.currentSectionViewController = controller;
            
            //Change the offset of the viewing rectangles (again, shift to left)
            self.nextSectionViewController.scrollView.frame = 
            CGRectOffset(self.nextSectionViewController.scrollView.frame, nextStart-currStart, 0);
            self.previousSectionViewController.scrollView.frame = 
            CGRectOffset(self.previousSectionViewController.scrollView.frame, prevStart-nextStart, 0);
            self.currentSectionViewController.scrollView.frame = 
            CGRectOffset(self.currentSectionViewController.scrollView.frame, currStart-prevStart, 0);
            
            //this has a new previous section, re image it
            int previousSection = (currentSection - 1 + sectionCount) % sectionCount;
            [previousSectionViewController setSection: previousSection];
            CGPoint offset = CGPointMake(self.previousSectionViewController.scrollView.contentOffset.x, 
                                         self.previousSectionViewController.view.frame.size.height*offsets[previousSection]);
            [previousSectionViewController.scrollView setContentOffset:offset animated:NO];
            
            //Set to offset of the current section too
            offset = CGPointMake(self.currentSectionViewController.scrollView.contentOffset.x, 
                                         self.currentSectionViewController.view.frame.size.height*offsets[currentSection]);
            [currentSectionViewController.scrollView setContentOffset:offset animated:YES];
            
            
            //reset the view frame
            self.view.frame = CGRectMake(currentPageOrigin, self.view.frame.origin.y,
                                         self.view.frame.size.width, self.view.frame.size.height );
            
        } else if (newCurrentSection-currentSection == 1 || (newCurrentSection==0 && currentSection==sectionCount-1)){
            //MOVED ONE SECTION UP!
            // Make the old next page the new current page
            // set the current section
            self.currentSection = self.nextSectionViewController.currentSection;
            
            // Swap the controllers (shift to left)
            JFSectionViewController* controller;
            controller = self.nextSectionViewController;
            self.nextSectionViewController = self.previousSectionViewController;
            self.previousSectionViewController = self.currentSectionViewController;
            self.currentSectionViewController = controller;
            
            //Change the offset of the viewing rectangles (again, shift to left)
            self.nextSectionViewController.scrollView.frame = 
            CGRectOffset(self.nextSectionViewController.scrollView.frame, nextStart-prevStart, 0);
            self.previousSectionViewController.scrollView.frame = 
            CGRectOffset(self.previousSectionViewController.scrollView.frame, prevStart-currStart, 0);
            self.currentSectionViewController.scrollView.frame = 
            CGRectOffset(self.currentSectionViewController.scrollView.frame, currStart-nextStart, 0);
            
            //this new view has a new next section, re image it
            int nextSection = (currentSection + 1) % sectionCount;
            [nextSectionViewController setSection: nextSection];
            CGPoint offset = CGPointMake(self.nextSectionViewController.scrollView.contentOffset.x, 
                                         self.nextSectionViewController.view.frame.size.height*offsets[nextSection]);
            [nextSectionViewController.scrollView setContentOffset:offset animated:NO];
            
            //Set to offset of the current section too
            offset = CGPointMake(self.currentSectionViewController.scrollView.contentOffset.x, 
                                 self.currentSectionViewController.view.frame.size.height*offsets[currentSection]);
            [currentSectionViewController.scrollView setContentOffset:offset animated:YES];
            
            
            //reset the view frame
            self.view.frame = CGRectMake(currentPageOrigin, self.view.frame.origin.y,
                                         self.view.frame.size.width, self.view.frame.size.height );
        } else {
            /*
            //swap the controler for prev and current
            JFSectionViewController *controller;
            controller = self.previousSectionViewController;
            self.previousSectionViewController = self.currentSectionViewController;
            self.currentSectionViewController = controller;
            
            //change the offset of the viewing rectangles
            //we do not need to move y origins because they are re-generated
            self.previousSectionViewController.scrollView.frame = 
            CGRectOffset(self.previousSectionViewController.scrollView.frame, prevStart-currStart, 0);
            self.currentSectionViewController.scrollView.frame = 
            CGRectOffset(self.currentSectionViewController.scrollView.frame, currStart-prevStart, 0);
            */
            //MADE A MESS
            currentSection = newCurrentSection;
            //set the previous section
            int previousSection = (currentSection - 1 + sectionCount) % sectionCount;
            [previousSectionViewController setSection: previousSection];
            CGPoint offset = CGPointMake(self.previousSectionViewController.scrollView.contentOffset.x, 
                                         self.previousSectionViewController.view.frame.size.height*offsets[previousSection]);
            [previousSectionViewController.scrollView setContentOffset:offset animated:NO];
            
            //set the next section
            int nextSection = (currentSection + 1) % sectionCount;
            [nextSectionViewController setSection: nextSection];
            offset = CGPointMake(self.nextSectionViewController.scrollView.contentOffset.x, 
                                         self.nextSectionViewController.view.frame.size.height*offsets[nextSection]);
            [nextSectionViewController.scrollView setContentOffset:offset animated:NO];
            
            //set the current section
            [currentSectionViewController setSection: currentSection];
            offset = CGPointMake(self.currentSectionViewController.scrollView.contentOffset.x, 
                                 self.currentSectionViewController.view.frame.size.height*offsets[currentSection]);
            [currentSectionViewController.scrollView setContentOffset:offset animated:YES];
            
            
            //reset the view frame
            self.view.frame = CGRectMake(currentPageOrigin, self.view.frame.origin.y,
                                         self.view.frame.size.width, self.view.frame.size.height );
            /*/
            //swap the controler for prev and current
            JFSectionViewController *controller;
            controller = self.previousSectionViewController;
            self.previousSectionViewController = self.currentSectionViewController;
            self.currentSectionViewController = controller;
            
            //change the offset of the viewing rectangles
            //we do not need to move y origins because they are re-generated
            self.previousSectionViewController.scrollView.frame = 
            CGRectOffset(self.previousSectionViewController.scrollView.frame, prevStart-currStart, 0);
            self.currentSectionViewController.scrollView.frame = 
            CGRectOffset(self.currentSectionViewController.scrollView.frame, currStart-prevStart, 0);
            
            
            //this has a new previous section, re image it
            int previousSection = (currentSection - 1 + sectionCount) % sectionCount;
            [previousSectionViewController setSection: previousSection];
            
            //this new view has a new next section, re image it
            int nextSection = (currentSection + 1) % sectionCount;
            [nextSectionViewController setSection: nextSection];
            
            //reset the view frame
            self.view.frame = CGRectMake(currentPageOrigin, self.view.frame.origin.y,
                                         self.view.frame.size.width, self.view.frame.size.height );
            /**/
             
        }
        //now we just need to refresh everything!
        /*
        CGPoint offset = CGPointMake(self.currentSectionViewController.scrollView.contentOffset.x, 
                                     self.currentSectionViewController.view.frame.size.height*offsets[currentSection]);
        [currentSectionViewController.scrollView setContentOffset:offset animated:YES];*/
        [self.view setNeedsDisplay];
    }
}

-(void)move:(id)sender
{
	CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:self.view.superview];
    
    static CGRect originalFrame;
    
	if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
        //we just began panning, this is an ugly way to store the current state when the panning began
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
        if (newOrigin.x < (previousPageOrigin + currentPageOrigin)/2){
            //we are in the next? section
            newOrigin.x = previousPageOrigin;
            newCurrentSection = self.nextSectionViewController.currentSection;
        }
        else if (newOrigin.x >= (nextPageOrigin + currentPageOrigin)/2){
            //we are in the previous? section
            newOrigin.x = nextPageOrigin;
            newCurrentSection = self.previousSectionViewController.currentSection;
        }
        else{ 
            // we are in the current section
            newOrigin.x = currentPageOrigin;
            newCurrentSection = self.currentSection;
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
    
    [delegate registerPaigingViewController: self];
    
    //YOU NEED TO CREATE OFFSET ARRAY HERE!
    //TODO: WE WILL START WITH ALL AT ZERO, but this should be persistent...
    offsets = malloc((sectionCount)*sizeof(float));
    for (int i=0; i<sectionCount; i++){
        offsets[i] = 0.f;
    }
}

- (void)pageDown:(id)sender
{
    int sect = self.nextSectionViewController.currentSection;
    [self setSection:sect withOffset:0.0];
}

- (void)pageUp:(id)sender
{
    int sect = self.previousSectionViewController.currentSection;
    [self setSection:sect withOffset:0.0];
}

- (IBAction)home:(id)sender {
    if (self.currentSection != 0){
        [self setSection:0 withOffset:0.0];
    }//else, there is no where to go to
}

-(BOOL) isToTheRight: (int)newCurrent of:(int)current withTotal:(int)total{
    return (current<newCurrent && !(current==0 && newCurrent==total-1))
            || (current==total-1 && newCurrent==0);
}

-(BOOL) isToTheLeftt: (int)newCurrent of:(int)current withTotal:(int)total{
    return (current>newCurrent && !(current==total-1 && newCurrent==0))
            || (current==0 && newCurrent==total-1);
}


- (void) setSection: (int)newSection withOffset:(float)offset{
    
    //get section count for the correct refresh
    textbookAppDelegate *delegate = [UIApplication sharedApplication].delegate;
    int sectionCount = [delegate sectionCount];
    if ([self isToTheRight:newSection of:self.currentSection withTotal:sectionCount]){
        //move forward
        //the new current section wil be the given section
        newCurrentSection = newSection;
        //the next pan becomes home
        [nextSectionViewController setSection: newSection];
        float totalHeight = nextSectionViewController.view.frame.size.height;
        float windowHeight = nextSectionViewController.scrollView.frame.size.height;
        
        float screenOffset = (totalHeight)*offset;
        if (screenOffset > totalHeight-windowHeight){
            screenOffset = (totalHeight-windowHeight);
        } 
        offsets[newSection]=screenOffset/totalHeight;
        //the rest of this looks a lot like a page down
        CGFloat nextPageOrigin = -(self.previousSectionViewController.view.frame.size.width + self.currentSectionViewController.view.frame.size.width);
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:.25];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [self.view setFrame: CGRectMake( nextPageOrigin, self.view.frame.origin.y,
                                        self.view.frame.size.width, self.view.frame.size.height )];
        [UIView setAnimationDelegate: self];
        [UIView setAnimationDidStopSelector: @selector(animationDidStop:finished:context:)];
        
        [UIView commitAnimations];
    } else if ([self isToTheLeftt:newSection of:self.currentSection withTotal:sectionCount]){
        //move back
        //the new current section wil be section newSection
        newCurrentSection = newSection;
        //the previous pan becomes home
        [previousSectionViewController setSection: newSection ];//withOffset:offset];        

        float totalHeight = previousSectionViewController.view.frame.size.height;
        float windowHeight = previousSectionViewController.scrollView.frame.size.height;

        float screenOffset = (totalHeight)*offset;
        if (screenOffset > totalHeight-windowHeight){
            screenOffset = (totalHeight-windowHeight);
        } 
        offsets[newSection]=screenOffset/totalHeight;
                
        //the rest of this looks a lot like page up!
        CGFloat previousPageOrigin = 0;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:.25];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [self.view setFrame: CGRectMake( previousPageOrigin, self.view.frame.origin.y,
                                        self.view.frame.size.width, self.view.frame.size.height )];
        [UIView setAnimationDelegate: self];
        [UIView setAnimationDidStopSelector: @selector(animationDidStop:finished:context:)];
        [UIView commitAnimations];
    } else{
        //We are in the same section, but we need to scroll to the pinched site
        float totalHeight = currentSectionViewController.view.frame.size.height;
        float windowHeight = currentSectionViewController.scrollView.frame.size.height;
        
        float screenOffset = (totalHeight)*offset;
        if (screenOffset > totalHeight-windowHeight){
            screenOffset = (totalHeight-windowHeight);
        } 
        offsets[newSection]=screenOffset/totalHeight;
        CGPoint pointOffset = CGPointMake(self.currentSectionViewController.scrollView.contentOffset.x, 
                             self.currentSectionViewController.view.frame.size.height*offsets[currentSection]);
        [currentSectionViewController.scrollView setContentOffset:pointOffset animated:YES];
        [self.view setNeedsDisplay];
    }
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
