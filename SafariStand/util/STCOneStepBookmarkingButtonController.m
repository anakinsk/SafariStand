//
//  STCOneStepBookmarkingButtonController.m
//  SafariStand
//
//  Created by Ivan Faiustov on 17/10/16.
//
//

#import "STCOneStepBookmarkingButtonController.h"
#import "STCBookmarksController.h"
#import "STCSafariStandCore.h"

@implementation STCOneStepBookmarkingButtonController

+ (NSString *)proxiedClassName {
    return @"OneStepBookmarkingButtonController";
}

- (void)_addBookmarkToReadingListWithoutAskingAndMakeDefault:(BOOL)arg1 {
    NSInteger currentMode = [[[STCSafariStandCore ud] objectForKey:kpPlusButtonModeKey] integerValue];
    
    id bookmarksObject = [STCOneStepBookmarkingButtonController bookmarkFolderForMode:currentMode];
    
    if (bookmarksObject) {
        // Self here is not our class but Safari's OneStepBookmarkingButtonController cause of the method swizzling
        [self _addBookmarkWithoutAskingToFolder:bookmarksObject andMakeDefault:arg1];
    } else {
        // Here we call the original implementation using our original proxy class
        [[STCOneStepBookmarkingButtonController originalWithInstance:self] _addBookmarkToReadingListWithoutAskingAndMakeDefault:arg1];
    }
}

- (void)_addBookmarkWithoutAskingToFolder:(id)bookmarksObject andMakeDefault:(BOOL)arg1 {
    // This one is here just so we can trick the compile in a thinking that the method is actually defined :)
}

- (NSString *)oneStepBookmarkingButtonActionDescription {
    return [STCOneStepBookmarkingButtonController bookmarkStringForMode:[[[STCSafariStandCore ud] stringForKey:kpPlusButtonModeKey] integerValue]];
}

- (NSArray<STCSwizzledMethod *> *)swizzledMethods {
    STCSwizzledMethod *method1 = [[STCSwizzledMethod alloc] initWithProxy:self selector:@selector(_addBookmarkToReadingListWithoutAskingAndMakeDefault:) classMethod:NO];
    STCSwizzledMethod *method2 = [[STCSwizzledMethod alloc] initWithProxy:self selector:@selector(oneStepBookmarkingButtonActionDescription) classMethod:NO];
    
    return @[method1, method2];
}

#pragma mark - Utils

+ (id)bookmarkFolderForMode:(NSInteger)mode {
    STCBookmarksController *controller = [STCBookmarksController sharedController];
    
    id bookmarksObject = nil;
    
    switch (mode) {
        case 1:
            return [controller bookmarksMenuCollection];
            break;
            
        case 2:
            return [controller bookmarksBarCollection];
            break;
            
        default:
            break;
    }
    
    return bookmarksObject;
}

+ (NSString *)bookmarkStringForMode:(NSInteger)mode {
    NSString *word = nil;
    
    switch (mode) {
        case 0:
            word = kpPlusButtonModeReadingList;
            break;
            
        case 1:
            word = kpPlusButtonModeBookmarksMenu;
            break;
            
        case 2:
            word = kpPlusButtonModeBookmarksBar;
            break;
    }
    
    return [NSString stringWithFormat:@"Add to %@", word];
}

@end
