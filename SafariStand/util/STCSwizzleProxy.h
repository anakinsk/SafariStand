//
//  STCSwizzleProzy.h
//  SafariStand
//
//  Created by Ivan Faiustov on 17/10/16.
//
//

#import "STCProxy.h"
#import "STCSwizzledMethod.h"

@interface STCSwizzleProxy : STCProxy

@property (nonatomic, readonly) NSArray<STCSwizzledMethod *> *swizzledMethods;

+ (instancetype)instance;
+ (instancetype)originalWithInstance:(id)instance;

- (void)applySwizzling;

@end
