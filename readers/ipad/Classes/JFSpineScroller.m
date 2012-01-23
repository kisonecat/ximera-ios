/*
  JFSpineScroller.m
  
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

#import "JFSpineScroller.h"

static void drawRoundRect( CGContextRef context, CGRect rrect, CGFloat radius )
{
	CGFloat width = CGRectGetWidth(rrect);
	CGFloat height = CGRectGetHeight(rrect);

	// Make sure corner radius isn't larger than half the shorter side
	if (radius > width/2.0) 	radius = width/2.0;
	if (radius > height/2.0) 	radius = height/2.0;    

	CGFloat minx = CGRectGetMinX(rrect);
	CGFloat midx = CGRectGetMidX(rrect);
	CGFloat maxx = CGRectGetMaxX(rrect);
	CGFloat miny = CGRectGetMinY(rrect);
	CGFloat midy = CGRectGetMidY(rrect);
	CGFloat maxy = CGRectGetMaxY(rrect);
	CGContextMoveToPoint(context, minx, midy);
	CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
	CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
	CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
	CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
	CGContextClosePath(context);
	CGContextDrawPath(context, kCGPathFillStroke);
}
	
@implementation JFSpineScroller

@synthesize currentOffset;
@synthesize currentSection;
@synthesize sectionLengths;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
	}
    return self;
}

- (void)awakeFromNib
{
	currentSection = 0;
	currentOffset = 0;
}

- (CGFloat)totalLength
{
	CGFloat total = 0.0;
	NSNumber *number;
	
	for( number in sectionLengths ) {
		total = total + [number floatValue]; 
	}
	
	return total;
}

- (void)drawRect:(CGRect)rect {
	if (sectionLengths == nil) return;
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetLineWidth(context, 0 );
		
	CGFloat spacing = self.bounds.size.width * 0.2;

	CGFloat availablePixels = self.bounds.size.height - spacing * ([sectionLengths count] - 1);
	
	CGFloat topEdge = 0;
	int i;
	for( i=0; i<[sectionLengths count]; i++ ) {
		CGFloat sectionHeight = availablePixels * [[sectionLengths objectAtIndex: i] floatValue] / [self totalLength];
		
		CGRect sectionRect = CGRectMake(self.bounds.size.width * 0.4, topEdge,
										self.bounds.size.width * 0.2, sectionHeight);

		CGContextSetStrokeColorWithColor(context, [UIColor darkGrayColor].CGColor );
		CGContextSetFillColorWithColor(context, [UIColor darkGrayColor].CGColor );
		drawRoundRect( context, sectionRect, self.bounds.size.width * 0.1 );
		
		if (i == currentSection) {
			CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor );
			CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor );
			
			CGFloat topFraction = currentOffset;
			if (topFraction > 1.0) topFraction = 1.0;
			if (topFraction < 0.0) topFraction = 0.0;
			
			CGFloat minSectionHeight = spacing;
			CGRect currentRect = sectionRect;
			currentRect.origin.y = topEdge + topFraction * (sectionHeight - minSectionHeight);
			currentRect.size.height = minSectionHeight;
			
			drawRoundRect( context, currentRect, self.bounds.size.width * 0.1 );
		}
		
		topEdge += spacing + sectionHeight;
	}
	
	return;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (sectionLengths == nil) return;

	UITouch *touch = [touches anyObject];
	CGPoint point = [touch locationInView:self];
	
	CGFloat spacing = self.bounds.size.width * 0.2;
	CGFloat availablePixels = self.bounds.size.height - spacing * ([sectionLengths count] - 1);
	CGFloat topEdge;
	
	int i;
	for( i=0; i<[sectionLengths count]; i++ ) {
		CGFloat sectionHeight = availablePixels * [[sectionLengths objectAtIndex: i] floatValue] / [self totalLength];
		
		CGRect sectionRect = CGRectMake(0, topEdge,
										self.bounds.size.width, sectionHeight);
		if (CGRectContainsPoint(sectionRect, point)) {
			currentOffset = (point.y - sectionRect.origin.y) / sectionRect.size.height;
			currentSection = i;
			[delegate spineViewDidScroll:self];
			[self setNeedsDisplay];
		}
		
		topEdge += spacing + sectionHeight;
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (sectionLengths == nil) return;

	UITouch *touch = [touches anyObject];
	CGPoint point = [touch locationInView:self];
	
	CGFloat spacing = self.bounds.size.width * 0.2;
	CGFloat availablePixels = self.bounds.size.height - spacing * ([sectionLengths count] - 1);
	CGFloat topEdge;
	
	int i;
	for( i=0; i<[sectionLengths count]; i++ ) {
		CGFloat sectionHeight = availablePixels * [[sectionLengths objectAtIndex: i] floatValue] / [self totalLength];
		
		CGRect sectionRect = CGRectMake(0, topEdge,
										self.bounds.size.width, sectionHeight);
		
		if (i == currentSection) {
			currentOffset = (point.y - sectionRect.origin.y) / sectionRect.size.height;
			if (currentOffset < 0.0) currentOffset = 0.0;
			if (currentOffset > 1.0) currentOffset = 1.0;
			[delegate spineViewDidScroll:self];
			[self setNeedsDisplay];
		}
		
		topEdge += spacing + sectionHeight;
	}	
}


/*
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesEnded:touches withEvent:event];
	
	printf("message");
	for (UITouch * touch in touches)
		printf(" %d\n", touch.tapCount);
}
*/

- (void)dealloc {
    [super dealloc];
}

@end
