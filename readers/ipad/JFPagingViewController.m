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
    free (offsets);
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
             
        }
        //now we just need to refresh everything!
        [self.view setNeedsDisplay];
    }
}

-(void)move:(id)sender
{
    
    textbookAppDelegate *delegate = [UIApplication sharedApplication].delegate;
    int sectionCount = [delegate sectionCount];
    
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
            
            
            int sect1 = self.nextSectionViewController.currentSection;
            int cursect1 = sect1+1;
            
            float p1 = (float)cursect1/(float)sectionCount;
            myProgressView.progress = p1;
        }
        else if (newOrigin.x >= (nextPageOrigin + currentPageOrigin)/2){
            //we are in the previous? section
            newOrigin.x = nextPageOrigin;
            newCurrentSection = self.previousSectionViewController.currentSection;
            
            int sect2 = self.previousSectionViewController.currentSection;
            int cursect2 = sect2+1;
            
            float p2 = (float)cursect2/(float)sectionCount;
            myProgressView.progress = p2;
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
        
        weblinks = [[NSMutableArray alloc] init];
        weblinks1 = [[NSMutableArray alloc] init];

    }
}

- (void)pageDown:(id)sender
{
    
    textbookAppDelegate *delegate = [UIApplication sharedApplication].delegate;
    int sectionCount = [delegate sectionCount];

    int sect = self.nextSectionViewController.currentSection;
    
    int cursect = sect + 1;
    float p = (float)cursect/(float)sectionCount;
    myProgressView.progress = p;
    
    
    [self setSection:sect];
    
    }

- (void)pageUp:(id)sender
{
    
    textbookAppDelegate *delegate = [UIApplication sharedApplication].delegate;
    int sectionCount = [delegate sectionCount];
    
    int sect = self.previousSectionViewController.currentSection;
    
    int cursect = sect + 1;
    
    float p = (float)cursect/(float)sectionCount;
    myProgressView.progress = p;
    [self setSection:sect];
}

