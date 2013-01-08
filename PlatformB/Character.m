
#import "Character.h"


@implementation Character
@synthesize bear = _bear, moving = _moving, onGround = _onGround, mightAsWellJump = _mightAsWellJump, walkLeft = _walkLeft, walkRight = _walkRight, desiredPosition = _desiredPosition, velocity = _velocity, walkAction = _walkAction;
 
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
    
    CGPoint forwardMove = ccp(900.0, 0.0);
    CGPoint forwardStep = ccpMult(forwardMove, dt); //1
    
    
    CGPoint backwardMove = ccp(-900.0, 0.0);
    CGPoint backwardStep = ccpMult(backwardMove, dt); //1
    
    self.velocity = ccp(self.velocity.x * 0.90, self.velocity.y); //2
    
    if (self.walkRight) {
        self.velocity = ccpAdd(self.velocity, forwardStep);
        self.bear.flipX = NO;
        if (!self.moving) {
            [_bear runAction:self.walkAction];
            self.moving = YES;
        }
    }
    else if (self.walkLeft) {
        self.bear.flipX = YES;
        self.velocity = ccpAdd(self.velocity, backwardStep);
        if (!self.moving) {
            [_bear runAction:self.walkAction];
            self.moving = YES;

        }
    }
     
    CGPoint minMovement = ccp(-120.0, -450.0);
    CGPoint maxMovement = ccp(120.0, 250.0);
    
    self.velocity = ccpClamp(self.velocity, minMovement, maxMovement); //4
    self.velocity = ccpAdd(self.velocity, gravityStep);
      
    
    CGPoint stepVelocity = ccpMult(self.velocity, dt);
    
    self.desiredPosition = ccpAdd(self.bear.position, stepVelocity);
   
 
    
}
  
-(id) initWithSpriteList:(NSString *) plistFilename pngFilename:(NSString *) pngFilename spriteNames:(NSString *) spriteName{
    if( (self=[super init]) ) {
        
        self.velocity = ccp(0.0, 0.0);
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:plistFilename];
        CCSpriteBatchNode *spriteSheet = [CCSpriteBatchNode batchNodeWithFile:pngFilename];
        [self addChild:spriteSheet z:100 tag:4];
        
        //spriteName = @"LRUN_000";
        
        // Load up the frames of our animation
        NSMutableArray *walkAnimFrames = [NSMutableArray array];
        NSString* z=@"";
        
        for(int i = 0; i <= 5; ++i) {
            z= i < 10 ? @"0" : @"";
            
            [walkAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@%@%d.png",spriteName,z, i]]];
        }
        
        CCAnimation *walkAnim =  [CCAnimation animationWithFrames:walkAnimFrames delay:0.04f];
        
        // Create a sprite for our bear
        self.bear = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%@00.png", spriteName]];
        self.bear.scale = 0.5;
        
        
        
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
