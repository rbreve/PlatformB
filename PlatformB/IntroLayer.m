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

#import "Inventory.h"
#import "Item.h"

#define FILENAME_KEY @"key.png"
#define FILENAME_FRUIT @"fruit.png"
#define FILENAME_COIN @"coin.png"

#pragma mark - IntroLayer

@interface IntroLayer()
@property (nonatomic, retain) NSMutableArray *elevators;
@property (nonatomic, retain) NSMutableArray *coins;

@property (nonatomic, retain) NSMutableArray *elevatorList;
@property (nonatomic, retain) NSMutableArray *movableBlocks;

@property (nonatomic, retain) NSMutableArray *items;

@property (nonatomic, strong) NSMutableArray *enemies;

@property (nonatomic, strong) Inventory *inventory;

 

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


-(NSMutableArray *)loadTilesFromLayer:(CCTMXLayer *) layer type:(int) type {
     
        
        NSMutableArray *tiles = [[NSMutableArray alloc] init];
        CGSize s = [self.bgTile.elevators layerSize];
        for( int x=0; x<s.width;x++) {
            for( int y=0; y< s.height; y++ ) {
                unsigned int tgid = [layer tileGIDAt:ccp(x,y)];
                if (tgid){
                     
                    Elevator *elevatorSprite = [[Elevator alloc] init];
                    
                    elevatorSprite.type = type;
                    elevatorSprite.gId = x+y*10;
                     

                    elevatorSprite.initPosition = ccp((x)*self.bgTile.tileMap.tileSize.width,   (self.bgTile.tileMap.mapSize.height-y-1)*self.bgTile.tileMap.tileSize.height);
                    
                    
                    if (![tiles containsObject:elevatorSprite]) {

                        [tiles addObject:elevatorSprite];
                    }
                    
                    [layer removeTileAt:ccp(x,y)];
                    
                }
               
            }
        }
    return tiles;
     
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

#pragma mark Touch Detection
 
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

#pragma mark Tiles

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

#pragma mark Collisions


-(void) checkForEnemiesCollisions:(NSMutableArray *) enemies{
    
    for (Character *enemy in enemies){
        
        [self checkForAndResolveCollisions2:enemy];
        
    }
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
                }else{
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
        
            }
        }
    }
    
    p.position =   p.desiredPosition ;
}

-(void) characterDie:(int) dieCause{
    [self.dude.bear runAction:[CCFadeOut actionWithDuration:0.3]];
    self.dude.bear.position = ccp(100,620);
    [self.dude.bear runAction:[CCFadeIn actionWithDuration:0.5]];

}


-(void) checkForItems:(Character *)p inLayer:(CCTMXLayer *) layer spriteFilename:(NSString *) spriteFilename{
    NSArray *tiles = [self getSurroundingTilesAtPosition:p.bear.position forLayer:layer];
    for (NSDictionary *dic in tiles) {
        
        CGRect tileRect = CGRectMake([[dic objectForKey:@"x"] floatValue], [[dic objectForKey:@"y"] floatValue], self.bgTile.tileMap.tileSize.width, self.bgTile.tileMap.tileSize.height);
        
        CGRect pRect = [p collisionBoundingBox];
        
        if ([[dic objectForKey:@"gid"] intValue] && CGRectIntersectsRect(pRect, tileRect)) {
            
            Item *item = [Item spriteWithFile:spriteFilename];
            
            
            item.name = @"Apple";
            [self.inventory addItem:item];
            
            [layer removeTileAt:[[dic objectForKey:@"tilePos"] CGPointValue]];
        }
        
    }
}

