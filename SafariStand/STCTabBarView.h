//
//  STCTabBarView.h
//  SafariStand
//
//  Created by Ivan Faiustov on 24/10/2016.
//
//

#import "STCProxy.h"

@interface STCTabBarView : STCProxy

- (NSArray *)tabBarViewItems;

@end

@interface NSView (STCTabBarView)

- (STCTabBarView *)tabBarProxy;

@end
