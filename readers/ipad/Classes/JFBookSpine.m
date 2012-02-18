/*
  JFBookSpine.m
  
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

#import "JFBookSpine.h"
#import <QuartzCore/QuartzCore.h>

@implementation JFBookSpine

@synthesize navigationScrollView;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/

- (void)dealloc {
    [super dealloc];
}


-(void)awakeFromNib 
{
    [super awakeFromNib];

    // Drop-shadow to the left hand side
    self.layer.shadowOpacity = 0.8;
    self.layer.shadowRadius = 4.0;
    self.layer.shadowOffset = CGSizeMake(0, 0);
    self.clipsToBounds = NO;

    // Panning gesture
    UIPanGestureRecognizer *pan = [[[UIPanGestureRecognizer alloc] init] autorelease];
	[pan addTarget:self action:@selector(move:)];
	[self addGestureRecognizer: pan];
}

-(void)move:(id)sender
{
	CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:self.superview];
    
    static CGRect originalFrame;
     
	if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
        originalFrame = [self frame];
        return;
	}
    
    CGFloat leftMost = [[self superview] frame].size.width - originalFrame.size.width;
    CGFloat rightMost = [[self superview] frame].size.width - originalFrame.size.width + navigationScrollView.frame.size.width;
    
    CGPoint newOrigin = CGPointMake( originalFrame.origin.x + translatedPoint.x,
                                    originalFrame.origin.y // Only panning in the right/left direction
                                    );
    
    if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateChanged) {
        if (newOrigin.x < leftMost)
            newOrigin.x = leftMost;
        
        if (newOrigin.x > rightMost)
            newOrigin.x = rightMost;
        
        self.frame = CGRectMake( newOrigin.x, newOrigin.y,
                                 originalFrame.size.width, originalFrame.size.height );

        return;
	}

	if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
        // Snap to the left
        if (newOrigin.x < (leftMost + rightMost)/2)
            newOrigin.x = leftMost;

        // Snap to the right
        if (newOrigin.x >= (leftMost + rightMost)/2)
            newOrigin.x = rightMost;
        
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:.35];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		[[sender view] setFrame: CGRectMake( newOrigin.x, newOrigin.y,
                                            originalFrame.size.width, originalFrame.size.height )];
		[UIView commitAnimations];
	}
}

@end
