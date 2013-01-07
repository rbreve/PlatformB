//
//  Elevator.m
//  PlatformB
//
//  Created by Roberto Breve on 1/2/13.
//
//

#import "Elevator.h"
#import "cocos2d.h"

@implementation Elevator

-(void)update:(ccTime)dt{

    
    CGPoint pos = self.desiredPosition;
    
     
        pos.y-=1;
   
    
    self.desiredPosition=pos;
    
 }


-(CGRect) collisionBoundingBox{
    CGRect collisionBox = CGRectInset(self.sprite.boundingBox, 0, 0);
    CGPoint diff = ccpSub(self.desiredPosition, self.position);
    CGRect returnBoundingBox = CGRectOffset(collisionBox, diff.x, diff.y);
    return returnBoundingBox;
}

-(void) setInitPosition:(CGPoint)initPosition{
    _initPosition = initPosition;
    _desiredPosition = initPosition;
}

-(id) init{
    if( (self=[super init]) ) {

        self.velocity = ccp(0.0, 0.0);

    }
    return self;
}

@end
