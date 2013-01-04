//
//  IntroLayer.m
//  PlatformA
//
//  Created by Roberto Breve on 12/23/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


// Import the interfaces
#import "IntroLayer.h"
#import "TileMap.h"
#import "Enemy.h"
#import "MovingSprite.h"
#import "Elevator.h"

#pragma mark - IntroLayer

@interface IntroLayer()
@property (nonatomic, retain) NSMutableArray *elevators;
@property (nonatomic, retain) NSMutableArray *elevatorList;
@end

@implementation IntroLayer{
    
}

@synthesize bgTile = _bgTile, dude = _dude, enemy = _enemy, elevatorList = _elevatorList;

-(id) init{
    if( (self=[super init]) ) {
        self.isTouchEnabled = YES;
        [self schedule:@selector(moving:)];

    }
    return self;

}


-(void)loadElevatorList{
     
        
        self.elevatorList = [[NSMutableArray alloc] init];
        CGSize s = [self.bgTile.elevators layerSize];
        for( int x=0; x<s.width;x++) {
            for( int y=0; y< s.height; y++ ) {
                unsigned int tgid = [self.bgTile.elevators tileGIDAt:ccp(x,y)];
                if (tgid){
                    //NSLog(@"tgid %d", tgid);
                     
                    Elevator *elevatorSprite = [[Elevator alloc] init];
                    
                    elevatorSprite.gId = x+y*10;
                     

                    elevatorSprite.initPosition = ccp((x)*self.bgTile.tileMap.tileSize.width,   (20-y-1)*self.bgTile.tileMap.tileSize.height);
                    
                    [self.elevatorList addObject:elevatorSprite];
                    
                    [self.bgTile.elevators removeTileAt:ccp(x,y)];
                    
                }
               
            }
        }
     
}


- (CGPoint)tileCoordForPosition:(CGPoint)position
{
    float x = floor(position.x /self.bgTile.tileMap.tileSize.width);
    float levelHeightInPixels = self.bgTile.tileMap.mapSize.height * self.bgTile.tileMap.tileSize.height;
    float y = floor((levelHeightInPixels - position.y) / self.bgTile.tileMap.tileSize.height);
    return ccp(x, y);
}



-(CGRect)tileRectFromTileCoords:(CGPoint)tileCoords {
    float levelHeightInPixels = self.bgTile.tileMap.mapSize.height * self.bgTile.tileMap.tileSize.height;
    CGPoint origin = ccp(tileCoords.x * self.bgTile.tileMap.tileSize.width, levelHeightInPixels - ((tileCoords.y + 1) * self.bgTile.tileMap.tileSize.height));
    return CGRectMake(origin.x, origin.y, self.bgTile.tileMap.tileSize.width, self.bgTile.tileMap.tileSize.height);
}


+(CCScene *) scene
{
	
	CCScene *scene = [CCScene node];

	IntroLayer *layer = [IntroLayer node];

	[scene addChild: layer];

	return scene;
}

 
 
- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *t in touches) {
        
        CGPoint touchLocation = [self convertTouchToNodeSpace:t];
        
        //get previous touch and convert it to node space
        CGPoint previousTouchLocation = [t previousLocationInView:[t view]];
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        
        //previousTouchLocation = ccp(previousTouchLocation.x, screenSize.height - previousTouchLocation.y);
        
        float previousX = screenSize.width - previousTouchLocation.y;
        float currentX = touchLocation.x;
        
        //NSLog(@"previous: %f touchLocation %f", previousX, touchLocation.x);
        
        if (previousX > 100 && previousX < 400 && currentX <= 100) {
            self.dude.walkLeft = YES;
            self.dude.walkRight = NO;
        }
        else
        if (previousX > 100 && currentX >= 100 && previousX < 400 && currentX <= 400) {
            self.dude.walkLeft = NO;
            self.dude.walkRight = YES;
        }
        
        
        
    }
}


-(void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    
    for (UITouch *t in touches) {
        CGPoint touchLocation = [self convertTouchToNodeSpace:t];
        
        
        if (touchLocation.x < 100) {
            self.dude.walkLeft = YES;
            self.dude.walkRight = NO;
           // NSLog(@"left");
        }else if (touchLocation.x <= 400){
            self.dude.walkRight = YES;
            self.dude.walkLeft = NO;
            //NSLog(@"right");
            
        }
        
        if (touchLocation.x > 900){
            self.dude.mightAsWellJump = YES;
           // NSLog(@"jump");
            
        }
    }
    
}


