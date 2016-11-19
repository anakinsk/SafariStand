//
//  STCBrowserWindowController.m
//  SafariStand
//
//  Created by Ivan Faiustov on 24/10/2016.
//
//

#import "STCBrowserWindowController.h"
#import "STCBrowserTabViewItem.h"
#import "STCTabBarView.h"
#import "STSafariConnect.h"

#pragma GCC diagnostic ignored "-Wincomplete-implementation"

@implementation STCBrowserWindowController

+ (NSString *)proxiedClassName {
    return @"BrowserWindowController";
}

- (NSMenu *)tabBarView:(NSView *)tabBarView menuForTabBarViewItem:(NSTabViewItem *)tabBarViewItem event:(NSEvent *)event {
    NSMenu *menu = [[STCBrowserWindowController originalWithInstance:self] tabBarView:tabBarView menuForTabBarViewItem:tabBarViewItem event:event];
    
    NSArray *tabViewItems = [[tabBarView tabBarProxy] tabBarViewItems];
    NSInteger selectedIndex = [tabViewItems indexOfObject:tabBarViewItem];
    
    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"Duplicate Tab" action:@selector(duplicateTab:) keyEquivalent:@""];
    [item setTarget:[STCBrowserWindowController instance]];
    [item setRepresentedObject:tabBarViewItem];
    [item setTag:selectedIndex];
    
    NSMenuItem *separator = [NSMenuItem separatorItem];
    
    [menu insertItem:separator atIndex:2];
    [menu insertItem:item atIndex:2];
    
    return menu;
}

- (NSArray<STCSwizzledMethod *> *)swizzledMethods {
    STCSwizzledMethod *method1 = [[STCSwizzledMethod alloc] initWithProxy:self selector:@selector(tabBarView:menuForTabBarViewItem:event:) classMethod:NO];
    
    return @[method1];
}

- (void)duplicateTab:(NSMenuItem *)item {
    id object = [item representedObject];
    
    NSString *urlString = [object valueForKey:@"URLString"];
    
    STSafariCreateTabForURLAtIndex([NSURL URLWithString:urlString], item.tag+1);
}


@end
