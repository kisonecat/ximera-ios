//
//  JFSectionViewController.m
//  textbook
//
//  Created by Fowler, James on 1/27/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "JFSectionViewController.h"
#import "JFSectionView.h"
#import "JFNavigatorViewController.h"
#import "textbookAppDelegate.h"

@implementation JFSectionViewController

@synthesize content;
@synthesize scrollView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(IBAction)buttonPressed{
    textbookAppDelegate *appDelegate = (textbookAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.night = true;                                                    
    [self setSection:currentSection];
}

- (UIView*)viewForZoomingInScrollView:(UIScrollView*)scrollView
{
	return content;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)sizeContent
{
    NSString *bundleRoot = [[NSBundle mainBundle] bundlePath];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *dirContents = [fm contentsOfDirectoryAtPath:bundleRoot error:nil];
    NSPredicate *fltr = [NSPredicate predicateWithFormat:
                         [NSString stringWithFormat:@"self ENDSWITH '.png' AND self BEGINSWITH 'tile%03d'", (currentSection+1)]];
    NSArray *onlyTiles = [dirContents filteredArrayUsingPredicate:fltr];
    
    CGSize world;
    world.width = 768;
    world.height = ([onlyTiles count] / 3) * 256;
	self.content.frame = CGRectMake(0, 0, world.width, world.height);
	self.scrollView.contentSize = CGSizeMake(CGRectGetMaxX(self.content.frame),
                                             CGRectGetMaxY(self.content.frame));
}

- (int)currentSection
{
    return currentSection;
}

- (void)setSection:(int)aSection
{
    textbookAppDelegate *appDelegate = (textbookAppDelegate *)[[UIApplication sharedApplication] delegate];
    // Remove any old webviews
    NSArray *subviews = [[self.view subviews] copy];
    for(UIView *subview in subviews) {
        if ([subview isKindOfClass:[UIWebView class]]) {
            [subview removeFromSuperview];
        }
    }
    
    currentSection = aSection;
    ((JFSectionView*)self.view).section = currentSection;

    // Recompute the size of the section
    [self sizeContent];
    
    // Clear the tiled image cache
    self.view.layer.contents = nil; // turns the CATiledLayer into a CALayer
    [self.view setNeedsDisplay]; // "magically" restores the layer to a CATiledLayer?
    if(appDelegate.night == false)
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper.png"]];
    else {
        self.view.backgroundColor = [UIColor blackColor];
    }
    // Create any webviews that the user requested
    NSString *path = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"textbook.plist"];
    NSArray *interactiveElements = [NSArray arrayWithContentsOfFile:path];
    
    for(NSDictionary *interactiveElement in interactiveElements) {
        if ([[interactiveElement valueForKey:@"page"] intValue] == currentSection + 1) {
            NSArray* points = [interactiveElement valueForKey:@"rectangle"];
            
            // A PDF rectangle is left-top-right-bottom, but the coordinate system changed in extract.rb
            // so that the origin is now in the upper-left
            CGFloat left = [[points objectAtIndex:0] floatValue];
            CGFloat bottom = [[points objectAtIndex:1] floatValue];
            CGFloat right = [[points objectAtIndex:2] floatValue];
            CGFloat top = [[points objectAtIndex:3] floatValue];

            CGRect webFrame = CGRectMake(left, top, right - left, bottom - top);
            UIWebView *webView = [[UIWebView alloc] initWithFrame:webFrame];
            [(UIScrollView*)[webView.subviews objectAtIndex:0] setShowsHorizontalScrollIndicator:NO];
            [(UIScrollView*)[webView.subviews objectAtIndex:0] setShowsVerticalScrollIndicator:NO]; 
            [webView setBackgroundColor:[UIColor clearColor]];
            [webView setOpaque:NO];
            
            // Hide the UIImageView's which create the shadow
            for(UIView *subview in [[[webView subviews] objectAtIndex:0] subviews]) { 
                if([subview isKindOfClass:[UIImageView class]])
                    subview.hidden = YES;
            }
            
            NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"interactive" ofType:@"html"] isDirectory:NO];
            [webView loadRequest:[NSURLRequest requestWithURL:url]];
            [self.view addSubview:webView]; 
            [webView release];
        }
    }
}

/*
- (void)setSection:(int)aSection withOffset:(float)offset{
    //First get the section content right
    [self setSection:aSection];
    //then move the  scrollwiew to the correct place
    CGFloat maxScreenY = self.scrollView.frame.size.height;
    CGFloat sectionLength = self.content.frame.size.height;
    //TODO tweak this, it is not great
    CGFloat currentStartY = (sectionLength - maxScreenY) * offset;
    if (currentStartY < 0){
        currentStartY = 0;
    }
    if (currentStartY > sectionLength - maxScreenY){
        currentStartY = sectionLength - maxScreenY;
    }
}
*/

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    isDragging = YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    isDragging = NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView
{
    if (isDragging != YES)
        return;
    
    [scrollView setContentOffset: CGPointMake(0, scrollView.contentOffset.y)]; // turn off left/right scrolling
    
    textbookAppDelegate *delegate = [UIApplication sharedApplication].delegate;
	    
    UIScrollView *navigatorScrollView = delegate.navigatorViewController.scrollView;
    
    CGFloat sectionScrolledFraction = (scrollView.contentOffset.y) / (scrollView.contentSize.height - scrollView.bounds.size.height);
    CGFloat navigatorScrolledDistance = sectionScrolledFraction * (navigatorScrollView.contentSize.height - navigatorScrollView.bounds.size.height);
    CGPoint contentOffset = CGPointMake(0, navigatorScrolledDistance);
    [navigatorScrollView setContentOffset:contentOffset animated: NO];
    
#if 0
    // If we bounce past the bottom, go to the next section
    CGFloat pixelsOver = [scrollView contentOffset].y - ([scrollView contentSize].height - [contView bounds].size.height);
    
    if (pixelsOver > 0.25 * [contView bounds].size.height)
        [self goToNextSection: self];
    
    // If we bounce past the top, go to the previous section
    CGFloat pixelsUnder = -[scrollView contentOffset].y;
    
    if (pixelsUnder > 0.25 * [contView bounds].size.height)
        [self goToPreviousSection: self];
#endif
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end