//
//  Inventory.h
//  PlatformB
//
//  Created by Roberto Breve on 1/6/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class Item;

@interface Inventory : CCLayer {
    
}

@property (nonatomic, strong) NSMutableArray *items;

-(void) addItem:(Item *) item;


@end