-(void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    //NSLog(@"touch ended");
    for (UITouch *t in touches) {
        CGPoint touchLocation = [self convertTouchToNodeSpace:t];
        
      
        if (touchLocation.x < 100) {
            self.dude.walkLeft = NO;
            [self.dude bearMoveEnded];
        }else if (touchLocation.x <= 400){
            self.dude.walkRight = NO;
            [self.dude bearMoveEnded];
        }else if (touchLocation.x > 900){
            self.dude.mightAsWellJump = NO;
        } 

    }
}

-(NSArray *)getSurroundingTilesAtPosition:(CGPoint)position forLayer:(CCTMXLayer *)layer {
    
    CGPoint plPos = [self tileCoordForPosition:position]; //1
    
    NSMutableArray *gids = [NSMutableArray array]; //2
    
    for (int i = 0; i < 9; i++) { //3
        int c = i % 3;
        int r = (int)(i / 3);
        CGPoint tilePos = ccp(plPos.x + (c - 1), plPos.y + (r - 1));
        
        if (tilePos.y > (self.bgTile.tileMap.mapSize.height - 1)) {
            //fallen in a hole
            return nil;
        }
        
        int tgid = [layer tileGIDAt:tilePos]; //4
        
        CGRect tileRect = [self tileRectFromTileCoords:tilePos]; //5
        
        NSDictionary *tileDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithInt:tgid], @"gid",
                                  [NSNumber numberWithFloat:tileRect.origin.x], @"x",
                                  [NSNumber numberWithFloat:tileRect.origin.y], @"y",
                                  [NSValue valueWithCGPoint:tilePos],@"tilePos",
                                  nil];
        [gids addObject:tileDict]; //6
        
    }
    
    [gids removeObjectAtIndex:4]; //7
    [gids insertObject:[gids objectAtIndex:2] atIndex:6];
    [gids removeObjectAtIndex:2];
    [gids exchangeObjectAtIndex:4 withObjectAtIndex:6];
    [gids exchangeObjectAtIndex:0 withObjectAtIndex:4];
    
    return (NSArray *)gids;
}



-(void)checkForAndResolveCollisions:(Enemy *)p {
    
    
    NSArray *tiles = [self getSurroundingTilesAtPosition:p.position forLayer:self.bgTile.walls]; //1
    
    p.onGround = NO;
    
    for (NSDictionary *dic in tiles) {
        CGRect pRect = [p collisionBoundingBox]; //3
        
        int gid = [[dic objectForKey:@"gid"] intValue]; //4
        
        if (gid) {
            CGRect tileRect = CGRectMake([[dic objectForKey:@"x"] floatValue], [[dic objectForKey:@"y"] floatValue], self.bgTile.tileMap.tileSize.width, self.bgTile.tileMap.tileSize.height); //5
            
            if (CGRectIntersectsRect(pRect, tileRect)) {
                CGRect intersection = CGRectIntersection(pRect, tileRect);
                int tileIndx = [tiles indexOfObject:dic];
                
                if (tileIndx == 0) {
                    //tile is directly below player
                    p.desiredPosition = ccp(p.desiredPosition.x, p.desiredPosition.y + intersection.size.height);
                    p.velocity = ccp(p.velocity.x, 0.0);
                    p.onGround = YES;
                } else if (tileIndx == 1) {
                    //tile is directly above player
                    p.desiredPosition = ccp(p.desiredPosition.x, p.position.y - intersection.size.height);
                    p.velocity = ccp(p.velocity.x, 0.0);
                } else if (tileIndx == 2) {
                    //tile is left of player
                    p.desiredPosition = ccp(p.desiredPosition.x + intersection.size.width, p.desiredPosition.y);
                    p.walkLeft = NO;
                    p.walkRight = YES;
                } else if (tileIndx == 3) {
                    //tile is right of player
                    p.desiredPosition = ccp(p.desiredPosition.x - intersection.size.width, p.desiredPosition.y);
                    p.walkLeft = YES;
                    p.walkRight = NO;
                }
        
            }
        }
    }
    
    p.position =   p.desiredPosition ;
}

