//
//  Character.h
//  PlatformA
//
//  Created by Roberto Breve on 12/23/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
@class Item;

@interface Character : CCLayer {
   
    
}
+(id) scene;

@property (nonatomic, retain) CCSprite *bear;
@property (nonatomic, retain) CCAction *walkAction;

@property (nonatomic, assign) CGPoint velocity;

@property (nonatomic, assign) BOOL moving;
@property (nonatomic, assign) BOOL walkLeft;
@property (nonatomic, assign) BOOL walkRight;
@property (nonatomic, assign) BOOL onGround;
@property (nonatomic, assign) BOOL onLeftWall;
@property (nonatomic, assign) BOOL onRightWall;

@property (nonatomic, assign) BOOL movesAlone;

@property (nonatomic, assign) BOOL mightAsWellJump;

@property (nonatomic, assign) CGPoint desiredPosition;

@property (nonatomic, strong) CCSprite *holdItem;

@property (nonatomic, assign) int walkSpeed;

 

-(void)bearMoveEnded ;
-(void)update:(ccTime)dt;

-(CGRect)collisionBoundingBox;

-(id) initWithSpriteList:(NSString *) plistFilename pngFilename:(NSString *) pngFilename spriteNames:(NSString *) spriteName frameNumber:(int) frameNumber;
-(id) initWithSprite:(NSString *) spriteFilename;

-(void) scaleWhenDies;

-(void) holdsItem:(Item *) item;
@end
