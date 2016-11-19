//
//  STTabProxyController.m
//  SafariStand

#if !__has_feature(objc_arc)
#error This file must be compiled with ARC
#endif


#import "SafariStand.h"
#import "STTabProxy.h"
#import "STTabProxyController.h"

//#import <WebKit2/WKImage.h>
//#import <WebKit2/WKImageCG.h>
//#import <WebKit2/WKBundlePage.h>

#import "HTWebKit2Adapter.h"

#import "STCBrowserWindowController.h"

@implementation STTabProxyController


static STTabProxyController *sharedInstance;

- (void)setup
{

    NSMutableArray* ary=[[NSMutableArray alloc]initWithCapacity:32];
    self.allTabProxy=ary;

    //既存のものにパッチ
    STSafariEnumerateBrowserTabViewItem(^(NSTabViewItem* tabViewItem, BOOL* stop){
        [STTabProxy tabProxyForTabViewItem:tabViewItem];
    });

    //tabViewItem を生成するとき STTabProxy を付ける
    Class cls=NSClassFromString(@"BrowserTabViewItem");

    //Safari 8
    if ([cls instancesRespondToSelector:@selector(initWithScrollableTabBarView:browserTab:)]) {
        //- (id)initWithScrollableTabBarView:(id)arg1 browserTab:(struct BrowserTab *)arg2;
        KZRMETHOD_SWIZZLING_("BrowserTabViewItem", "initWithScrollableTabBarView:browserTab:", id, call, sel)
        ^id (id slf, id tabBarView, void* browserTab)
        {
            id result=call(slf, sel, tabBarView, browserTab);
            id proxy __unused=[[STTabProxy alloc]initWithTabViewItem:result];
            return result;
            
        }_WITHBLOCK;
    //Safari 9
    }else if ([cls instancesRespondToSelector:@selector(initWithBrowserWindowControllerMac:)]) {
        KZRMETHOD_SWIZZLING_("BrowserTabViewItem", "initWithBrowserWindowControllerMac:", id, call, sel)
        ^id (id slf, id winCtl)
        {
            id result=call(slf, sel, winCtl);
            id proxy __unused=[[STTabProxy alloc]initWithTabViewItem:result];
            return result;
            
        }_WITHBLOCK;
    }

    
    //tabの数変更を監視するため
    //順番入れ替えのときは2回呼ばれる(remove->insert)
    //Safari が飛ばす BrowserWindowControllerMacTabsInWindowDidChangeNotification に依存するように変更 ← Safari 9 で廃止っぽい
    //こちらは順番入れ替えでも1回しか発生しない。notification object は BrowserWindowControllerMac
    /*
     KZRMETHOD_SWIZZLING_("ScrollableTabBarView", "tabViewDidChangeNumberOfTabViewItems:", void, call, sel)
    ^(id slf, NSTabView* tabView)
    {
        call(slf, sel, tabView);
        [[NSNotificationCenter defaultCenter]postNotificationName:STTabViewDidChangeNote object:tabView];
    }_WITHBLOCK;
    */
    
    //Safari 9
    KZRMETHOD_SWIZZLING_("TabBarView", "insertTabBarViewItem:atIndex:", void, call, sel)
    ^(id slf, id arg1, unsigned long long arg2)
    {
        call(slf, sel, arg1, arg2);
        NSTabView* tabView=[arg1 tabView];
        [[NSNotificationCenter defaultCenter]postNotificationName:STTabViewDidChangeNote object:tabView];
        
        
    }_WITHBLOCK;
    
    KZRMETHOD_SWIZZLING_("TabBarView", "removeTabBarViewItem:", void, call, sel)
    ^(id slf, id arg1)
    {
        call(slf, sel, arg1);
        NSTabView* tabView=[arg1 tabView];
        [[NSNotificationCenter defaultCenter]postNotificationName:STTabViewDidChangeNote object:tabView];
        
    }_WITHBLOCK;

    KZRMETHOD_SWIZZLING_(kSafariBrowserWindowControllerCstr, "_moveTab:toIndex:isChangingPinnedness:", void, call, sel)
    ^(id slf, id arg1, unsigned long long arg2, BOOL ar3)
    {
        call(slf, sel, arg1, arg2, ar3);
        NSTabView* tabView=[arg1 tabView];
        [[NSNotificationCenter defaultCenter]postNotificationName:STTabViewDidChangeNote object:tabView];
        
    }_WITHBLOCK;
    
    //tabの選択を監視するため
    KZRMETHOD_SWIZZLING_("TabBarView", "selectTabBarViewItem:", void, call, sel)
    ^(id slf, id item)
    {
        call(slf, sel, item);
        NSTabView* tabView=[item tabView];
        NSArray* tabViewItems=[tabView tabViewItems];
        for (NSTabViewItem* eachItem in tabViewItems) {
            STTabProxy* proxy=[STTabProxy tabProxyForTabViewItem:eachItem];
            if (eachItem==item) {
                proxy.isUnread=NO;
                proxy.isSelected=YES;
            }else if (proxy.isSelected){
                proxy.isSelected=NO;
            }
        }
        
        [[NSNotificationCenter defaultCenter]postNotificationName:STTabViewDidSelectItemNote object:tabView];
        
    }_WITHBLOCK;
    

    //tabView入れ替わりを監視するため
    /* bookmarks bar の「すべてをタブで開く」などで呼ばれる。NSTabView ごと入れ替わる
       このとき古い NSTabView は「戻る」できるように保持されている。
       そこからページ遷移すると古い NSTabView は破棄され、戻ることもできなくなる。
     
       新規作成した直後に「すべてをタブで開く」を実行するとうまく取れない。#wontfix
       tabViewDidChangeNumberOfTabViewItems: は取れるので以前は問題なかった
     */
    /*
     Safari 9 では -[BrowserWindowContentView setTabSwitcher:] が廃止
     -[BrowserWindowControllerMac setTabSwitcher:] に切り替えれば良さそうだが
     とりあえず放置。
     */
#if 0
    //Safari 8
    KZRMETHOD_SWIZZLING_("BrowserWindowContentView", "setTabSwitcher:", void, call, sel)
    ^(id slf, id/*NSTabView*/ tabView)
    {
        //[self willChangeValueForKey:@"allTabProxy"];
        
        //leftTabs
        NSTabView* exitTabView=objc_msgSend(slf, @selector(tabSwitcher));
        NSArray* exitTabs=[STTabProxyController tabProxiesForTabView:exitTabView];
        [exitTabs enumerateObjectsUsingBlock:^(STTabProxy* obj, NSUInteger idx, BOOL *stop) {
            obj.hidden=YES;
        }];
        
        call(slf, sel, tabView);
        
        //[[STTabProxyController si]maintainTabSelectionOrder:[STTabProxy tabProxyForTabViewItem:tabView]];
        //proxy.isSelected がセットされてないことがある
        NSTabViewItem* selectedTabViewItem=[tabView selectedTabViewItem];
        STTabProxy* proxy=[STTabProxy tabProxyForTabViewItem:selectedTabViewItem];
        proxy.isSelected=YES;
        
        NSArray* enteredTabs=[STTabProxyController tabProxiesForTabView:tabView];
        [enteredTabs enumerateObjectsUsingBlock:^(STTabProxy* obj, NSUInteger idx, BOOL *stop) {
            obj.hidden=NO;
        }];
        
        //[self didChangeValueForKey:@"allTabProxy"];
        [[NSNotificationCenter defaultCenter] postNotificationName:STTabViewDidReplaceNote object:tabView];
    }_WITHBLOCK;
#endif
    
    
    //STTabProxy の title を更新するため
    KZRMETHOD_SWIZZLING_("BrowserTabViewItem", "setLabel:", void, call, sel)
    ^(id slf, NSString* label)
    {
        call(slf, sel, label);
        
        STTabProxy* proxy=[STTabProxy tabProxyForTabViewItem:slf];
        proxy.title=label;
    }_WITHBLOCK;

    //tabViewItem がdealloc、 STTabProxyリストから除外
    //重要：dealloc 中 retain されないように self は __unsafe_unretained
    KZRMETHOD_SWIZZLING_("BrowserTabViewItem", "dealloc", void, call, sel)
    ^(__unsafe_unretained id slf)
    {
        
        id proxy=[STTabProxy tabProxyForTabViewItem:slf];
        if(proxy){
            [proxy tabViewItemWillDealloc];
            [[STTabProxyController si]removeTabProxy:proxy];
        }
        proxy=nil;
        call(slf, sel);
    }_WITHBLOCK;
    
    
    //WKView は頻繁に作り直される。そのとき didStartProgress が上手く取れないため view の入れ替え時に捕まえる
    KZRMETHOD_SWIZZLING_("ResizableContentContainer", "didAddSubview:", void, call, sel)
    ^void (id slf, id wkView)
    {
        call(slf, sel, wkView);
        
        if ([[wkView className]isEqualToString:@"BrowserWKView"]) {
            NSView* tabContentView=[slf superview];
            STSafariEnumerateBrowserTabViewItem(^(NSTabViewItem *tabViewItem, BOOL *stop) {
                if (![tabViewItem respondsToSelector:@selector(tabContentView)]) {
                    return;
                }
                id view=((id(*)(id, SEL, ...))objc_msgSend)(tabViewItem, @selector(tabContentView));
                if (view==tabContentView) {
                    STTabProxy* proxy=[STTabProxy tabProxyForTabViewItem:tabViewItem];
                    [proxy wkViewDidReplaced:wkView];
                    *stop=YES;
                }
            });
        }
    }_WITHBLOCK;
    
    [[STCBrowserWindowController instance] applySwizzling];

    //favicon update
    //2回ほど無駄に多めに呼ばれる。そのときアイコンを取りに行っても準備できてない。
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(noteWebIconDatabaseDidAddIcon:)
                                                name:@"IconControllerDidChangeIconForPageURLNotification" object:nil];
    
}

