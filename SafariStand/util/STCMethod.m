//
//  STCMethod.m
//  SafariStand
//
//  Created by Ivan Faiustov on 18/10/16.
//
//

#import "STCMethod.h"

@implementation STCMethod

- (instancetype)initWithSEL:(SEL)sel classMethod:(BOOL)classMethod {
    self = [super init];
    
    if (self) {
        _selector = sel;
        _classMethod = classMethod;
    }
    
    return self;
}

@end
