//
//  JFSectionViewController.m
//  textbook
//
//  Created by Fowler, James on 1/27/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "JFSectionViewController.h"
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
                         [NSString stringWithFormat:@"self ENDSWITH '.png' AND self BEGINSWITH 'tile%03d'", 1]];
    NSArray *onlyTiles = [dirContents filteredArrayUsingPredicate:fltr];
    
    CGSize world;
    world.width = 768;
    world.height = ([onlyTiles count] / 3) * 256;
	self.content.frame = CGRectMake(0, 0, world.width, world.height);
	self.scrollView.contentSize = CGSizeMake(CGRectGetMaxX(self.content.frame),
                                             CGRectGetMaxY(self.content.frame));
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView
{
    [scrollView setContentOffset: CGPointMake(0, scrollView.contentOffset.y)]; // turn off left/right scrolling

    /*
	if (beingScrolling == YES)
		return;
    
    beingScrolling = YES;
    */
    
    textbookAppDelegate *delegate = [UIApplication sharedApplication].delegate;
	    
    UIScrollView *navigatorScrollView = delegate.navigatorViewController.scrollView;
    CGPoint contentOffset = CGPointMake(0, [scrollView contentOffset].y * ([navigatorScrollView contentSize].height - [navigatorScrollView bounds].size.height) / ([scrollView contentSize].height - [delegate.sectionViewController.scrollView bounds].size.height));
    [navigatorScrollView setContentOffset:contentOffset animated: NO];
    
    // beingScrolling = NO;
    
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
    [self sizeContent];
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
