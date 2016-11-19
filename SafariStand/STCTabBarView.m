//
//  STCTabBarView.m
//  SafariStand
//
//  Created by Ivan Faiustov on 24/10/2016.
//
//

#import "STCTabBarView.h"

#pragma GCC diagnostic ignored "-Wincomplete-implementation"

@implementation STCTabBarView

@end

@implementation NSView (STCTabBarView)

- (STCTabBarView *)tabBarProxy {
    STCTabBarView *proxy = [[STCTabBarView alloc] initWithObject:self];
    
    return proxy;
}

@end
