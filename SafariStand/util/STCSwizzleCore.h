//
//  STCSwizzleCore.h
//  SafariStand
//
//  Created by Ivan Faiustov on 17/10/16.
//
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString *const SWIZZLE_ID;

@class STCSwizzledMethod;

@interface STCSwizzleCore : NSObject

+ (void)applySwizzlingWithMethod:(STCSwizzledMethod *)method;
+ (SEL)swizzledSelectorFromSelector:(SEL)originalSel;

@end