-(void) characterDie:(int) dieCause{
    [self.dude.bear runAction:[CCFadeOut actionWithDuration:0.3]];
    self.dude.bear.position = ccp(100,500);
    [self.dude.bear runAction:[CCFadeIn actionWithDuration:0.5]];

}


-(void) checkForFruits:(Character *)p{
    NSArray *tiles = [self getSurroundingTilesAtPosition:p.bear.position forLayer:self.bgTile.fruits];
    for (NSDictionary *dic in tiles) {
        
        CGRect tileRect = CGRectMake([[dic objectForKey:@"x"] floatValue], [[dic objectForKey:@"y"] floatValue], self.bgTile.tileMap.tileSize.width, self.bgTile.tileMap.tileSize.height);
        
        CGRect pRect = [p collisionBoundingBox];
        
        if ([[dic objectForKey:@"gid"] intValue] && CGRectIntersectsRect(pRect, tileRect)) {
            NSLog(@"Got Fruit");
            [self.bgTile.fruits removeTileAt:[[dic objectForKey:@"tilePos"] CGPointValue]];
        }
        
    }
}


-(void) checkForHazards:(Character *)p{
    NSArray *tiles = [self getSurroundingTilesAtPosition:p.bear.position forLayer:self.bgTile.hazards];
    for (NSDictionary *dic in tiles) {
        
        CGRect tileRect = CGRectMake([[dic objectForKey:@"x"] floatValue], [[dic objectForKey:@"y"] floatValue], self.bgTile.tileMap.tileSize.width, self.bgTile.tileMap.tileSize.height);
        
        CGRect pRect = [p collisionBoundingBox];
        
        if ([[dic objectForKey:@"gid"] intValue] && CGRectIntersectsRect(pRect, tileRect)) {
            [self characterDie:0];
        }
        
    }
}


-(void)checkForAndResolveCollisions2:(Character *)p {
    
    
    NSArray *tiles = [self getSurroundingTilesAtPosition:p.bear.position forLayer:self.bgTile.walls]; 
     
     
    p.onGround = NO;
    
    for (NSDictionary *dic in tiles) {
        CGRect pRect = [p collisionBoundingBox]; //3
        
        int gid = [[dic objectForKey:@"gid"] intValue]; //4
         
        if (gid) {
            CGRect tileRect = CGRectMake([[dic objectForKey:@"x"] floatValue], [[dic objectForKey:@"y"] floatValue], self.bgTile.tileMap.tileSize.width, self.bgTile.tileMap.tileSize.height); //5
           
             
            
            if (CGRectIntersectsRect(pRect, tileRect)) {
                CGRect intersection = CGRectIntersection(pRect, tileRect);
                int tileIndx = [tiles indexOfObject:dic];
                
                if (tileIndx == 0) {
                    //tile is directly below player
                    p.desiredPosition = ccp(p.desiredPosition.x, p.desiredPosition.y + intersection.size.height);
                    p.velocity = ccp(p.velocity.x, 0.0);
                    p.onGround = YES;
                } else if (tileIndx == 1) {
                    //tile is directly above player
                    p.desiredPosition = ccp(p.desiredPosition.x, p.bear.position.y - intersection.size.height);
                    p.velocity = ccp(p.velocity.x, 0.0);
                } else if (tileIndx == 2) {
                    //tile is left of player
                    p.desiredPosition = ccp(p.desiredPosition.x + intersection.size.width, p.desiredPosition.y);
                } else if (tileIndx == 3) {
                    //tile is right of player
                    p.desiredPosition = ccp(p.desiredPosition.x - intersection.size.width, p.desiredPosition.y);
                }
                /*
                else {
                    if (intersection.size.width > intersection.size.height) {
                        //tile is diagonal, but resolving collision vertially
                        p.velocity = ccp(p.velocity.x, 0.0);
                        float resolutionHeight;
                        if (tileIndx > 5) {
                            resolutionHeight = -intersection.size.height;
                            p.onGround = YES;
                        } else {
                            resolutionHeight = intersection.size.height;
                        }
                        
                        p.desiredPosition = ccp(p.desiredPosition.x, p.desiredPosition.y + resolutionHeight );
                        
                    } else {
                        float resolutionWidth;
                        if (tileIndx == 6 || tileIndx == 4) {
                            resolutionWidth = intersection.size.width;
                        } else {
                            resolutionWidth = -intersection.size.width;
                        }
                        p.desiredPosition = ccp(p.desiredPosition.x + resolutionWidth , p.desiredPosition.y);
                        
                    }
                }
                 */
            }
        }
    }
    
    p.bear.position =   p.desiredPosition ;
}
 
 

