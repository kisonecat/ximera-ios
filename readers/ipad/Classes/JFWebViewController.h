/*
  JFWebViewController.h
  
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
#import "JFSpineScroller.h"
#import "textbookAppDelegate.h"

#define NAV_ZOOM_RATIO 0.29

@interface JFWebViewController : UIViewController<UIScrollViewDelegate, SpineScrollerDelegate> {
	IBOutlet UIWebView *webView;
	IBOutlet JFSpineScroller* spineScroller;

	int displayedSection;
	BOOL isLoading;
	textbookAppDelegate * appDelegate;
	
	BOOL beingScrolling;
}

- (UIScrollView*) scrollView;
- (void)spineViewDidScroll:(JFSpineScroller *)aSpineScroller;

- (IBAction)goToPreviousSection: (id)sender;
- (IBAction)goToNextSection: (id)sender;

- (BOOL)getIsScrolling;
- (void)setIsScrolling:(BOOL) scrolling;

@property (nonatomic, retain) IBOutlet JFSpineScroller * spineScroller;

@end
