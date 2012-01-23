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

#import "JFContViewController.h"

#define SECTION_COUNT 3

@implementation JFContViewController


- (void)viewDidLoad
{
	[super viewDidLoad];
	
	appDelegate = (textbookAppDelegate *) [[UIApplication sharedApplication] delegate];

/*
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
 */
	// load the initial section
	displayedSection = 1;
	[self loadData];
}


- (void)loadData
{
	CGRect viewFrame;
	viewFrame.origin.x = 0;
	viewFrame.origin.y = 0;
	viewFrame.size.width = 256+256+254;
	viewFrame.size.height = (75 / 3) * 256;
	
	UIView * contBaseView = [[UIView alloc] initWithFrame:viewFrame];
	UIView * navBaseView = [[UIView alloc] initWithFrame:viewFrame];
	
	int zoom256 = 256*NAV_ZOOM_RATIO;
	int zoom254 = 254*NAV_ZOOM_RATIO;
	
	for (int i=0; i <= 74; ++i)
	{
		CATiledLayer * tileLayer = [CATiledLayer layer];
		tileLayer.frame = CGRectMake((i%3)*256, (i/3)*256, ((i+1)%3 == 0) ? 254: 256, 256);
		NSString* filename = [NSString stringWithFormat: (i < 10) ? @"tile0%d.png" : @"tile%d.png", i]; // numbering the tile05.png
		UIImage * aTile = [UIImage imageNamed:filename];
		tileLayer.contents = (id) aTile.CGImage;
		[contBaseView.layer addSublayer:tileLayer];
		
		tileLayer = [CATiledLayer layer];
		tileLayer.frame = CGRectMake((i%3)*zoom256, (i/3)*zoom256, ((i+1)%3 == 0) ? zoom254: zoom256, zoom256);
		
		CGSize navSize = CGSizeMake(((i+1)%3 == 0) ? zoom254 : zoom256, zoom256);
		UIGraphicsBeginImageContext(navSize);
		[aTile drawInRect:CGRectMake(0, 0, navSize.width, navSize.height)];
		UIImage * smallTile = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		
		tileLayer.contents = (id) smallTile.CGImage;
		[navBaseView.layer addSublayer:tileLayer];
	}
		
	[contView addSubview:contBaseView];
	contView.contentSize = viewFrame.size;
    
    // give it a margin
    // make new tiles ? 
	
	viewFrame.size.width = 2*zoom256 + zoom254;
	viewFrame.size.height = (75/3)*zoom256;
	
	[appDelegate.navView addSubview:navBaseView];
	appDelegate.navView.contentSize = viewFrame.size;
	
	
	CGRect frame = CGRectMake(50, 100, 400, 400);
	UIWebView * webview = [[UIWebView alloc] initWithFrame:frame];
	[contView addSubview:webview];
    [webview setBackgroundColor:[UIColor clearColor]]; // makes webview
    [webview setOpaque:NO];                            // transparent
    
    //[webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"/Users/snapp/textbook/Classes/interactive.html"]]];

    [webview loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"interactive" ofType:@"html"]isDirectory:NO]]];

    
	// Now how do you have html files in an iPad app?
    // Will the current program actually run on the ipad?
}   




- (void)goToNextSection: (id)sender
{
	if (displayedSection < SECTION_COUNT)
	{
		++ displayedSection;
		[self loadData];
	}
}

- (void)goToPreviousSection: (id)sender
{
	if (displayedSection > 1)
	{
		-- displayedSection;
		[self loadData];
	}		
}


//
// BADBAD: currently, the bouncing is really broken.
//
// bouncing should reveal the start of the next section, 
// and if you pull hard enough, the next section should pop up
//

// If the cont page scrolled, scroll the nav page

float oldX; // here or better in .h interface

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    

[scrollView setContentOffset: CGPointMake(0, scrollView.contentOffset.y)]; // turn off left/right scrolling

	if (beingScrolling == YES)
		return;
	
	// When we're loading a new section for the first time, we must ignore the page scrolling
	if (isLoading == NO)
	{		
		beingScrolling = YES;
	
		UIScrollView * navScrollView = appDelegate.navView;
		CGPoint contentOffset = CGPointMake(0, [scrollView contentOffset].y * ([navScrollView contentSize].height - [appDelegate.navView bounds].size.height) / ([scrollView contentSize].height - [contView bounds].size.height));
		[navScrollView setContentOffset:contentOffset animated: NO];

		beingScrolling = NO;
		
		// If we bounce past the bottom, go to the next section
		CGFloat pixelsOver = [scrollView contentOffset].y - ([scrollView contentSize].height - [contView bounds].size.height);
		
		if (pixelsOver > 0.25 * [contView bounds].size.height)
			[self goToNextSection: self];

		// If we bounce past the top, go to the previous section
		CGFloat pixelsUnder = -[scrollView contentOffset].y;
		
		if (pixelsUnder > 0.25 * [contView bounds].size.height)
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
