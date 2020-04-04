//
//  AppDelegate.h
//  pDestroyer
//
//  Created by ITmind on 29.07.11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) UIWindow *window;

-(void) loadSprite;
-(void) deleteSender:(id)sender;

@end
