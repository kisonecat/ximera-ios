/*
  JFSpineScroller.h
  
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

#import <UIKit/UIKit.h>

@class JFSpineScroller;

@protocol SpineScrollerDelegate
- (void)spineViewDidScroll:(JFSpineScroller*)spineScroller;
@end


@interface JFSpineScroller : UIView {
	NSArray *sectionLengths;
	int currentSection;
	CGFloat currentOffset;
	IBOutlet id<SpineScrollerDelegate> delegate;
}

@property int currentSection;
@property CGFloat currentOffset;
@property (retain) NSArray *sectionLengths;

@end
