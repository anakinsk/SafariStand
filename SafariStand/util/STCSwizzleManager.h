//
//  STCSwizzleManager.h
//  SafariStand
//
//  Created by Ivan Faiustov on 17/10/16.
//
//

#import <Foundation/Foundation.h>
#import "STCSwizzleProxy.h"

@interface STCSwizzleManager : NSObject

@property (nonatomic, readonly) NSArray<STCSwizzleProxy *> *swizzledObjects;

@end
