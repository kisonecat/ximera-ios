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
@synthesize thirdButton;
@synthesize firstWebButton;
@synthesize secondButton ,totalButton;

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
    [firstWebButton release];
    [secondButton release];
    [thirdButton release];
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
        //Record the starting positions
        CGFloat prevStart, currStart, nextStart;
        prevStart = self.previousSectionViewController.scrollView.frame.origin.x;
        currStart = self.currentSectionViewController.scrollView.frame.origin.x;
        nextStart = self.nextSectionViewController.scrollView.frame.origin.x;
       
        //get section count for the correct refresh
        textbookAppDelegate *delegate = [UIApplication sharedApplication].delegate;
        int sectionCount = [delegate sectionCount];
        
        if (currentSection-newCurrentSection==1 || (currentSection==0 && newCurrentSection==sectionCount-1)) {
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
            
            //reset the view frame
            self.view.frame = CGRectMake(currentPageOrigin, self.view.frame.origin.y,
                                         self.view.frame.size.width, self.view.frame.size.height );
        } else if (newCurrentSection-currentSection == 1 || (newCurrentSection==0 && currentSection==sectionCount-1)){
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
            
            //reset the view frame
            self.view.frame = CGRectMake(currentPageOrigin, self.view.frame.origin.y,
                                         self.view.frame.size.width, self.view.frame.size.height );
        } else {
            //previous has chapter one, the other two we need to redo!
            
            //set the current section
            self.currentSection = self.previousSectionViewController.currentSection;
            
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
        }
        //now we just need to refresh everything!
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
}

- (void)pageDown:(id)sender
{
    newCurrentSection = self.nextSectionViewController.currentSection;
    CGFloat nextPageOrigin = -(self.previousSectionViewController.view.frame.size.width + self.currentSectionViewController.view.frame.size.width);

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.25];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [self.view setFrame: CGRectMake( nextPageOrigin, self.view.frame.origin.y,
                                        self.view.frame.size.width, self.view.frame.size.height )];
    [UIView setAnimationDelegate: self];
    [UIView setAnimationDidStopSelector: @selector(animationDidStop:finished:context:)];
    
    [UIView commitAnimations];
}

- (void)pageUp:(id)sender
{
    newCurrentSection = self.previousSectionViewController.currentSection;
    CGFloat previousPageOrigin = 0;
    
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.25];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [self.view setFrame: CGRectMake( previousPageOrigin, self.view.frame.origin.y,
                                    self.view.frame.size.width, self.view.frame.size.height )];
    [UIView setAnimationDelegate: self];
    [UIView setAnimationDidStopSelector: @selector(animationDidStop:finished:context:)];
    
    [UIView commitAnimations];
}

- (IBAction)home:(id)sender {
    if (self.currentSection != 0){
        //the new current section wil be section 0
        newCurrentSection = 0;
        //the previous pan becomes home
        [previousSectionViewController setSection: 0];        
        
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
    }//else, there is no where to go to
}


- (void) setSection: (int) newSection{
    if (self.currentSection < newSection){
        //move forward
        //the new current section wil be the given section
        newCurrentSection = newSection;
        //the next pan becomes home
        [nextSectionViewController setSection: newSection];  
        
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
    } else if (self.currentSection > newSection){
        //move back
        //the new current section wil be section newSection
        newCurrentSection = newSection;
        //the previous pan becomes home
        [previousSectionViewController setSection: newSection];        
        
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
    }//else we stay put
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

//implementing the plus button on the book spine



-(IBAction)popButton{
    
    UIAlertView *firstAlertView = [[UIAlertView alloc] initWithTitle:@"Menu" message:@"Select the one" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add Web Link( Atmost 3)", @"Add Index" ,nil];
    [firstAlertView setTag: 0];

    [firstAlertView show];
    
}  

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

    switch (alertView.tag)
    {
        case 0: /* firstAlert */
        {

    
    //  if (buttonIndex ==0){
    
    //  UIAlertView *alertView1 = [[UIAlertView alloc] initWithTitle:@"website" message:@"This is the message" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
    
    //  alertView1.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    
    // [alertView1 addTextFieldWithValue:@""label:@"Enter the web address"];
    
    
    //  } 
    
    
    if (buttonIndex ==1){
        
        alertView1 = [[UIAlertView alloc] initWithTitle:@"Add Web Link" message:@"Enter web address in the format of http://www.abc.com" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Enter", nil];
        alertView1.alertViewStyle = UIAlertViewStylePlainTextInput;
     
         [alertView1 setTag: 1];
         [alertView1 show];
      
       }   
    
    
    if (buttonIndex ==2){
        
       //  [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"http://www.google.com"]];
        
     /*   UIAlertView *alertView1 = [[UIAlertView alloc] initWithTitle:@"Add Video" message:@"This is the message" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        alertView1.alertViewStyle = UIAlertViewStylePlainTextInput;
        
        [alertView1 show]; */
    }
}
            break;
            
        case 1: {
                       
            if (buttonIndex ==1){
                // NSLog (@"%d", totalButton);
                
                textfield = [[UITextField alloc] init];
                textfield = [alertView1 textFieldAtIndex:0]; 
               
                    
                 @try { 
                    // NSLog (@"%d", totalButton);
                     if(totalButton ==0) {
                        [firstWebButton setBackgroundColor:[UIColor clearColor]];
                        NSArray* myArray = [[NSArray alloc] init];
                        myArray = [textfield.text  componentsSeparatedByString:@"."];
                        NSString* secondString = [myArray objectAtIndex:1];
                        [firstWebButton setTitle: secondString forState:UIControlStateNormal];
                         [firstWebButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal]; 
                         [self setTotalButton:1];
                        // NSLog (@"%d", totalButton);

                            
                     }else if (totalButton ==1) {
                        // NSLog (@"%d", totalButton);
                         [secondButton setBackgroundColor:[UIColor clearColor]];
                         NSArray* myArray = [[NSArray alloc] init];
                         myArray = [textfield.text  componentsSeparatedByString:@"."];
                         NSString* secondString = [myArray objectAtIndex:1];
                         [secondButton setTitle: secondString forState:UIControlStateNormal];
                         [secondButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal]; 
                         [self setTotalButton:2];

                     }else if (totalButton ==2) {
                         NSLog (@"%d", totalButton);
                         [thirdButton setBackgroundColor:[UIColor clearColor]];
                         NSArray* myArray = [[NSArray alloc] init];
                         myArray = [textfield.text  componentsSeparatedByString:@"."];
                         NSString* secondString = [myArray objectAtIndex:1];
                         [thirdButton setTitle: secondString forState:UIControlStateNormal];
                         [thirdButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal]; 
                         [self setTotalButton:3];
                         
                     } else if (totalButton ==3) {
                         UIAlertView *message = [[UIAlertView alloc] initWithTitle:@" Message " message:@"You can not have more than 3 links at one session" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                         [message show]; 

                     }

                     
                    
                    }
                    @catch (NSException *e) {
                       
                        UIAlertView *errorMessage = [[UIAlertView alloc] initWithTitle:@"Error Message " message:@"Enter the correct web Address first" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
                        [errorMessage show]; }
                    }
                }
            
            break;
        }

}            

-(IBAction)link:(id)sender {

        [[UIApplication sharedApplication]openURL:[NSURL URLWithString: textfield.text]];
    
    
    
}







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
    [self setTotalButton:0];
    
    
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
