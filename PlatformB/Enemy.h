//
//  Enemy.h
//  PlatformB
//
//  Created by Roberto Breve on 1/1/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Enemy : CCSprite {
    
}

-(void)update:(ccTime)dt;

-(CGRect)collisionBoundingBox;

@property (nonatomic, retain) CCAction *walkAction;

@property (nonatomic, assign) CGPoint desiredPosition;
@property (nonatomic, assign) CGPoint velocity;
@property (nonatomic, assign) BOOL mightAsWellJump;
@property (nonatomic, assign) BOOL moving;
@property (nonatomic, assign) BOOL walkLeft;
@property (nonatomic, assign) BOOL walkRight;
@property (nonatomic, assign) BOOL onGround;


@end
