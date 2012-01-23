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

#import "JKNavWebViewController.h"
#import "JFWebViewController.h"

@implementation JKNavWebViewController

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
	printf("nav viewDidLoad\n");
	
    [super viewDidLoad];
	
	appDelegate = (textbookAppDelegate *) [[UIApplication sharedApplication] delegate];

	// Make scrollbars invisible in the navWeb view
	UIScrollView * sv = (UIScrollView*)[navWebView.subviews objectAtIndex:0];
	[sv setShowsHorizontalScrollIndicator:NO];
	[sv setShowsVerticalScrollIndicator:NO];

	// Fit the index content to the navWeb window
	sv.transform = CGAffineTransformConcat(sv.transform, CGAffineTransformMakeScale(NAV_ZOOM_RATIO, NAV_ZOOM_RATIO));

	[appDelegate.webView.superview bringSubviewToFront:appDelegate.webView];
	[appDelegate.webView.superview bringSubviewToFront:appDelegate.bookSpine];

	// Draw shadow of bookSpine
	appDelegate.bookSpine.layer.shadowOpacity = 1.0;
	appDelegate.bookSpine.layer.shadowRadius = 5.0;
	appDelegate.bookSpine.layer.shadowOffset = CGSizeMake(-4, 4);
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
	UIScrollView * scrollView = (UIScrollView*)[navWebView.subviews objectAtIndex:0];	
	CGPoint curCenter = scrollView.center;
	
	// Move NavWebView (NavWebView have to move its center because of the Affine transformation
	if (left)
		curCenter.x = 564/2;
	else
		curCenter.x = 442;
	scrollView.center = curCenter;
	//~
	
	// Move Book Spine
	CGRect bookFrame = bookSpine.frame;
	if (left)
		bookFrame.origin.x = 564;
	else
		bookFrame.origin.x = 768-41;
	bookSpine.frame = bookFrame;
	
	// Sizing ContentWebView
	UIScrollView * contentScrollView = [appDelegate.contentWebViewController scrollView];
	CGRect contentFrame = contentScrollView.frame;
	if (left)
		contentFrame.size.width = 564;
	else
		contentFrame.size.width = 768-41;
	
	contentScrollView.frame = contentFrame;
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


// Find the scrollview for the webview (and make ourselves its delegate)
- (UIScrollView*) scrollView
{
    for (UIView* subView in self.view.subviews)
		if ([[subView.class description] isEqualToString:@"UIScrollView"])
		{
			UIScrollView * currentScrollView = (UIScrollView*)subView;
            currentScrollView.delegate = self;
			return currentScrollView;
        }
	
	return nil;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	printf("nav scrollViewDidScroll\n");
	if ([appDelegate.contentWebViewController getIsScrolling] == YES)
		return;
	
	[appDelegate.contentWebViewController setIsScrolling: YES];
	
	[appDelegate.contentWebViewController.spineScroller setCurrentOffset: [scrollView contentOffset].y / ([scrollView contentSize].height - [appDelegate.webView bounds].size.height/NAV_ZOOM_RATIO) ];
	[appDelegate.contentWebViewController.spineScroller setNeedsDisplay];
	
	UIScrollView * contentScrollView = [appDelegate.contentWebViewController scrollView];
	CGPoint contentOffset = CGPointMake(0, [scrollView contentOffset].y * ([contentScrollView contentSize].height - [appDelegate.webView bounds].size.height) / ([scrollView contentSize].height - [navWebView bounds].size.height/NAV_ZOOM_RATIO));
	[contentScrollView setContentOffset:contentOffset animated: NO];
	
	[appDelegate.contentWebViewController setIsScrolling: NO];
}



- (void)userDidTapWebView:(UITouch *)touch
{
	static CGPoint oldPoint;
	
	if ([appDelegate.contentWebViewController getIsScrolling] == YES)
		return;
	
	CGPoint tapPoint = [touch locationInView:navWebView];
	if (tapPoint.x < -41 || tapPoint.y < 0)
		return;
	
	UIScrollView * scrollView = (UIScrollView*)[navWebView.subviews objectAtIndex:0];
	CGPoint curCenter = scrollView.center;
	
	if (touch.phase == UITouchPhaseBegan)
		oldPoint = tapPoint;
	else if (touch.phase == UITouchPhaseMoved)
	{
		CGRect bookFrame = bookSpine.frame;
		if (bookFrame.origin.x - tapPoint.x >= 564)
		{
			// Move NavWebView (NavWebView have to move its center because of the Affine transformation)
			curCenter.x += tapPoint.x - oldPoint.x;
			if (curCenter.x < 564/2)
				curCenter.x = 564/2;
			else if (curCenter.x > 442)
				curCenter.x = 442;
		
			scrollView.center = curCenter;
			//~
		
			// Move Book Spine
			bookFrame.origin.x += tapPoint.x - oldPoint.x;
			if (bookFrame.origin.x < 564)
				bookFrame.origin.x = 564;
			else if (bookFrame.origin.x > 768-41)
				bookFrame.origin.x = 768-41;
		
			bookSpine.frame = bookFrame;
			//~

			// Sizing ContentWebView
			UIScrollView * contentScrollView = [appDelegate.contentWebViewController scrollView];
			CGRect contentFrame = contentScrollView.frame;
			contentFrame.size.width += tapPoint.x - oldPoint.x;
			if (contentFrame.size.width < 564)
				contentFrame.size.width = 564;
			else if (contentFrame.size.width > 768-41)
				contentFrame.size.width = 768-41;
			contentScrollView.frame = contentFrame;
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

		
		oldPoint = tapPoint;
		if (touch.tapCount == 0)
			return;
		
		[appDelegate.contentWebViewController setIsScrolling: YES];
	
		[appDelegate.contentWebViewController.spineScroller setCurrentOffset: ([scrollView contentOffset].y + tapPoint.y) / ([scrollView contentSize].height - [appDelegate.webView bounds].size.height/NAV_ZOOM_RATIO)];
		[appDelegate.contentWebViewController.spineScroller setNeedsDisplay];
	
		UIScrollView * contentScrollView = [appDelegate.contentWebViewController scrollView];
		CGPoint contentOffset = CGPointMake(0, tapPoint.y/NAV_ZOOM_RATIO + [scrollView contentOffset].y - 300);
	
		if (contentOffset.y > [contentScrollView contentSize].height - [appDelegate.webView bounds].size.height)
			contentOffset.y = [contentScrollView contentSize].height - [appDelegate.webView bounds].size.height;
		else if (contentOffset.y < 0)
			contentOffset.y = 0;
	
		[contentScrollView setContentOffset:contentOffset animated: NO];
	
		[appDelegate.contentWebViewController setIsScrolling: NO];
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