//should remove this
-(void) checkForFruits:(Character *)p{
    NSArray *tiles = [self getSurroundingTilesAtPosition:p.bear.position forLayer:self.bgTile.fruits];
    for (NSDictionary *dic in tiles) {
        
        CGRect tileRect = CGRectMake([[dic objectForKey:@"x"] floatValue], [[dic objectForKey:@"y"] floatValue], self.bgTile.tileMap.tileSize.width, self.bgTile.tileMap.tileSize.height);
        
        CGRect pRect = [p collisionBoundingBox];
        
        if ([[dic objectForKey:@"gid"] intValue] && CGRectIntersectsRect(pRect, tileRect)) {
             
            Item *fruit = [Item spriteWithFile:@"I_C_Apple.png"];
            
            
            fruit.name = @"Apple";
            [self.inventory addItem:fruit];
            
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

-(void) checkForMovableObjectCollisions:(NSMutableArray *) objects{
    
    
    for (Elevator *elevator in objects) {
        
        CCSprite *sprite = (CCSprite *)[self.bgTile getChildByTag:elevator.gId];
        elevator.position = sprite.position;
        elevator.sprite = sprite;
        
        CGPoint spritePos = elevator.desiredPosition;
        spritePos.y -= [sprite boundingBox].size.height;
        
     
        NSArray *tiles = [self getSurroundingTilesAtPosition:spritePos forLayer:self.bgTile.walls];
        
        
        //NSLog(@"count tiles %d", [tiles count]);
        
        CGRect pRect = CGRectMake(sprite.position.x, sprite.position.y, [sprite boundingBox].size.width, [sprite boundingBox].size.height);
        
        
        for (NSDictionary *dic in tiles) {
            
            int gid = [[dic objectForKey:@"gid"] intValue]; 
            
            if (gid) {
                CGRect tileRect = CGRectMake([[dic objectForKey:@"x"] floatValue], [[dic objectForKey:@"y"] floatValue], self.bgTile.tileMap.tileSize.width, self.bgTile.tileMap.tileSize.height);
                
                //NSLog(@"bbox sprite %f %f - %f %f",pRect.origin.x,pRect.origin.y, tileRect.origin.x, tileRect.origin.y);

                
                if (CGRectIntersectsRect(pRect, tileRect)) {
                    

                    
                    CGRect intersection = CGRectIntersection(pRect, tileRect);
                    int tileIndx = [tiles indexOfObject:dic];
                    //NSLog(@"inter bellow %d", tileIndx);

                    if (pRect.origin.y > tileRect.origin.y) {
                        //tile is directly below player
                       // NSLog(@"inter bellow %d", tileIndx);

                        elevator.desiredPosition = ccp(elevator.desiredPosition.x, elevator.desiredPosition.y + 1);
                        
                        elevator.onGround = YES;
                    } 
                    else if (tileIndx == 2) {
                        //tile is left of player
                        elevator.desiredPosition = ccp(elevator.desiredPosition.x + intersection.size.width, elevator.desiredPosition.y);
                    } else if (tileIndx == 3) {
                        //tile is right of player
                        elevator.desiredPosition = ccp(elevator.desiredPosition.x - intersection.size.width, elevator.desiredPosition.y);
                    }
                    
                    
                }
            }

        }
        
        sprite.position = elevator.desiredPosition;


    }
    
}





-(void) scaleWhenDies:(Character *)character{
    id scaleDownAction = [CCEaseInOut actionWithAction:[CCScaleTo actionWithDuration:0.1 scaleX:1 scaleY:0.3] rate:1.0];
    id actionRemoveFromParent = [CCCallBlock actionWithBlock:^{
        [character.bear removeFromParentAndCleanup:YES];
        [self.enemies removeObject:character];
        
    }];

    
    [character.bear runAction:[CCSequence actions: scaleDownAction, actionRemoveFromParent, nil]];
    
}

-(void) checkForCollisionsWithEnemies:(NSMutableArray *) enemies withCharacter:(Character *)character{
    
    for (Character *enemy in enemies){

        if (CGRectIntersectsRect([enemy collisionBoundingBox], [character collisionBoundingBox])) {
             
            CGPoint charPos = character.bear.position;
            CGPoint enemyPos = enemy.bear.position;
   
            if (charPos.y > enemyPos.y+15) {

                
                [self scaleWhenDies:enemy];
                
                character.mightAsWellJump = YES;
                
                
                
            }else{
                if (abs(charPos.x - enemyPos.x) > 10){
                    NSLog(@"dead");
                }
            }
        }
    }
}

-(void) checkForCollisionsWithMovableObjects:(NSMutableArray *) objects withCharacter:(Character *)character{
  
    
    for (Elevator *elevator in objects) {
        CCSprite *sprite = (CCSprite *)[self.bgTile getChildByTag:elevator.gId];
       

        if ( CGRectIntersectsRect([sprite boundingBox], [character collisionBoundingBox])) {
            
            if (elevator.type == itemGoldenKey) {
                //enlazar type con filename mejor
                Item *item = [[Item alloc] initWithFile:@"key.png"];
                item.itemType = itemGoldenKey;
                [self.inventory addItem:item];
                [self.bgTile removeChild:sprite cleanup:YES];
                
                [character holdsItem:item];
                
                return;
            }
            
            if (elevator.type == itemCoin) {
                //enlazar type con filename mejor
                Item *item = [[Item alloc] initWithFile:@"coin.png"];
                item.itemType = itemCoin;
                [self.inventory addItem:item];
                [self.bgTile removeChild:sprite cleanup:YES];
                return;
            }
            
            CGRect intersection = CGRectIntersection([sprite boundingBox], [character collisionBoundingBox]);
            
            character.onGround = YES;
            
            CGPoint charPosition = character.desiredPosition;
            CGPoint spritePosition = sprite.position;
            
            //below
            
            if ((character.desiredPosition.y >= sprite.position.y + [sprite boundingBox].size.height)&&(character.onGround)) {
                
                charPosition.y = character.desiredPosition.y + intersection.size.height;
                //otherwise it will fall hard
                character.velocity = ccp(character.velocity.x, 0);
                
                
                character.desiredPosition = charPosition;
                character.bear.position = character.desiredPosition;
            }
            
            float charHeightOffset = [character.bear boundingBox].size.height / 2;
            
            if ((charPosition.x > spritePosition.x)&&(spritePosition.y+charHeightOffset == charPosition.y)) {
                spritePosition.x -= intersection.size.width;
            }else if ((charPosition.x < spritePosition.x)&&(spritePosition.y+charHeightOffset == charPosition.y)) {
                spritePosition.x += intersection.size.width;
            }
      
            
            if (elevator.type == isMovable){
                elevator.desiredPosition = spritePosition;
            }
            
        }
    }
}


 


-(void)checkForAndResolveCollisions2:(Character *)p {
    NSArray *tiles = [self getSurroundingTilesAtPosition:p.bear.position forLayer:self.bgTile.walls]; 
    
    p.onGround = NO;
    p.onLeftWall = NO;
    p.onRightWall = NO;
    
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
                    
                    //Lava Effect Sinks se unde
                    //p.desiredPosition = ccp(p.desiredPosition.x, p.bear.position.y);
                    
                    p.velocity = ccp(p.velocity.x, 0.0);
                    p.onGround = YES;
                    
                    p.mightAsWellJump = NO;
                    
                } else if (tileIndx == 1) {
                    //tile is directly above player
                    p.desiredPosition = ccp(p.desiredPosition.x, p.bear.position.y - intersection.size.height);
                    p.velocity = ccp(p.velocity.x, -100);
                } else if (tileIndx == 2 || tileIndx == 4 || tileIndx == 6) {
                    //tile is left of player
                    p.desiredPosition = ccp(p.desiredPosition.x + intersection.size.width, p.desiredPosition.y);
                    
                    if (p.movesAlone) {
                        p.walkRight = YES;
                        p.walkLeft = NO;
                    }
                    
                    //p.onLeftWall = YES;
                } else if (tileIndx == 3 || tileIndx==5 || tileIndx == 7)   {
                  
                    p.desiredPosition = ccp(p.desiredPosition.x - intersection.size.width, p.desiredPosition.y);
                    
                    if (p.movesAlone) {
                        p.walkLeft = YES;
                        p.walkRight = NO;
                    }
                }
                
               
            }
        }
    }
    
    p.bear.position =   p.desiredPosition ;
}

