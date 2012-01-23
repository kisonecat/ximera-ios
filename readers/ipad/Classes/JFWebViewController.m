/*
  JFWebViewController.m
  
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

#import "JFWebViewController.h"

#define SECTION_COUNT 3

@implementation JFWebViewController

@synthesize spineScroller;

- (void)viewDidLoad
{
	printf("web viewDidLoad\n");
	[super viewDidLoad];
	
	appDelegate = (textbookAppDelegate *) [[UIApplication sharedApplication] delegate];
	
	// Make scrollbars invisible in the web view
	[(UIScrollView*)[webView.subviews objectAtIndex:0] setShowsHorizontalScrollIndicator:NO];
	[(UIScrollView*)[webView.subviews objectAtIndex:0] setShowsVerticalScrollIndicator:NO];	
	
	// Compute section sizes (using file size as a proxy for the content height of the webpage
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSMutableArray *sectionLengths = [NSMutableArray array];
	
	int i;
	for( i=0; i<SECTION_COUNT; i++ ) {
		NSString* filename = [NSString stringWithFormat:@"a%d", i + 1];
		NSString* filePath = [[NSBundle mainBundle] pathForResource:filename ofType:@"html" inDirectory:@"html/html"];

		NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:filePath error:NULL];

		if (fileAttributes != nil) {
			NSNumber* fileSize = [fileAttributes objectForKey:NSFileSize];
			[sectionLengths addObject: fileSize];
		}
	}

	[spineScroller setSectionLengths:sectionLengths];
	
	// load the initial section
	displayedSection = -1;
	[self spineViewDidScroll: spineScroller];
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

// Scroll to the appropriate location after loading
- (void)webViewDidFinishLoad:(UIWebView *)aWebView
{
	printf("web viewDidFinishLoad\n");
	UIScrollView * scrollView = [self scrollView];
	CGPoint contentOffset = CGPointMake(0, [spineScroller currentOffset] * ([scrollView contentSize].height - [webView bounds].size.height));
	[scrollView setContentOffset:contentOffset animated: NO];
	
	scrollView = [appDelegate.navWebViewController scrollView];
	contentOffset = CGPointMake(0, [spineScroller currentOffset] * ([scrollView contentSize].height - [appDelegate.navWebView bounds].size.height/NAV_ZOOM_RATIO));
	[scrollView setContentOffset:contentOffset animated: NO];
	
	isLoading = NO;
}

// When the spine scrolls, scroll the web content
- (void)spineViewDidScroll:(JFSpineScroller *)aSpineScroller
{
	printf("web spineViewDidScroll\n");
	// If we've changed sections, request the HTML file for the new section
	if (displayedSection != [spineScroller currentSection])
	{
		NSString* filename = [NSString stringWithFormat:@"a%d", [spineScroller currentSection] + 1];
		[webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:filename ofType:@"html"
																											inDirectory:@"html/html"]isDirectory:NO]]];	
	
		
		[appDelegate.navWebView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:filename ofType:@"html"
																											inDirectory:@"html/html"]isDirectory:NO]]];		
		
		displayedSection = [spineScroller currentSection];
		isLoading = YES;
	}
	else
	{
		UIScrollView * scrollView = [self scrollView];
		CGPoint contentOffset = CGPointMake(0, [spineScroller currentOffset] * ([scrollView contentSize].height - [webView bounds].size.height));
		[scrollView setContentOffset:contentOffset animated: NO];
		
		scrollView = [appDelegate.navWebViewController scrollView];
		contentOffset = CGPointMake(0, [spineScroller currentOffset] * ([scrollView contentSize].height - [appDelegate.navWebView bounds].size.height/NAV_ZOOM_RATIO));
		[scrollView setContentOffset:contentOffset animated: NO];
	}
}

- (void)goToNextSection: (id)sender
{
	printf("web next section\n");
	// move to next section, or the end of the last section
	if ([spineScroller currentSection] + 1 < SECTION_COUNT) {
		[spineScroller setCurrentSection: [spineScroller currentSection] + 1];
		[spineScroller setCurrentOffset: 0];
	} else {
		[spineScroller setCurrentOffset: 1.0];
	}
	
	[spineScroller setNeedsDisplay];
	[self spineViewDidScroll: spineScroller];
}

- (void)goToPreviousSection: (id)sender
{
	// move to the previous section, or the beginning of the first
	if ([spineScroller currentSection] >= 1) {
		[spineScroller setCurrentSection: [spineScroller currentSection] - 1];
		[spineScroller setCurrentOffset: 1.0];
	} else {
		[spineScroller setCurrentOffset: 0.0];
	}
	
	[spineScroller setNeedsDisplay];
	[self spineViewDidScroll: spineScroller];
}

//
// BADBAD: currently, the bouncing is really broken.
//
// bouncing should reveal the start of the next section, 
// and if you pull hard enough, the next section should pop up
//

// If the web page scrolled, scroll the spine
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	printf("web scrollViewDidScroll\n");
	if (beingScrolling == YES)
		return;
	
	// When we're loading a new section for the first time, we must ignore the webpage scrolling
	if (isLoading == NO)
	{
		// Turn off bouncing when we're halfway down the last section
		if ([scrollView contentOffset].y > 0.5 * [scrollView contentSize].height)
		{
			if ([spineScroller currentSection] == SECTION_COUNT - 1)
				scrollView.bounces = NO;
			else
				scrollView.bounces = YES;
		}
		
		// Turn off bouncing when we're halfway up the first section
		if ([scrollView contentOffset].y < 0.5 * [scrollView contentSize].height)
		{
			if ([spineScroller currentSection] == 0)
				scrollView.bounces = NO;
			else
				scrollView.bounces = YES;
		}
		
		beingScrolling = YES;
		
		[spineScroller setCurrentOffset: [scrollView contentOffset].y / ([scrollView contentSize].height - [webView bounds].size.height) ];
		[spineScroller setNeedsDisplay];

		UIScrollView * navScrollView = [appDelegate.navWebViewController scrollView];
		CGPoint contentOffset = CGPointMake(0, [spineScroller currentOffset] * ([navScrollView contentSize].height - [appDelegate.navWebView bounds].size.height/NAV_ZOOM_RATIO));
		[navScrollView setContentOffset:contentOffset animated: NO];

		beingScrolling = NO;
		
		// If we bounce past the bottom, go to the next section
		CGFloat pixelsOver = [scrollView contentOffset].y - ([scrollView contentSize].height - [webView bounds].size.height);
		
		if (pixelsOver > 0.25 * [webView bounds].size.height)
			[self goToNextSection: self];

		// If we bounce past the top, go to the previous section
		CGFloat pixelsUnder = -[scrollView contentOffset].y;
		
		if (pixelsUnder > 0.25 * [webView bounds].size.height)
			[self goToPreviousSection: self];
	}	
}


- (BOOL)getIsScrolling
{
	return beingScrolling;
}
- (void)setIsScrolling:(BOOL) scrolling
{
	beingScrolling = scrolling;
}


@end
