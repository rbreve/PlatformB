//
//  Elevator.h
//  PlatformB
//
//  Created by Roberto Breve on 1/2/13.
//
//

#import <Foundation/Foundation.h>
#import "CCSprite.h"

@interface Elevator : NSObject

enum {
    itemGoldenKey = 4,
    isObject = 3,
    isElevator = 2,
	isMovable = 1,
    itemCoin = 5,
};

@property (nonatomic, assign) BOOL movingUp;
@property (nonatomic, assign) CGPoint initPosition;
@property (nonatomic, assign) int gId;
@property (nonatomic, strong) CCSprite *sprite;
@property (nonatomic, assign) int type;
@property (nonatomic, assign) BOOL initYRandom;

@property (nonatomic, assign) CGPoint velocity;
@property (nonatomic, assign) BOOL onGround;
@property (nonatomic, assign) CGPoint desiredPosition;
@property (nonatomic, assign) CGPoint position;


-(void)update:(ccTime)dt;
-(CGRect) collisionBoundingBox;


@end
