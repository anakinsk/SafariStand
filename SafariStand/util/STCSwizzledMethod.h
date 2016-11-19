//
//  STCSwizzledMethod.h
//  SafariStand
//
//  Created by Ivan Faiustov on 17/10/16.
//
//

#import "STCMethod.h"

@class STCSwizzleProxy;

@interface STCSwizzledMethod : STCMethod

@property (nonatomic, weak) STCSwizzleProxy *proxy;

- (instancetype)initWithProxy:(STCSwizzleProxy *)proxy selector:(SEL)selector classMethod:(BOOL)classMethod;

@end
