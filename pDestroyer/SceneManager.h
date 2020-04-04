//
//  SceneManager.h
//  SceneManager
//
//  Created by MajorTom on 9/7/10.
//  Copyright iphonegametutorials.com 2010. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "MenuLayer.h"


@interface SceneManager : NSObject {
}

+(void) goMenu;
+(void) go:(CCLayer *) layer;
+(void) go:(CCScene *) scene i:(int) i;

@end
