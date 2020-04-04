//
//  MenuLayer.h
//  MenuLayer
//
//  Created by MajorTom on 9/7/10.
//  Copyright iphonegametutorials.com 2010. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Level.h"

//#import "HelloWorldLayer.h"

@interface MenuLayer : Level {
    CCMenu* pMenu;
}

- (void)onNewGame:(id)sender;
//- (void)onContinue:(id)sender;
- (void)onExit:(id)sender;
- (void)onClear:(id)sender;
- (void)onOptions:(id)sender;
- (void)onOptionsSound:(id)sender;
- (void)onOptionsMusic:(id)sender;
- (void)onBack:(id)sender;
- (void)launchLevel:(id)sender;
- (void)launchSurvival:(id)sender;
- (void)launchPuzzle:(id)sender;
- (void)launchMultiplayerGameKit:(id)sender;
-(void) conectToMultiplayerGameKit:(id)sender;

- (void)backgroundMusicFinished;
-(void) setBackgroundMusic;

@end
