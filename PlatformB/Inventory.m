//
//  Inventory.m
//  PlatformB
//
//  Created by Roberto Breve on 1/6/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "Inventory.h"
#import "Item.h"

@interface Inventory()
@property (nonatomic, assign) NSInteger slotCount;
@end

@implementation Inventory


-(NSMutableArray *) items{
    if (_items == nil) {
        _items = [[NSMutableArray alloc] init];
    }
    return _items;
}

-(NSInteger) countOcurrencesOfItem:(Item *) item{
    NSInteger count=0;
    for (Item *i in self.items) {
        if (item.itemType == i.itemType) {
            count++;
        }
    }
    return count;
}


-(void) addItem:(Item *) item{
    
    NSInteger ocurrences = [self countOcurrencesOfItem:item];
    [self.items addObject:item];
    
    if (ocurrences > 0) {
       
        CCLabelTTF *label = (CCLabelTTF *)[self getChildByTag:item.itemType];
        [label setString:[NSString stringWithFormat:@"%d", ocurrences]];
    }else{
        self.slotCount ++;
        CCLabelTTF *label =   [CCLabelTTF labelWithString:@"1" fontName:@"AmericanTypewriter" fontSize:16];
        label.tag = item.itemType;
        [self addChild:item];
        [self addChild:label];
        label.position = ccp(0, 500 - self.slotCount * 45 - 20);
        item.position = ccp(0, 500 - self.slotCount * 45);
    }
  
}

-(id) init{
    if (self = [super init]) {
        
        
    }
    return self;
}

@end
