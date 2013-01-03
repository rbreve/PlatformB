//
//  Enemy.m
//  PlatformB
//
//  Created by Roberto Breve on 1/1/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "Enemy.h"


@implementation Enemy

@synthesize moving = _moving, onGround = _onGround, mightAsWellJump = _mightAsWellJump, walkLeft = _walkLeft, walkRight = _walkRight, desiredPosition = _desiredPosition, velocity = _velocity, walkAction = _walkAction;


-(id)initWithFile:(NSString *)filename {
    if (self = [super initWithFile:filename]) {
        self.velocity = ccp(0.0, 0.0);
    }
    return self;
}

-(void)update:(ccTime)dt{
    CGPoint jumpForce = ccp(0.0, 450.0);
    float jumpCutoff = 150.0;
    if (self.mightAsWellJump && self.onGround) {
        self.velocity = ccpAdd(self.velocity, jumpForce);
        //[[SimpleAudioEngine sharedEngine] playEffect:@"jump.wav"];
    } else if (!self.mightAsWellJump && self.velocity.y > jumpCutoff) {
        self.velocity = ccp(self.velocity.x, jumpCutoff);
    }
    
    
    CGPoint gravity = ccp(0.0, -450.0);
    CGPoint gravityStep = ccpMult(gravity, dt);
    
    CGPoint forwardMove = ccp(400.0, 0.0);
    CGPoint forwardStep = ccpMult(forwardMove, dt); //1
    
    
    CGPoint backwardMove = ccp(-400.0, 0.0);
    CGPoint backwardStep = ccpMult(backwardMove, dt); //1
    
    self.velocity = ccp(self.velocity.x * 0.90, self.velocity.y); //2
    
    if (self.walkRight) {
        self.velocity = ccpAdd(self.velocity, forwardStep);
        self.flipX = YES;
        
    }
    else if (self.walkLeft) {
        self.flipX = NO;
        self.velocity = ccpAdd(self.velocity, backwardStep);
         
    }
    
    CGPoint minMovement = ccp(-120.0, -450.0);
    CGPoint maxMovement = ccp(120.0, 250.0);
    
    self.velocity = ccpClamp(self.velocity, minMovement, maxMovement); //4
    self.velocity = ccpAdd(self.velocity, gravityStep);
    
    
    CGPoint stepVelocity = ccpMult(self.velocity, dt);
    
    self.desiredPosition = ccpAdd(self.position, stepVelocity);
    
    if (self.desiredPosition.y < 10) {
        self.desiredPosition = ccp(self.desiredPosition.x, 10);
        self.onGround = YES;
    }
    
}

-(CGRect)collisionBoundingBox {
    
    CGRect collisionBox = CGRectInset(self.boundingBox, 3, 0);
    //collisionBox = CGRectOffset(collisionBox, 0, -2);
    CGPoint diff = ccpSub(self.desiredPosition, self.position);
    CGRect returnBoundingBox = CGRectOffset(collisionBox, diff.x, diff.y);
    // NSLog(@"%f %f", returnBoundingBox.origin.x, returnBoundingBox.origin.y);
    
    return returnBoundingBox;
    
}

@end
