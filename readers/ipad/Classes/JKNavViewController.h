/*
  JKNavViewController.h
  
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
#import "JFMainWindow.h"
#import "textbookAppDelegate.h"
#import "JFBookSpine.h"

@interface JKNavViewController : UIViewController<UIScrollViewDelegate, TapDetectingWindowDelegate>
{
	IBOutlet UIScrollView *navView;
	IBOutlet UIWindow *window;
	IBOutlet JFBookSpine *bookSpine;
	
	textbookAppDelegate * appDelegate;
}

- (void) handleSwipe:(UISwipeGestureRecognizer *)swipe;
- (void) moveNav:(BOOL) left;

@end
