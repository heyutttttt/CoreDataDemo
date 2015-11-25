//
//  Father.m
//  CoreDataDemo
//
//  Created by RYAN on 15/11/21.
//  Copyright © 2015年 ryan. All rights reserved.
//

#import "Father.h"

@implementation Father

- (id)init{
    if (self = [super init]) {
        NSString *name = @"Father's name";
        _name = [name copy];
        self.age = 20;
    }
    
    return self;
}

- (void)sayHello{
    NSLog(@"%@ says hello to you!", _name);
}

- (void)sayGoodbay{
    NSLog(@"%@ says goodbya to you!", _name);
}

- (NSString *)description{
    return [NSString stringWithFormat:@"name:%@, age:%d", _name, self.age];
}
@end
