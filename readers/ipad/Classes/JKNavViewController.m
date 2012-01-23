/*
  JKNavWebViewController.m
  
  This file is part of ximera.

  ximera is free software: you can redistribute it and/or modify it
  under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  ximera is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with ximera.  If not, see <http://www.gnu.org/licenses/>.
*/

#import "JKNavViewController.h"
#import "JFContViewController.h"

@implementation JKNavViewController

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	appDelegate = (textbookAppDelegate *) [[UIApplication sharedApplication] delegate];

	[navView.superview bringSubviewToFront:navView];
	[navView.superview bringSubviewToFront:appDelegate.bookSpine];


	// Draw shadow of bookSpine
	appDelegate.bookSpine.layer.shadowOpacity = 1.0;
	appDelegate.bookSpine.layer.shadowRadius = 5.0;
	appDelegate.bookSpine.layer.shadowOffset = CGSizeMake(-4, 0);
	appDelegate.bookSpine.clipsToBounds = NO;
	//~

	// Swipe detection
	UISwipeGestureRecognizer * swipeLeft = [[[UISwipeGestureRecognizer alloc] init] autorelease];
	swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
	swipeLeft.numberOfTouchesRequired = 1;
	[swipeLeft addTarget:self action:@selector(handleSwipe:)];
	[bookSpine addGestureRecognizer: swipeLeft];
	
	UISwipeGestureRecognizer * swipeRight = [[[UISwipeGestureRecognizer alloc] init] autorelease];
	swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
	swipeRight.numberOfTouchesRequired = 1;
	[swipeRight addTarget:self action:@selector(handleSwipe:)];
	[bookSpine addGestureRecognizer: swipeRight];
}
 

- (void) handleSwipe:(UISwipeGestureRecognizer *)swipe
{
	[UIView animateWithDuration:0.2 animations:^{[self moveNav:swipe.direction == UISwipeGestureRecognizerDirectionLeft];} ];
}


- (void) moveNav:(BOOL) left
{
	// Resize contView
	CGRect contFrame = appDelegate.contView.frame;
	if (left)
		contFrame.size.width = 564;
	else
		contFrame.size.width = 768-41;
	appDelegate.contView.frame = contFrame;
	//~
	
	// Move navView
	CGRect navFrame = navView.frame;
	if (left)
		navFrame.origin.x = 605;
	else
		navFrame.origin.x = 768;
	navView.frame = navFrame;
	//~
	
	// Move Book Spine
	CGRect bookFrame = bookSpine.frame;
	if (left)
		bookFrame.origin.x = 564;
	else
		bookFrame.origin.x = 768-41;
	bookSpine.frame = bookFrame;
	//~	
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}





- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	printf("nav scrollViewDidScroll\n");
	if ([appDelegate.contentViewController getIsScrolling] == YES)
		return;
	
	[appDelegate.contentViewController setIsScrolling: YES];

	UIScrollView * contentScrollView = appDelegate.contView;
	CGPoint contentOffset = CGPointMake(0, [scrollView contentOffset].y * ([contentScrollView contentSize].height - [appDelegate.contView bounds].size.height) / ([scrollView contentSize].height - [navView bounds].size.height));
	[contentScrollView setContentOffset:contentOffset animated: NO];
	
	[appDelegate.contentViewController setIsScrolling: NO];
    
    [scrollView setContentOffset: CGPointMake(0, scrollView.contentOffset.y)]; // turn off left/right scrolling

}



- (void)userDidTapWebView:(UITouch *)touch
{
	static CGPoint oldPoint;
	
	if ([appDelegate.contentViewController getIsScrolling] == YES)
		return;
	
	CGPoint tapPoint = [touch locationInView:navView];
	if (tapPoint.x < -41 || tapPoint.y < 0)
		return;
	
	CGRect navFrame = navView.frame;
	
	if (touch.phase == UITouchPhaseBegan)
		oldPoint = tapPoint;
	else if (touch.phase == UITouchPhaseMoved)
	{
		CGRect bookFrame = bookSpine.frame;
		if (bookFrame.origin.x - tapPoint.x >= 564)
		{
			// Move NavView (NavView have to move its center because of the Affine transformation)
			navFrame.origin.x += tapPoint.x - oldPoint.x;
			if (navFrame.origin.x < 605)
				navFrame.origin.x = 605;
			else if (navFrame.origin.x > 768-41)
				navFrame.origin.x = 768-41;
		
			navView.frame = navFrame;
			//~
		
			// Move Book Spine
			bookFrame.origin.x += tapPoint.x - oldPoint.x;
			if (bookFrame.origin.x < 564)
				bookFrame.origin.x = 564;
			else if (bookFrame.origin.x > 768-41)
				bookFrame.origin.x = 768-41;
		
			bookSpine.frame = bookFrame;
			//~
			
			// Resize contView
			CGRect contFrame = appDelegate.contView.frame;
			contFrame.size.width += tapPoint.x - oldPoint.x;
			if (contFrame.size.width < 564)
				contFrame.size.width = 564;
			else if (contFrame.size.width > 768-41)
				contFrame.size.width = 768-41;
			//~
		}
		
		oldPoint = tapPoint;
	}
	else if (touch.phase == UITouchPhaseEnded)
	{
		// Move bar to the nearest valid position
		CGRect bookFrame = bookSpine.frame;
		if (bookFrame.origin.x > 564 && bookFrame.origin.x < (564 + 768-41)/2)
			[UIView animateWithDuration:0.2 animations:^{[self moveNav:TRUE];} ];
		else if (bookFrame.origin.x >= (564 + 768-41)/2 && bookFrame.origin.x < 768-41)
			[UIView animateWithDuration:0.2 animations:^{[self moveNav:FALSE];} ];			

		if (bookSpine.frame.origin.x - tapPoint.x >= 564)
			return;
		
		oldPoint = tapPoint;
		if (touch.tapCount == 0)
			return;
		
		[appDelegate.contentViewController setIsScrolling: YES];
	
		UIScrollView * contentScrollView = appDelegate.contView;
		CGPoint contentOffset = CGPointMake(0, tapPoint.y/NAV_ZOOM_RATIO + [navView contentOffset].y - 300);
	
		if (contentOffset.y > [contentScrollView contentSize].height - [appDelegate.contView bounds].size.height)
			contentOffset.y = [contentScrollView contentSize].height - [appDelegate.contView bounds].size.height;
		else if (contentOffset.y < 0)
			contentOffset.y = 0;
	
		[contentScrollView setContentOffset:contentOffset animated: NO];
	
		[appDelegate.contentViewController setIsScrolling: NO];
	}
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
