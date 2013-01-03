//
//  IntroLayer.h
//  PlatformA
//
//  Created by Roberto Breve on 12/23/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Character.h"

@class TileMap;
@class Enemy;
// HelloWorldLayer
@interface IntroLayer : CCLayer
{
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@property (nonatomic, retain) Character *dude;
@property (nonatomic, retain) TileMap *bgTile;
@property (nonatomic, retain) Enemy *enemy;
@end
