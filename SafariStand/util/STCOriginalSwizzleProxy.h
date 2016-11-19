//
//  STCOriginalSwizzleProxy.h
//  SafariStand
//
//  Created by Ivan Faiustov on 18/10/16.
//
//

#import <Foundation/Foundation.h>
#import "STCMethod.h"

@interface STCOriginalSwizzleProxy : NSProxy

+ (instancetype)proxyForInstance:(id)instance;

@end
