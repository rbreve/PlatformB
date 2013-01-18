
#import "Character.h"
#import "Item.h"

@interface Character()
@property (nonatomic, assign) BOOL hasAnimation;
@end

@implementation Character
 
+(CCScene *) scene
{
 	CCScene *scene = [CCScene node];
 	Character *layer = [Character node];
 	[scene addChild: layer];
	return scene;
}

-(CGRect) collisionBoundingBox{
    CGRect collisionBox = CGRectInset(self.bear.boundingBox, 0, 0);
    CGPoint diff = ccpSub(self.desiredPosition, self.bear.position);
    CGRect returnBoundingBox = CGRectOffset(collisionBox, diff.x, diff.y);
   // NSLog(@"%f %f", returnBoundingBox.origin.x, returnBoundingBox.origin.y);
    return returnBoundingBox;
}


-(void) holdsItem:(Item *) item{
    CCSprite *k = [CCSprite spriteWithFile:@"key.png"];
    [self addChild:k z:1001 tag:13];
    self.holdItem = k;
}

-(void) dieFinished{
    
}


-(void) scaleWhenDies{
    id scaleDownAction = [CCEaseInOut actionWithAction:[CCScaleTo actionWithDuration:0.1 scaleX:1 scaleY:0.3] rate:1.0];
    id actionRemoveFromParent = [CCCallFuncN actionWithTarget:self selector:@selector(dieFinished)];

    [self.bear runAction:[CCSequence actions: scaleDownAction, actionRemoveFromParent, nil]];

}

-(void)bearMoveEnded {
    //NSLog(@"move ended");
    [self.bear stopAction:self.walkAction];
    self.moving = FALSE;
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
    
    CGPoint forwardMove = ccp(self.walkSpeed, 0.0);
    CGPoint forwardStep = ccpMult(forwardMove, dt); //1
    
    
    CGPoint backwardMove = ccp(-self.walkSpeed, 0.0);
    CGPoint backwardStep = ccpMult(backwardMove, dt); //1
    
    self.velocity = ccp(self.velocity.x * 0.90, self.velocity.y); //2
    
    if (self.walkRight) {
        self.velocity = ccpAdd(self.velocity, forwardStep);
        self.bear.flipX = NO;
        if (!self.moving) {
            if (self.hasAnimation) {
                [_bear runAction:self.walkAction];
            }
            self.moving = YES;
        }
    }
    else if (self.walkLeft) {
        self.bear.flipX = YES;
        self.velocity = ccpAdd(self.velocity, backwardStep);
        if (!self.moving) {
            if (self.hasAnimation) {
                [_bear runAction:self.walkAction];
            }
            self.moving = YES;

        }
    }
    
    
 
    BOOL jumpingFromWall;
    
    if (self.mightAsWellJump && self.onLeftWall && !self.onGround) {
        CGPoint jumpForce = ccp(600.0, 450.0);
        self.velocity = ccpAdd(self.velocity, jumpForce);
        jumpingFromWall = YES;
    }
    else
    if (self.mightAsWellJump && self.onRightWall && !self.onGround) {
        CGPoint jumpForce = ccp(-600.0, 450.0);
        self.velocity = ccpAdd(self.velocity, jumpForce);
        jumpingFromWall = YES;

    }
    
    CGPoint minMovement;
    CGPoint maxMovement;
    
    if (jumpingFromWall) {
        minMovement = ccp(-320.0, -450.0);
        maxMovement = ccp(320.0, 250.0);
    }else{
        minMovement = ccp(-320.0, -450.0);
        maxMovement = ccp(320.0, 250.0);
    }
   
    
    self.velocity = ccpClamp(self.velocity, minMovement, maxMovement); //4
    self.velocity = ccpAdd(self.velocity, gravityStep);
      
    
    CGPoint stepVelocity = ccpMult(self.velocity, dt);
    
    self.desiredPosition = ccpAdd(self.bear.position, stepVelocity);
   
    if (self.holdItem) {
        self.holdItem.flipX = !self.walkRight;
        self.holdItem.position =ccp(self.bear.position.x-self.walkLeft*20+self.walkRight*20, self.bear.position.y);
    }
 
    
}

-(id) initWithSprite:(NSString *) spriteFilename{
    if ((self = [super init])) {
        self.velocity = ccp(0.0, 0.0);

        self.walkSpeed = 400;
        
        self.bear = [CCSprite spriteWithFile:spriteFilename];
        [self addChild:self.bear z:1200];
    }
    return self;

}

-(id) initWithSpriteList:(NSString *) plistFilename pngFilename:(NSString *) pngFilename spriteNames:(NSString *) spriteName frameNumber:(int) frameNumber{
    if( (self=[super init]) ) {
        self.hasAnimation = YES;
        self.walkSpeed = 900;
        
        self.velocity = ccp(0.0, 0.0);
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:plistFilename];
        CCSpriteBatchNode *spriteSheet = [CCSpriteBatchNode batchNodeWithFile:pngFilename];
        [self addChild:spriteSheet z:100 tag:4];
        
        //spriteName = @"LRUN_000";
        
        // Load up the frames of our animation
        NSMutableArray *walkAnimFrames = [NSMutableArray array];
        
        
        for(int i = 0; i <= frameNumber; ++i) {
             [walkAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@%d.png",spriteName, i]]];
        }
        
        CCAnimation *walkAnim =  [CCAnimation animationWithFrames:walkAnimFrames delay:0.04f];
        
        // Create a sprite for our bear
        self.bear = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%@0.png", spriteName]];
         
        
        
        //self.walkAction = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:walkAnim restoreOriginalFrame:NO]];
        
        self.walkAction =         [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:walkAnim]];
        
        [spriteSheet addChild:_bear z:1000 tag:10];
        
    }
    return self;
}



-(void) onEnter
{
    [super onEnter];
}


@end
