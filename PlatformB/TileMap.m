//
//  TileMap.m
//  PlatformA
//
//  Created by Roberto Breve on 12/31/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "TileMap.h"
#import "MovingSprite.h"

@implementation TileMap

-(id) init
{
    if( (self=[super init] )) {
        
        
        self.tileMap = [CCTMXTiledMap tiledMapWithTMXFile:@"world1.tmx"];
        self.walls = [self.tileMap layerNamed:@"walls"];
        self.elevators = [self.tileMap layerNamed:@"elevators"];
        self.hazards = [self.tileMap layerNamed:@"hazards"];
        self.fruits = [self.tileMap layerNamed:@"fruits"];
        self.pushable = [self.tileMap layerNamed:@"pushable"];
        self.keys = [self.tileMap layerNamed:@"keys"];

        [self addChild:self.tileMap z:-1];
            
        
    }
    return self;
}

-(NSMutableArray *)elevatorList{
    if (_elevatorList == nil){
        
        _elevatorList = [[NSMutableArray alloc] init];
        CGSize s = [self.elevators layerSize];
        for( int x=0; x<s.width;x++) {
            for( int y=0; y< s.height; y++ ) {
                unsigned int tgid = [self.elevators tileGIDAt:ccp(x,y)];
                if (tgid){
                    
                    CGRect tileCoords=[self tileRectFromTileCoords:ccp(x, y)];
                    
                    MovingSprite *elevatorSprite = [[MovingSprite alloc] initWithFile:@"elevator.png" rect:tileCoords];
                       
                    elevatorSprite.gId = tgid;
                    elevatorSprite.tag = tgid;
                    elevatorSprite.initPosition = ccp(tileCoords.origin.x, tileCoords.origin.y);
                 
                    [self.elevatorList addObject:elevatorSprite];
                    
                    [self.elevators removeTileAt:ccp(x,y)];
                    
                }
          
                
                                          
            }
        }
    }
    return _elevatorList;
        
}


-(CGRect)tileRectFromTileCoords:(CGPoint)tileCoords {
    float levelHeightInPixels = self.tileMap.mapSize.height * self.tileMap.tileSize.height;
    CGPoint origin = ccp(tileCoords.x * self.tileMap.tileSize.width, levelHeightInPixels - ((tileCoords.y + 1) * self.tileMap.tileSize.height));
    return CGRectMake(origin.x, origin.y, self.tileMap.tileSize.width, self.tileMap.tileSize.height);
}

-(CGPoint) getSpawnPointfromObjectNamed:(NSString *) objectName{
    CCTMXObjectGroup *objects = [self.tileMap objectGroupNamed:@"Spawns"];
    NSAssert(objects != nil, @"'Objects' object group not found");
    NSMutableDictionary *spawnPoint = [objects objectNamed:objectName];
    NSAssert(spawnPoint != nil, @"SpawnPoint object not found");
    
    int x = [[spawnPoint valueForKey:@"x"] intValue];
    int y = [[spawnPoint valueForKey:@"y"] intValue];
    
    return ccp(x, y);
}

-(NSMutableArray *) getCoins{
    CCTMXObjectGroup *objects = [self.tileMap objectGroupNamed:@"Coins"];
    NSLog(@"filename %@", [objects valueForKey:@"filename"]);
    NSMutableArray *spawnPoints = [objects objects];
    NSMutableArray *points = [[NSMutableArray alloc] init];
    for (NSDictionary *point in spawnPoints){
        [points addObject:[NSValue valueWithCGPoint:ccp([[point valueForKey:@"x"] floatValue], [[point valueForKey:@"y"] floatValue])]];
    }
    return  points;
    
}

@end
