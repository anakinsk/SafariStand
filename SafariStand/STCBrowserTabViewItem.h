//
//  STCBrowserTabViewItem.h
//  SafariStand
//
//  Created by Ivan Faiustov on 24/10/2016.
//
//

#import "STCProxy.h"

@interface STCBrowserTabViewItem : STCProxy

- (id)browserContentViewController;

@end

@interface NSTabViewItem (STCBrowserTabViewItem)

- (STCBrowserTabViewItem *)proxy;

@end