#pragma mark Schedulers

-(void) updateElevators:(NSMutableArray *) elevators inTime:(ccTime) dt{
    for (Elevator *elevator in elevators){
        [elevator update:dt];
    }
}

-(void) moving:(ccTime)dt{
    
    [self.dude update:dt];
    
    //enemies
    [self moveEnemies:self.enemies time:dt];
    [self checkForEnemiesCollisions:self.enemies];
 
    //Character with Enemies
    [self checkForCollisionsWithEnemies:self.enemies withCharacter:self.dude];
    
    [self moveElevators:self.elevatorList];
    
    //Character with tiles
    [self checkForAndResolveCollisions2:self.dude];
    
    //character with Elevators
    [self checkForCollisionsWithMovableObjects:self.elevatorList withCharacter:self.dude];
    
    //character with Items
    [self checkForCollisionsWithMovableObjects:self.items withCharacter:self.dude];
    [self checkForCollisionsWithMovableObjects:self.coins withCharacter:self.dude];
    

    //character with hazards
    
    [self checkForHazards:self.dude];
    
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

-(void) moveEnemies:(NSMutableArray *) enemies time:(ccTime )dt{
    for (Character *enemy in enemies){
        [enemy update:dt];
        enemy.bear.position = enemy.desiredPosition;
    }
}

-(void) moveElevators:(NSMutableArray *)elevators{
    for (Elevator *elevator in elevators) {
        
        CCSprite *sprite = (CCSprite *)[self.bgTile getChildByTag:elevator.gId];
        CGPoint spritePosition = sprite.position;
        
        if (elevator.movingUp) {
            if (spritePosition.y >= elevator.initPosition.y) {
                elevator.movingUp = NO;
            }
            else{
                spritePosition.y +=1;
            }
        }else{
            
            if (spritePosition.y <= elevator.initPosition.y - 100) {
                elevator.movingUp = YES;
            }else{
                spritePosition.y -=1;
            }
            
        }
        sprite.position  = spritePosition;
    }
}

#pragma mark Initializer


-(void) addElevatorFromFilename:(NSString *)spriteName  fromTiles:(NSMutableArray *)tiles inLayer:(CCLayer *)layer{
    for (Elevator *elevator in tiles) {
        
        CCSprite *sprite = [CCSprite spriteWithFile:spriteName];
        
        sprite.tag = elevator.gId;
        [layer addChild:sprite];
   
        sprite.anchorPoint = ccp(0, 0);
        
        CGPoint initPosition = elevator.initPosition;
         
        sprite.position = initPosition;
        
    }
}


-(void) initElevators{
   
    self.elevatorList = [self loadTilesFromLayer:self.bgTile.elevators type:isElevator];
    [self addElevatorFromFilename:@"elevator.png" fromTiles:self.elevatorList inLayer:self.bgTile];
    
    self.movableBlocks = [self loadTilesFromLayer:self.bgTile.pushable type:isMovable];
    [self addElevatorFromFilename:@"pushable.png" fromTiles:self.movableBlocks inLayer:self.bgTile];
    
    self.items = [self loadTilesFromLayer:self.bgTile.keys type:itemGoldenKey];
    [self addElevatorFromFilename:FILENAME_KEY fromTiles:self.items inLayer:self.bgTile];
    
    self.coins =  [self loadTilesFromLayer:self.bgTile.coins type:itemCoin];
    [self addElevatorFromFilename:FILENAME_COIN fromTiles:self.coins inLayer:self.bgTile];
    

    
}


-(void) initEnemies{
    self.enemies = [[NSMutableArray alloc] init];
    
    Character *enemy1 = [[Character alloc] initWithSprite:@"red.png"];
    enemy1.bear.position = [self.bgTile getSpawnPointfromObjectNamed:@"EnemySpawn"];
    [self.bgTile addChild:enemy1 z:1000];
    enemy1.walkRight = YES;
    enemy1.movesAlone = YES;
    
    Character *enemy2 = [[Character alloc] initWithSprite:@"red.png"];
    enemy2.bear.position =  [self.bgTile getSpawnPointfromObjectNamed:@"EnemySpawn2"];

    [self.bgTile addChild:enemy2 z:1000];
    enemy2.walkRight = YES;
    enemy2.movesAlone = YES;


    [self.enemies addObject:enemy1];
    [self.enemies addObject:enemy2];
    
    
}

#pragma mark Enter 

-(void) onEnter
{
	[super onEnter];
    
    //TODO hacer tilemap init with filename
    //CGSize size = [[CCDirector sharedDirector] winSize];
    
    CCSprite *sky = [CCSprite spriteWithFile:@"sky.png"];
    sky.position = ccp(200,470);
    [self addChild:sky];
    
    
    self.bgTile = [TileMap node];

    [self addChild:self.bgTile];
    self.bgTile.position = ccp(0, -200);
    
    self.dude = [[Character alloc] initWithSpriteList:@"walkgirl.plist" pngFilename:@"walkgirl.png" spriteNames:@"w" frameNumber:3];
    self.dude.bear.position = [self.bgTile getSpawnPointfromObjectNamed:@"PlayerSpawn"];
    
    [self.bgTile addChild:self.dude z:15];
     
     
    self.inventory  = [[Inventory alloc] init];
    self.inventory.position = ccp(1000, 15);
    [self addChild:self.inventory];
    
    [self initEnemies];
    [self initElevators];
        
}





@end