- (void)noteWebIconDatabaseDidAddIcon:(NSNotification*)notification
{
    NSURL* url=[[notification userInfo]objectForKey:@"iconControllerPageURLKey"];
    if (url) {
        STSafariEnumerateBrowserTabViewItem(^(NSTabViewItem *tabViewItem, BOOL *stop) {
            STTabProxy* proxy=[STTabProxy tabProxyForTabViewItem:tabViewItem];
            [proxy iconDatabaseDidAddIconForURL:url];
        });
    }
}


+ (STTabProxyController *)si
{
    if (sharedInstance == nil) {
		sharedInstance = [[STTabProxyController alloc]init];
        [sharedInstance setup];
    }
    
    return sharedInstance;
}


+ (NSMutableArray *)tabProxiesForTabView:(NSTabView*)tabView
{
    NSMutableArray* ary=nil;
    NSArray* tabs=[tabView tabViewItems];
    ary=[NSMutableArray arrayWithCapacity:[tabs count]];
    for (id tabViewItem in tabs) {
        if (STSafariUsesWebKit2(tabViewItem)) {
            id proxy=[STTabProxy tabProxyForTabViewItem:tabViewItem];
            if (proxy) {
                [ary addObject:proxy];
            }
        }
    }
    return ary;

}


+ (NSMutableArray *)tabProxiesForWindow:(NSWindow*)win
{
    NSMutableArray* ary=nil;
    id winCtl=[win windowController];
    if([[winCtl className]isEqualToString:kSafariBrowserWindowController]
       && [winCtl respondsToSelector:@selector(orderedTabViewItems)]){
        NSArray* tabs=objc_msgSend(winCtl, @selector(orderedTabViewItems));
        
        ary=[NSMutableArray arrayWithCapacity:[tabs count]];
        for (id tabViewItem in tabs) {
            if (STSafariUsesWebKit2(tabViewItem)) {
                id proxy=[STTabProxy tabProxyForTabViewItem:tabViewItem];
                if (proxy) {
                    [ary addObject:proxy];
                }
            }
        }
    }
    return ary;
}


