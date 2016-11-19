//
//  STCBrowserContentViewControllerObjCAdapter.m
//  SafariStand
//
//  Created by Ivan Faiustov on 24/10/2016.
//
//

#import "STCBrowserContentViewControllerObjCAdapter.h"

#pragma GCC diagnostic ignored "-Wincomplete-implementation"

@implementation STCBrowserContentViewControllerObjCAdapter

- (instancetype)initWithBrowserContentViewController:(id)contentVC {
    Class adapterClass = NSClassFromString(self.proxiedClassName);
    id adapter = [adapterClass alloc];
    adapter = objc_msgSend(adapter, @selector(initWithBrowserContentViewController:), contentVC);
    
    self = [super initWithObject:adapter];
    
    return self;
}

+ (NSString *)proxiedClassName {
    return @"BrowserContentViewControllerObjCAdapter";
}

@end
