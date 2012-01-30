//
//  JFNavigatorViewController.m
//  textbook
//
//  Created by Fowler, James on 1/27/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "JFNavigatorViewController.h"
#import "JFSectionViewController.h"
#import "textbookAppDelegate.h"
#import <QuartzCore/QuartzCore.h>


@implementation JFNavigatorViewController

@synthesize scrollView;

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

#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    UIImage *image = [UIImage imageNamed: @"page001.png"];
    CALayer *layer = [CALayer layer];
    layer.contents = (id)image.CGImage;
    
    CGFloat width = self.view.frame.size.width;
    CGFloat height = width * image.size.height / image.size.width;
    layer.frame = CGRectMake(0,0,width,height);
    [self.view.layer addSublayer:layer];
    self.view.frame = layer.frame;
    self.scrollView.contentSize = layer.frame.size;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [self loadView];
    [super viewDidLoad];
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
	return YES;
}

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

    // this thing is causing a stack overflow!
    /*
    [aScrollView setContentOffset: CGPointMake(0, aScrollView.contentOffset.y)]; // turn off left/right scrolling
    
    textbookAppDelegate *delegate = [UIApplication sharedApplication].delegate;
    
    UIScrollView *sectionScrollView = delegate.sectionViewController.scrollView;
   
    CGFloat navigatorScrolledFraction = (aScrollView.contentOffset.y) / (aScrollView.contentSize.height - aScrollView.bounds.size.height);
    CGFloat sectionScrolledDistance = navigatorScrolledFraction * (sectionScrollView.contentSize.height - sectionScrollView.bounds.size.height);
    CGPoint contentOffset = CGPointMake(0, sectionScrolledDistance);
    [sectionScrollView setContentOffset:contentOffset animated: NO];
     */
}


@end