- (id)init {
    self = [super init];
    if (!self) return nil;

    return self;
}


- (STTabProxy*)tabProxyForPageRef:(void*)pageRef
{
    for (STTabProxy* tabProxy in _allTabProxy) {
        if ([tabProxy pageRef]==pageRef) {
            return tabProxy;
        }
    }
    return nil;
}


- (void)addTabProxy:(id)tabProxy
{
    NSIndexSet *indexes = [NSIndexSet indexSetWithIndex:[_allTabProxy count]];
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"allTabProxy"];
    [_allTabProxy addObject:tabProxy];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"allTabProxy"];
}


- (void)removeTabProxy:(id)tabProxy
{
    NSInteger idx=[_allTabProxy indexOfObjectIdenticalTo:tabProxy];
    if (idx==NSNotFound) {
        return;
    }
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"tabProxyWillRemove" object:tabProxy];
    NSIndexSet *indexes=[NSIndexSet indexSetWithIndex:idx];
    
    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"allTabProxy"];
    [self.allTabProxy removeObjectAtIndex:idx];
    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"allTabProxy"];
    
}

//not use now
- (void)maintainTabSelectionOrder:(id)tabProxy
{
    if (tabProxy) {
        [self.allTabProxy removeObject:tabProxy];
        [self.allTabProxy addObject:tabProxy];
    }
}


- (NSTabViewItem*)lastSelectedTabViewItemForwindow:(NSWindow*)win
{
    NSTabViewItem* result=nil;
    NSEnumerator* e=[self.allTabProxy reverseObjectEnumerator];
    STTabProxy* tabProxy=nil;
    while (tabProxy=[e nextObject]) {
        if ([[tabProxy tabView]window]==win) {
            result=[tabProxy tabViewItem];
            break;
        }
    }
    return result;
}

@end

