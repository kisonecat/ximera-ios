/*
  JFPopupView.m
  
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

#import "JFPopupView.h"


@implementation JFPopupView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetLineWidth(context, 1 );

	CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor );
	CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor );

	CGRect rrect = self.bounds;
	
	CGContextMoveToPoint(context, CGRectGetMaxX(rrect), CGRectGetMaxY(rrect) );
	CGContextAddLineToPoint(context, CGRectGetMinX(rrect), CGRectGetMaxY(rrect) );
	CGContextAddLineToPoint(context, CGRectGetMinX(rrect), CGRectGetMinY(rrect) );
	CGContextAddLineToPoint(context, CGRectGetMaxX(rrect), CGRectGetMinY(rrect) );
	
	CGContextClosePath(context);
	CGContextDrawPath(context, kCGPathFillStroke);
			
	return;
}

- (IBAction)displayPopup:(id)sender
{
	if ([self isHidden]) {
		[self setHidden: NO];
	} else {
		[self setHidden: YES];
	}

}

- (void)dealloc {
    [super dealloc];
}


@end
