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

@class JFPagingViewController;

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
    //if we are gone, we do not need boundaries
    free (yBoundaries);
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
    textbookAppDelegate *delegate = [UIApplication sharedApplication].delegate;
    textbookAppDelegate *appDelegate = (textbookAppDelegate *)[[UIApplication sharedApplication] delegate];
    int sectionCount = [delegate sectionCount];
    
    //this one will keep the boundaries of the spines
    yBoundaries = malloc((sectionCount+1)*sizeof(float));
    
    CGFloat position = 0;
    CGFloat width = 0;
    for( int i=0; i<sectionCount; i++ ) {
        NSString *filename = [NSString stringWithFormat: @"page%03d.png", i + 1];
        UIImage *image = [UIImage imageNamed:filename];
        UIImage *nImage = [self negativeImage:image];
        CALayer *layer = [CALayer layer];
        if(appDelegate.night == true){
        layer.contents = (id)nImage.CGImage;
        }
       else {
        layer.contents = (id)image.CGImage;
       }
    
        width = self.view.frame.size.width;
        CGFloat height = width * image.size.height / image.size.width;
        layer.frame = CGRectMake(0,position,width,height);
        
        yBoundaries[i]=position;
        // to get one of them:
        position += height;
        [self.view.layer addSublayer:layer];
    }    
    
    yBoundaries[sectionCount] = position;
    
    self.view.frame = CGRectMake(0,0,width,position);
    self.scrollView.contentSize = self.view.frame.size;
    if(appDelegate.night == false)
     self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper.png"]];
    else {
        self.view.backgroundColor = [UIColor blackColor];
    }
}
-(IBAction)buttonPressed{
     textbookAppDelegate *appDelegate = (textbookAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.night = true;
    [self loadView];
}
- (UIImage *)negativeImage:(UIImage*)tile
{
    CGSize size = tile.size;
    int width = size.width;
    int height = size.height;
    
    // Create a suitable RGB+alpha bitmap context in BGRA colour space
    CGColorSpaceRef colourSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *memoryPool = (unsigned char *)calloc(width*height*4, 1);
    CGContextRef context = CGBitmapContextCreate(memoryPool, width, height, 8, width * 4, colourSpace, kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colourSpace);
    
    // draw the current image to the newly created context
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), [tile CGImage]);
    
    // run through every pixel, a scan line at a time...
    for(int y = 0; y < height; y++)
    {
        // get a pointer to the start of this scan line
        unsigned char *linePointer = &memoryPool[y * width * 4];
        
        // step through the pixels one by one...
        for(int x = 0; x < width; x++)
        {
            //get rgb values
            int r, g, b; 
            if(linePointer[3])
            {
                r = linePointer[0] * 255 / linePointer[3];
                g = linePointer[1] * 255 / linePointer[3];
                b = linePointer[2] * 255 / linePointer[3];
            }
            else
                r = g = b = 0;
            
            // invert colors
            r = 255 - r;
            g = 255 - g;
            b = 255 - b;
            
            // multiply by alpha again, divide by 255 to undo the
            // scaling before, store the new values and advance
            // the pointer we're reading pixel data from
            linePointer[0] = r * linePointer[3] / 255;
            linePointer[1] = g * linePointer[3] / 255;
            linePointer[2] = b * linePointer[3] / 255;
            linePointer += 4;
        }
    }
    
    // get a CG image from the context, wrap that into a
    // UIImage
    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    UIImage *returnImage = [UIImage imageWithCGImage:cgImage];
    
    // clean up
    CGImageRelease(cgImage);
    CGContextRelease(context);
    free(memoryPool);
    
    return returnImage;
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

//This is where we will move to the right section
- (IBAction)tapped:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded)     
    {   
        textbookAppDelegate *delegate = [UIApplication sharedApplication].delegate;
        // handling code     
        CGPoint p = [sender locationInView:scrollView];
        CGFloat y = p.y;
        int section = 0;
        while (yBoundaries[section+1]<y){
            section ++;
        }
        //the 
        float offset = ((float)(y - yBoundaries[section]))  /
                            ((float)(yBoundaries[section+1] - yBoundaries[section]));
        JFPagingViewController* pager = [delegate getPagingViewController];
        [pager setSection : section withOffset : offset];
    }
}
@end
