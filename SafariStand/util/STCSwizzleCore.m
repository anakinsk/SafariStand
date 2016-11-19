//
//  STCSwizzleCore.m
//  SafariStand
//
//  Created by Ivan Faiustov on 17/10/16.
//
//

#import "STCSwizzleCore.h"
#import "STCSwizzledMethod.h"
#import "STCSwizzleProxy.h"
#import "STCClass.h"

NSString *const SWIZZLE_ID = @"XXXAAASSSRVWEIJVJWVWCBEUWCHW_";

@implementation STCSwizzleCore

// Here we apply a bit tricky non standard swizzling where a swizzled method is a part of a proxy class, but the original still has to be a part of the original class to work correctly
+ (void)applySwizzlingWithMethod:(STCSwizzledMethod *)method {
    STCClass *originalClass = [STCClass classWithObjcClassName:method.proxy.proxiedClassName isMetaClass:method.classMethod];
    STCClass *proxyClass = [STCClass classWithObjcClassName:method.proxy.className isMetaClass:NO];
    
    Method originalMethod = [originalClass objcMethodForSelector:method.selector];
    Method swizzledMethod = [proxyClass objcMethodForSelector:method.selector];
    NSCParameterAssert(originalMethod);
    NSCParameterAssert(swizzledMethod);
    
    // What happens here is that we wanna be able to call the original implementation of the method, where the swizzled method has to be a part of our proxy, but the original has to be a part of the original class for eveyrthing to work correctly. So here we add a new method to the original class with known signature, then apply swizzling to swap methods implementation. We also add prefix to the added method so our proxy will know how to resolve this so you can call the original implementation at any time later on :)
    IMP swizzledMethodIMP = method_getImplementation(swizzledMethod);
    const char *types = method_getTypeEncoding(swizzledMethod);
    SEL newSEL = NSSelectorFromString([NSString stringWithFormat:@"%@%@", SWIZZLE_ID, NSStringFromSelector(method.selector)]);
    
    Method newMethod = [originalClass addMethodWithSel:newSEL imp:swizzledMethodIMP andSignature:types];
    
    method_exchangeImplementations(originalMethod, newMethod);
}

+ (SEL)swizzledSelectorFromSelector:(SEL)originalSel {
    SEL newSel = NSSelectorFromString([NSString stringWithFormat:@"%@%@", SWIZZLE_ID, NSStringFromSelector(originalSel)]);
    
    return newSel;
}

@end
