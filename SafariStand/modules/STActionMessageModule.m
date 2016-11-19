//
//  STActionMessageModule.m
//  SafariStand

#if !__has_feature(objc_arc)
#error This file must be compiled with ARC
#endif

#import "SafariStand.h"
#import "STActionMessageModule.h"
#import "STSafariConnect.h"

#define kActionMessageScheme	@"action_message:"
#define kActionMessagePrefix	@"action_message"
@implementation STActionMessageModule



- (id)initWithStand:(id)core
{
    self = [super initWithStand:core];
    if (!self) return nil;

    
    /*
    //Safari 8
    KZRMETHOD_SWIZZLING_(STSafariBookmarksControllerClass(), "addMenuItemForBookmark:withTabPlacementHint:toMenu:", id, call, sel)
    ^id(id slf, id bookmark, void* tabLocation, id menu)
    {
        id returnValue=nil;
        
        returnValue=[actionMessageModule menuItemForBookmarkLeaf:bookmark];
        if(returnValue){
            [menu addItem:returnValue];
            return returnValue;
        }
        returnValue=call(slf, sel, bookmark, tabLocation, menu);
        return returnValue;
        
    }_WITHBLOCK;
    */
    
    KZRMETHOD_SWIZZLING_("NSMenu", "safari_addMenuItemForBookmark:withTabPlacementHint:", id, call, sel)
    ^id(id slf, id bookmark, void* tabLocation)
    {
        id returnValue=nil;
        
        returnValue=[self menuItemForBookmarkLeaf:bookmark];
        if(returnValue){
            [slf addItem:returnValue];
            return returnValue;
        }
        id result=call(slf, sel, bookmark, tabLocation);
        return result;
    }_WITHBLOCK;

    
    //BookmarkBarをクリックしたとき
    KZRMETHOD_SWIZZLING_("FavoriteButton", "_goToBookmark", void, call, sel)
    ^(id slf){
        BOOL	hackHandled=NO;
        if([[STCSafariStandCore ud]boolForKey:kpActionMessageEnabled] && [slf respondsToSelector:@selector(bookmark)]){
            id	bookmark=objc_msgSend(slf, @selector(bookmark));
            if(bookmark){
                NSString	*url=STSafariWebBookmarkURLString(bookmark);
                hackHandled=[self handleBookmakBarAction:url];
            }
        }
        //横取りしてなかったら元を呼ぶ
        if(!hackHandled)
            call(slf, sel);
        
    }_WITHBLOCK;
    
    
    return self;
}


- (NSMenuItem*)menuItemForBookmarkLeaf:(id)bookmarkLeaf
{
	id returnValue=nil;
    
    int bookmarkType=STSafariWebBookmarkType(bookmarkLeaf);
	if(bookmarkType==wbBookmark){
		//this is WebBookmarkLeaf
        NSString *url=STSafariWebBookmarkURLString(bookmarkLeaf);
        
        if([url hasPrefix:kActionMessageScheme]){
            NSString*   menuTitle=STSafariWebBookmarkTitle(bookmarkLeaf);

            returnValue=[[NSMenuItem alloc]initWithTitle:menuTitle action:@selector(actHandleBookmakItem:) keyEquivalent:@""];
			[returnValue setTarget:self];
			[returnValue setEnabled:YES];
            [returnValue setRepresentedObject:url];
		}
	}		
    
	return returnValue;    
}


- (void)handleActionMessage:(NSArray*)messages
{
    NSString* action=[[messages objectAtIndex:1]stringByAppendingString:@":"];
    SEL	selector=NSSelectorFromString(action);
    if(selector){
        [NSApp sendAction:selector to:nil from:self];
    }
}

//001 BookmakBar_Action
- (BOOL)handleBookmakBarAction:(NSString*)url
{
    if(![[STCSafariStandCore ud]boolForKey:kpActionMessageEnabled])return NO;
    
	//foundRange.location==0;    unsigned int length
    NSArray* ary=[url componentsSeparatedByString:@":"];
    if([ary count]<=1) return NO;
    
	if([[ary objectAtIndex:0]isEqualToString:kActionMessagePrefix]){
        [self handleActionMessage:ary];
		return YES;
	}
	return NO;
}


//001 BookmakBar_Action
//ブックマークバーのクリック、ブックマークメニュー選択 IBAction
- (void)actHandleBookmakItem:(id)sender
{
    id url=nil;
    if([sender isKindOfClass:[NSString class]]){
        url=sender;
    }else{
        url=[sender representedObject];
    }
    if(url){
        [self handleBookmakBarAction:url];
    }
}


@end