-(void) moving:(ccTime)dt{
    
    [self.dude update:dt];
    [self.enemy update:dt];
    [self moveElevators];
    
    self.dude.bear.position = self.dude.desiredPosition;
    
    [self checkForAndResolveCollisions2:self.dude];
    [self checkForAndResolveCollisions:self.enemy];
    [self checkForCollisionsWithMovingObjects:self.dude];
    
    [self checkForHazards:self.dude];
    [self checkForFruits:self.dude];
    
    
    //[self setViewpointCenter: self.dude.bear.position];
}

-(void)setViewpointCenter:(CGPoint) position {
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    int x = MAX(position.x, winSize.width / 2);
    int y = MAX(position.y, winSize.height / 2);
    x = MIN(x, (self.bgTile.tileMap.mapSize.width * self.bgTile.tileMap.tileSize.width)
            - winSize.width / 2);
    y = MIN(y, (self.bgTile.tileMap.mapSize.height * self.bgTile.tileMap.tileSize.height)
            - winSize.height/2);
    CGPoint actualPosition = ccp(x, y);
    
    CGPoint centerOfView = ccp(winSize.width/2, winSize.height/2);
    CGPoint viewPoint = ccpSub(centerOfView, actualPosition);
    self.bgTile.tileMap.position = viewPoint;
}

-(void) checkForCollisionsWithMovingObjects:(Character *)character{
    for (Elevator *elevator in self.elevatorList) {
        CCSprite *sprite = (CCSprite *)[self.bgTile getChildByTag:elevator.gId];
        
        
        if ( CGRectIntersectsRect([sprite boundingBox], [self.dude collisionBoundingBox])) {
             character.onGround = YES;
            if ((character.desiredPosition.y >= sprite.position.y + [sprite boundingBox].size.height)&&(character.onGround)) {
                CGPoint charPosition = character.desiredPosition;
                //NSLog(@"char y %f elevator y %f", charPosition.y, sprite.position.y+[sprite boundingBox].size.height);
                charPosition.y = sprite.position.y + [sprite boundingBox].size.height + 10;
                character.desiredPosition = charPosition;
                character.bear.position = character.desiredPosition;
               
            }
        }
    }
}

-(void) moveElevators{
    for (Elevator *elevator in self.elevatorList) {
        CCSprite *sprite = (CCSprite *)[self.bgTile getChildByTag:elevator.gId];
        CGPoint spritePosition = sprite.position;
        
        if (elevator.movingUp) {
            if (spritePosition.y == elevator.initPosition.y) {
                elevator.movingUp = NO;
            }
            else{
                spritePosition.y +=1;
            }
        }else{
            
            if (spritePosition.y == elevator.initPosition.y - 100) {
                elevator.movingUp = YES;
            }else{
                spritePosition.y -=1;
            }
            
        }
        sprite.position  = spritePosition;
    }
}


-(void) initElevators{
    [self loadElevatorList];
    for (Elevator *elevator in self.elevatorList) {
        CCSprite *sprite = [CCSprite spriteWithFile:@"elevator.png"];
        
        sprite.tag = elevator.gId;
        [self.bgTile addChild:sprite];
        sprite.anchorPoint = ccp(0, 0);
        sprite.position = elevator.initPosition;
        
    }
}

-(void) onEnter
{
	[super onEnter];
    
    
    
    
    self.bgTile = [TileMap node];
    self.bgTile.position = ccp(0, 0);
    [self addChild:self.bgTile];
    
    self.dude = [Character node];
    [self.bgTile addChild:self.dude z:15];
    
    
    self.enemy = [[Enemy alloc] initWithFile:@"red.png"];
    [self.bgTile addChild:self.enemy];
    self.enemy.position = ccp(140,550);
    self.enemy.walkLeft = YES;
    
    [self initElevators];
    [self moveElevators];
     
}


@end
