//
//  STCSwizzleProzy.m
//  SafariStand
//
//  Created by Ivan Faiustov on 17/10/16.
//
//

#import "STCSwizzleProxy.h"
#import "STCSwizzleCore.h"
#import "STCOriginalSwizzleProxy.h"

@interface STCSwizzleProxy()

@property (nonatomic) BOOL swizzlingApplied;
@property (nonatomic) NSArray<STCSwizzledMethod *> *swizzledMethods;

@end

@implementation STCSwizzleProxy

static NSMutableDictionary * _sharedInsances = nil;
static dispatch_semaphore_t _semaphore = nil;

+ (instancetype)instance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInsances = [NSMutableDictionary dictionary];
        _semaphore = dispatch_semaphore_create(1);
    });
    
    __block id object = nil;
    
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *key = NSStringFromClass([self class]);
        
        object = [_sharedInsances objectForKey:key];
        if (!object) {
            object = [[super alloc] init];
            [_sharedInsances setObject:object forKey:key];
        }
        
        dispatch_semaphore_signal(_semaphore);
    });
    
    return object;
}

+ (instancetype)alloc {
    return [self instance];
}

- (void)applySwizzling {
    if (self.swizzlingApplied) {
        return;
    }
    
    for (STCSwizzledMethod *method in self.swizzledMethods) {
        [STCSwizzleCore applySwizzlingWithMethod:method];
    }
    
    self.swizzlingApplied = YES;
}

+ (instancetype)originalWithInstance:(id)instance {
    STCOriginalSwizzleProxy *originalProxy = [STCOriginalSwizzleProxy proxyForInstance:instance];
    
    return (STCSwizzleProxy *)originalProxy;
}

@end
