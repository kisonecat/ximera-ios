/*
  JFMainWindow.m
  
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

#import "JFMainWindow.h"

@implementation JFMainWindow

@synthesize controllerThatObserves;

- (void)forwardTap:(id)touch {
	[controllerThatObserves userDidTapWebView:touch];
}

// This can be used to intercept taps to the webview---might be useful in the future.
- (void)sendEvent:(UIEvent *)event
{
	[super sendEvent:event];
	
	if (controllerThatObserves == nil)
		return;

	NSSet *touches = [event allTouches];
	UITouch* touch = [touches anyObject];

	[self performSelector:@selector(forwardTap:) withObject:touch];
}

@end
