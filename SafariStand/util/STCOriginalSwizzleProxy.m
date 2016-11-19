//
//  STCOriginalSwizzleProxy.m
//  SafariStand
//
//  Created by Ivan Faiustov on 18/10/16.
//
//

#import "STCOriginalSwizzleProxy.h"
#import "STCSwizzleCore.h"

@interface STCOriginalSwizzleProxy ()

@property (nonatomic) id instance;

@end


@implementation STCOriginalSwizzleProxy

- (instancetype)initWithInstance:(id)instance {
    _instance = instance;
    
    return self;
}

+ (instancetype)proxyForInstance:(id)instance {
    STCOriginalSwizzleProxy *proxy = [[STCOriginalSwizzleProxy alloc] initWithInstance:instance];
    
    return proxy;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    return [self.instance methodSignatureForSelector:sel];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    SEL selector = invocation.selector;
    SEL swizzledSel = [STCSwizzleCore swizzledSelectorFromSelector:selector];
    
    invocation.selector = swizzledSel;
    
    [invocation invokeWithTarget:self.instance];
}

@end
