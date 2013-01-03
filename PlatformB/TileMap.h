//
//  TileMap.h
//  PlatformA
//
//  Created by Roberto Breve on 12/31/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface TileMap : CCLayer {
    
}

@property (nonatomic, retain) CCTMXTiledMap *tileMap;
@property (nonatomic, retain) CCTMXLayer *background;
@property (nonatomic, retain) CCTMXLayer *walls;
@property (nonatomic, retain) CCTMXLayer *elevators;

@property (nonatomic, retain) NSMutableArray *elevatorList;

@end
