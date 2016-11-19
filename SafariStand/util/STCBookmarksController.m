//
//  STCBookmarksController.m
//  SafariStand
//
//  Created by Ivan Faiustov on 17/10/16.
//
//

#pragma GCC diagnostic ignored "-Wincomplete-implementation"

#import "STCBookmarksController.h"

@implementation STCBookmarksController

+ (instancetype)sharedController {
    Class bookmarkControllerClass = NSClassFromString(@"BookmarksController");
    id bookmarkController = objc_msgSend(bookmarkControllerClass, @selector(sharedController));
    
    return [[self alloc] initWithObject:bookmarkController];
}

@end
