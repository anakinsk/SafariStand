//
//  STCBrowserTabViewItem.m
//  SafariStand
//
//  Created by Ivan Faiustov on 24/10/2016.
//
//

#import "STCBrowserTabViewItem.h"

@implementation STCBrowserTabViewItem

@end

@implementation NSTabViewItem (STCBrowserTabViewItem)

- (STCBrowserTabViewItem *)proxy {
    STCBrowserTabViewItem *proxy = [[STCBrowserTabViewItem alloc] initWithObject:self];
    
    return proxy;
}

@end
