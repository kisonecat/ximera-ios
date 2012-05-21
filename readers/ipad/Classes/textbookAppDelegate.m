/*
  textbookAppDelegate.m
  
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

#import "textbookAppDelegate.h"

@implementation textbookAppDelegate

@synthesize window;
@synthesize left;
@synthesize right;
@synthesize sectionViewController, navigatorViewController;
@synthesize bookSpine;
@synthesize night;
- (int)sectionCount
{
    NSString *bundleRoot = [[NSBundle mainBundle] bundlePath];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *dirContents = [fm contentsOfDirectoryAtPath:bundleRoot error:nil];
    NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '.png' AND self BEGINSWITH 'page'"];
    NSArray *onlyPages = [dirContents filteredArrayUsingPredicate:fltr];
    
    return [onlyPages count];
}

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    

    [window makeKeyAndVisible];
	
	//diasble Scrolling "Bounce"
	/*
	for (id subview in webView.subviews) {
		if ([[subview class] isSubclassOfClass: [UIScrollView class]]) {
			((UIScrollView *)subview).bounces = NO;
		}
	}*/
    night = false;
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    [window release];
    [super dealloc];
}

- (void)registerPaigingViewController: (JFPagingViewController *) registerMe{
    pagingViewController = registerMe;
}

- (JFPagingViewController *) getPagingViewController{
    return pagingViewController;
}

- (IBAction)dayNightPressed:(id)sender {
    
    //This needs to be reversible
    night = !night;       
    //from one of the subroutines
    [navigatorViewController loadView];
    [pagingViewController refresh];
    
    //this is in sectionViewController
    //[self setSection:currentSection];
    
   // [sectionViewController loadView];
    
   // [pagingViewController loadView];
    //[bookSpine loadView];
}

@end
