//
//  Item.h
//  PlatformB
//
//  Created by Roberto Breve on 1/6/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Item : CCSprite {
    
}

@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) int itemType;

@end