- (IBAction)home:(id)sender {
    if (self.currentSection != 0){
        [self setSection:0];
        
        textbookAppDelegate *delegate = [UIApplication sharedApplication].delegate;
        int sectionCount = [delegate sectionCount];
        
         float p = (float)sectionCount;
        
         myProgressView.progress = 1.0/p;
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


- (void) setSection: (int)newSection{
    
    //get section count for the correct refresh
    textbookAppDelegate *delegate = [UIApplication sharedApplication].delegate;
    int sectionCount = [delegate sectionCount];
    if ([self isToTheRight:newSection of:self.currentSection withTotal:sectionCount]){
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
    } else if ([self isToTheLeftt:newSection of:self.currentSection withTotal:sectionCount]){
        //move back
        //the new current section wil be section newSection
        newCurrentSection = newSection;
        //the previous pan becomes home
        [previousSectionViewController setSection: newSection ];//withOffset:offset];        
        
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
    } 
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
        
        float screenOffset = (totalHeight)*offset-(0.3333)*windowHeight;
        if (screenOffset > totalHeight-windowHeight){
            screenOffset = (totalHeight-windowHeight);
        } else if (screenOffset < 0) {
            screenOffset = 0;
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
        
        float screenOffset = (totalHeight)*offset-(0.3333)*windowHeight;
        if (screenOffset > totalHeight-windowHeight){
            screenOffset = (totalHeight-windowHeight);
        } else if (screenOffset < 0) {
            screenOffset = 0;
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
        
        float screenOffset = (totalHeight)*offset-(0.3333)*windowHeight;
        if (screenOffset > totalHeight-windowHeight){
            screenOffset = (totalHeight-windowHeight);
        } else if (screenOffset < 0) {
            screenOffset = 0;
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

//implementing the plus button on the book spine



-(IBAction)popButton{
    
    
    UIAlertView *firstAlertView = [[UIAlertView alloc] initWithTitle:@"Menu" message:@"Select the one" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add Web Links", @"Add notes" ,nil];
    [firstAlertView setTag: 0];
    
    [firstAlertView show];
    
}  

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (alertView.tag)
    {
        case 0: /* firstAlert, shown when hitting + */
        {
            
            
            if (buttonIndex ==1){
                
                alertView1 = [[UIAlertView alloc] initWithTitle:@"Add Web Link" message:@"Enter web address in the format of http://www.abc.com" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Enter", nil];
                alertView1.alertViewStyle = UIAlertViewStylePlainTextInput;
                
                [alertView1 setTag: 1];
                [alertView1 show];
                
            }   
                    
            if (buttonIndex ==2){
                
                //add notes
            }

        }
            break;
            
        case 1: /* Adding a link? */ {
            
            if (buttonIndex ==1){
                textfield = [[UITextField alloc] init];
                textfield = [alertView1 textFieldAtIndex:0]; 
                
                @try { 
                    NSArray* myArray = [[NSArray alloc] init];
                    myArray = [textfield.text  componentsSeparatedByString:@"."];
                    
                    NSString* firstString = [myArray objectAtIndex:0];
                    NSString* secondString = [myArray objectAtIndex:1];
                    
                    if(([myArray count]>=3)&&(([firstString isEqualToString:@"http://www"])||([firstString isEqualToString:@"www"]))) {
                        
                        if([firstString isEqualToString:@"www"]){
                            textfield.text =[@"http://" stringByAppendingFormat:textfield.text];
                        }
                            
                        [weblinks addObject:secondString];
                        [weblinks1 addObject:textfield.text]; 
                    }
                    else {
                        UIAlertView *errorMessage = [[UIAlertView alloc] initWithTitle:@"Error Message " message:@"Enter the correct web Address first" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
                        [errorMessage show]; 
                    }

                }
                @catch (NSException *e) {
                    
                    UIAlertView *errorMessage = [[UIAlertView alloc] initWithTitle:@"Error Message " message:@"Enter the correct web Address first" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
                    [errorMessage show]; }
            }
        }
            
            break;
            
        case 2: /* going to a web page */{
            //Array index starts at 0, but button index at 0 is cancel, so we start links at 1
            
            if (buttonIndex >0 && buttonIndex <= [weblinks count]){
                //we are within the array, just go to the linkk
                //if you don't trust me google that...
                [[UIApplication sharedApplication]openURL:[NSURL URLWithString:[weblinks1 objectAtIndex:buttonIndex-1]]];    
            } 
            else if (buttonIndex == 0){
                
            }
            else if ([weblinks count] == 0){

                //we are deleting a button, and there is no things that can be deleted 
                UIAlertView *message = [[UIAlertView alloc] initWithTitle:@" Message " message:@"There is no link to delete" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil]; 
                
                [message show];
                
            }
            else {
                
                UIAlertView *removeAlert = [[UIAlertView alloc] initWithTitle:@" Remove " message:@"Click on the link which you want to remove" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil]; 
                
                for (int j = 0; j < [weblinks count]; j++) {
                    // NSLog(@"The Array at %d index is %@",j,[weblinks objectAtIndex:j]);
                    [removeAlert addButtonWithTitle:[weblinks objectAtIndex:j]];
                    [removeAlert setTag:3];
                    [removeAlert show];
                }
            }  
        }
            break;
            
       case 3: /* remove a web link */{
           if(buttonIndex !=0){ 
            
            [weblinks1 removeObjectAtIndex:buttonIndex-1];
               [weblinks removeObjectAtIndex:buttonIndex-1];}

          }
            break;      
       }
   }  


- (IBAction)linkMenu:(id)sender {
    
    webMenuAlertView = [[UIAlertView alloc] initWithTitle:@"Go to the web site" message:@"click button" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
    [webMenuAlertView setTag: 2];
    
    int i;
    for (i = 0; i < [weblinks count]; i++) {
        [webMenuAlertView addButtonWithTitle:[weblinks objectAtIndex:i]];
    }
    [webMenuAlertView addButtonWithTitle:@"Delete Link"];
    [webMenuAlertView show];

    
    

}



- (IBAction)clicksnap:(id)sender
{
    /* UIGraphicsBeginImageContext(self.view.bounds.size);
     
     [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
     
     UIImage *screenshotImage = UIGraphicsGetImageFromCurrentImageContext();
     
     UIGraphicsEndImageContext();
     
     UIImageWriteToSavedPhotosAlbum(screenshotImage, nil, nil, nil); */
	
	CGRect screenRect = [[UIScreen mainScreen] bounds];
	UIGraphicsBeginImageContext(screenRect.size);
	
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	[[UIColor blackColor] set];
	CGContextFillRect(ctx, screenRect);
	
	[self.view.layer renderInContext:ctx];
	
	UIImage *screenImage = UIGraphicsGetImageFromCurrentImageContext();
	// set the coordinates in place of nil.......to get the selected screenshot//
	UIImageWriteToSavedPhotosAlbum(screenImage, nil, nil, nil);
	//fill cordinat in place of nil if u want only image comes and not button......ok this code is to get full screen screenshot//
	UIGraphicsEndImageContext();	
	
	UIAlertView *alerts = [[UIAlertView alloc]
						  initWithTitle: @""
						  message: @"Snapshot saved successfully to the Photo Gallery"
						  delegate: nil
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil];
	[alerts show];
	[alerts release];
	
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
    textbookAppDelegate *delegate = [UIApplication sharedApplication].delegate;
    int sectionCount = [delegate sectionCount];
    
    
    float p1 = 1.0/(float)sectionCount;
    myProgressView.progress = p1;
    
    
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

- (void) refresh 
{
    [currentSectionViewController setSection: currentSectionViewController.currentSection];
    [previousSectionViewController setSection: previousSectionViewController.currentSection];
    [nextSectionViewController setSection: nextSectionViewController.currentSection];
}

@end
