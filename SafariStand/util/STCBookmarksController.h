//
//  STCBookmarksController.h
//  SafariStand
//
//  Created by Ivan Faiustov on 17/10/16.
//
//

#import "STCProxy.h"

@interface STCBookmarksController : STCProxy

+ (instancetype)sharedController;

- (id)bookmarksMenuCollection;
- (id)bookmarksBarCollection;

@end
