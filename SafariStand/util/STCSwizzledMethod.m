//
//  STCSwizzledMethod.m
//  SafariStand
//
//  Created by Ivan Faiustov on 17/10/16.
//
//

#import "STCSwizzledMethod.h"
#import "STCSwizzleProxy.h"

@interface STCSwizzledMethod()

@property (nonatomic) BOOL swizzlingApplied;

@end

@implementation STCSwizzledMethod

- (instancetype)initWithProxy:(STCSwizzleProxy *)proxy selector:(SEL)selector classMethod:(BOOL)classMethod {
    self = [super initWithSEL:selector classMethod:classMethod];
    
    if (self) {
        _proxy = proxy;
    }
    
    return self;
}

@end
