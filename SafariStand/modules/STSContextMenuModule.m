//
//  STSContextMenuModule.m
//  SafariStand

#if !__has_feature(objc_arc)
#error This file must be compiled with -fno-objc-arc
#endif

#import "SafariStand.h"
#import "STSContextMenuModule.h"
#import "STQuickSearchModule.h"
#import <WebKit/WebKit.h>
#import "HTWebKit2Adapter.h"
#import "HTWebClipwinCtl.h"
#import "STFakeJSCommand.h"

#import "STSquashContextMenuSheetCtl.h"

#ifdef DEBUG
//#define DEBUG_MENUDUMP 0
#endif

@implementation STSContextMenuModule

- (void)injectToContextMenuWithButtonCell:(NSMenu *)menu withVKView:(id)wkview
{
    NSMenuItem* itm;
    
    BOOL hasSelectedLink=NO;
    BOOL hasSelectedText=NO;
    
    // 既存のメニュー項目をいくつか取得
    NSMenuItem* copyTextItem=[menu itemWithTag:8]; //8 == copy text
    NSMenuItem* copyLinkItem=[menu itemWithTag:3]; //3 == copy link
    NSMenuItem* copyImageItem=[menu itemWithTag:6]; //6 == copy link
    NSMenuItem* sharingMenuItem=[menu itemWithTag:2053];
    NSArray* sharingItems=[[[sharingMenuItem representedObject]valueForKey:@"_reserved"]valueForKey:@"items"]; //NSSharingServicePickerReserved
    NSMutableDictionary* selectionInfo=[[NSMutableDictionary alloc]initWithCapacity:2];

    for (id sharingItem in sharingItems) {
        if ([sharingItem isKindOfClass:[NSURL class]]) {
            selectionInfo[@"link"]=sharingItem;
            hasSelectedLink=YES;
        }else if ([sharingItem isKindOfClass:[NSString class]]){
            selectionInfo[@"label"]=sharingItem;
            hasSelectedText=YES;
        }
    }
    

#ifdef DEBUG_MENUDUMP
    static NSMutableDictionary* tagdic=nil;
    if (tagdic==nil) {
        tagdic=[[NSMutableDictionary alloc]init];
    }
    static NSMutableArray* tagary=nil;
    if (tagary==nil) {
        tagary=[[NSMutableArray alloc]init];
    }

    for (NSMenuItem* itm in [menu itemArray]) {
        if ([itm tag] && [itm title]) {
            NSNumber *tagNum=[NSNumber numberWithInteger:[itm tag]];
            if (![tagdic objectForKey:tagNum]) {
                [tagary addObject:[NSDictionary dictionaryWithObjectsAndKeys:tagNum, @"tag", [itm title], @"title",nil]];
                [tagdic setObject:[itm title] forKey:tagNum];
            }
        }
        NSString* debugTtile=[NSString stringWithFormat:@"%@ (%lu)",[itm title],[itm tag]];
        [itm setTitle:debugTtile];
    }
#endif

    //[webUserDataWrapper userData] returns invalid data
#if 0
    //STSDownloadModule  replace Save Image to “Downloads”
	if([[STCSafariStandCore ud]boolForKey:kpClassifyDownloadFolderBasicEnabled]){
        NSInteger tag;
        
        //Safari 8
        tag=10011;

        NSMenuItem* itm=[menu itemWithTag:tag];
        id dlModule=[STCSafariStandCore mi:@"STSDownloadModule"];
        if (itm && dlModule) {
            [itm setAction:@selector(actCopyImageToDownloadFolderMenu:)];
            [itm setTarget:dlModule];
#ifdef DEBUG_MENUDUMP
            [itm setTitle:@"actCopyImageToDownloadFolderMenu:"];
#endif
        }
    }
#endif
    
    
    // 選択文字列を調べる
    if (copyTextItem || copyLinkItem) {
        hasSelectedText=YES;
    }
    
    if (wkview && hasSelectedText) {
        NSString* selectedText=selectionInfo[@"label"];
        
        NSPasteboard* pb=[NSPasteboard pasteboardWithName:kSafariStandPBKey];
        [pb clearContents];
        
        if (!selectedText) {
            //NSStringPboardType is deprecated but WKView doesn't handle NSPasteboardTypeString.
            [wkview writeSelectionToPasteboard:pb types:[NSArray arrayWithObject:NSStringPboardType]];
            selectedText=[pb stringForType:NSStringPboardType];
        }else{
            [pb setString:selectedText forType:NSStringPboardType];
        }

        NSUInteger len=[selectedText length];
        if(len>0 && len<1024){//あんまり長いのは除外
            [[STQuickSearchModule si]setupContextMenu:menu forceBottom:(copyLinkItem ? YES:NO)];
        }
        
        //Clip Web Archive
        if(len>0 && [[STCSafariStandCore ud]boolForKey:kpShowClipWebArchiveContextMenu]){
            NSMenuItem* itm;
            itm=[[NSMenuItem alloc]initWithTitle:@"Clip Web Archive with Selection"
                                          action:@selector(actWebArchiveSelectionMenu:) keyEquivalent:@""];
            [itm setTarget:self];
            [itm setRepresentedObject:wkview];
            [menu addItem:itm];
        }
    }

    
    if(hasSelectedLink){
        
        NSInteger idx=[menu indexOfItem:copyLinkItem];
        if([[STCSafariStandCore ud]boolForKey:kpShowCopyLinkTagContextMenu]){
            if([[STCSafariStandCore ud]boolForKey:kpCopyLinkTagAddTargetBlank]){
                itm=[[NSMenuItem alloc]initWithTitle:LOCALIZE(@"Copy Link Tag (_blank)")
                                              action:@selector(actCopyLinkTagBlankMenu:) keyEquivalent:@""];
            }else{
                itm=[[NSMenuItem alloc]initWithTitle:LOCALIZE(@"Copy Link Tag")
                                              action:@selector(actCopyLinkTagMenu:) keyEquivalent:@""];
            }
            [itm setTarget:self];
            [itm setRepresentedObject:selectionInfo];
            [menu insertItem:itm atIndex:++idx];
            
            if([[STCSafariStandCore ud]boolForKey:kpCopyLinkTagAddTargetBlank]){
                itm=[[NSMenuItem alloc]initWithTitle:LOCALIZE(@"Copy Link Tag")
                                              action:@selector(actCopyLinkTagMenu:) keyEquivalent:@""];
            }else{
                itm=[[NSMenuItem alloc]initWithTitle:LOCALIZE(@"Copy Link Tag (_blank)")
                                              action:@selector(actCopyLinkTagBlankMenu:) keyEquivalent:@""];
            }
            [itm setTarget:self];
            [itm setRepresentedObject:selectionInfo];
            [itm setKeyEquivalentModifierMask:NSAlternateKeyMask];
            [itm setAlternate:YES];
            [menu insertItem:itm atIndex:++idx];
        }
        
        if([[STCSafariStandCore ud]boolForKey:kpShowCopyLinkTitleContextMenu]){
            itm=[[NSMenuItem alloc]initWithTitle:LOCALIZE(@"Copy Link Title") action:@selector(actCopyLinkTitleMenu:) keyEquivalent:@""];
            [itm setTarget:self];
            [itm setRepresentedObject:selectionInfo];
            [menu insertItem:itm atIndex:++idx];
            
        }
        
        if([[STCSafariStandCore ud]boolForKey:kpShowCopyLinkAndTitleContextMenu]){
            itm=[[NSMenuItem alloc]initWithTitle:LOCALIZE(@"Copy Link and Title") action:@selector(actCopyLinkAndTitleMenu:) keyEquivalent:@""];
            [itm setTarget:self];
            [itm setRepresentedObject:selectionInfo];
            [menu insertItem:itm atIndex:++idx];
            
            itm=[[NSMenuItem alloc]initWithTitle:LOCALIZE(@"Copy Link (space) Title") action:@selector(actCopyLinkAndTitleSpaceMenu:) keyEquivalent:@""];
            [itm setTarget:self];
            [itm setRepresentedObject:selectionInfo];
            [itm setKeyEquivalentModifierMask:NSAlternateKeyMask];
            [itm setAlternate:YES];
            [menu insertItem:itm atIndex:++idx];
        }
        
#ifdef DEBUG_MENUDUMP
        // WindowPolicy checker
        NSMenu* windowPolicyTestMenu=[self safariWindowPolicyTestMenuWithUserDataWrapper:selectionInfo];
        itm=[[NSMenuItem alloc]initWithTitle:@"WindowPolicyTest" action:nil keyEquivalent:@""];
        [itm setSubmenu:windowPolicyTestMenu];
        [menu insertItem:itm atIndex:++idx];
#endif

        
        //LOG(@"%ud, %ud, %@,%@",type,WKDataGetTypeID(),[copyLinkItem title], NSStringFromSelector([copyLinkItem action]));
    } //if(copyLinkItem)
    
#if 0
    if(copyImageItem){
        if([[STCSafariStandCore ud]boolForKey:kpShowGoogleImageSearchContextMenu]){
            NSInteger idx=[menu indexOfItem:copyImageItem];
            itm=[[NSMenuItem alloc]initWithTitle:LOCALIZE(@"Google Image Search") action:@selector(actImageSearchMenu:) keyEquivalent:@""];
            [itm setTarget:self];
            [itm setRepresentedObject:[copyImageItem representedObject]];
            [menu insertItem:itm atIndex:++idx];
        }
    }
    
#endif
    
    //solo image
    if (wkview && [htMIMETypeForWKView(wkview) hasPrefix:@"image/"]) {
        NSMenu* imagePageSubmenu=[self imagePageSubmenu];
        itm=[[NSMenuItem alloc]initWithTitle:@"Image Display" action:nil keyEquivalent:@""];
        [itm setSubmenu:imagePageSubmenu];
        [menu addItem:itm];
        
    }
    
    //SquashContextMenuItem
    if ([[STCSafariStandCore ud]boolForKey:kpSquashContextMenuItemEnabled]) {
        NSArray* disabledItems=[[STCSafariStandCore ud]arrayForKey:kpSquashContextMenuItemTags];
        for (NSNumber* tag in disabledItems) {
            NSMenuItem* mi=[menu itemWithTag:[tag intValue]];
            if (mi) {
                [menu removeItem:mi];
            }
        }
        //clean up separator
        BOOL prevIsSeparator=YES;
        NSInteger i;
        for (i=[menu numberOfItems]-1; i>=0; --i) {
            NSMenuItem* mi=[menu itemAtIndex:i];
            if ([mi isSeparatorItem]) {
                if(prevIsSeparator || i==0) [menu removeItemAtIndex:i];
                prevIsSeparator=YES;
            }else {
                prevIsSeparator=NO;
            }
        }
    }

}


-(void)actImageSearchMenu:(id)sender
{
    id webUserDataWrapper=[sender representedObject];
    void* apiObject=[webUserDataWrapper userData]; //struct APIObject
    uint32_t type=WKGetTypeID(apiObject);
    if(type==WKDictionaryGetTypeID()){ //8==TypeDictionary
        NSString* urlStr=htWKDictionaryStringForKey(apiObject, @"ImageURL");
        LOG(@"%@",urlStr);
        [[STQuickSearchModule si]sendGoogleImageQuerySeedWithoutAddHistoryWithSearchString:urlStr policy:[STQuickSearchModule tabPolicy]];
    }
}


-(void)actCopyLinkTagMenu:(id)sender
{
    NSDictionary* selectionInfo=[sender representedObject];
    NSURL* linkURL=selectionInfo[@"link"];
    NSString* linkStr=[linkURL absoluteString];
    NSString* titleStr=selectionInfo[@"label"];
    if(!linkStr)linkStr=@"";
    if(!titleStr)titleStr=@"";
    
    NSString* format=LOCALIZE(@"LINKTAG");
    NSString* result=[NSString stringWithFormat:format, linkStr, titleStr];
    
    NSPasteboard*pb=[NSPasteboard generalPasteboard];
    [pb clearContents];
    [pb setString:result forType:NSPasteboardTypeString];

}


-(void)actCopyLinkTagBlankMenu:(id)sender
{
    NSDictionary* selectionInfo=[sender representedObject];
    NSURL* linkURL=selectionInfo[@"link"];
    NSString* linkStr=[linkURL absoluteString];
    NSString* titleStr=selectionInfo[@"label"];
    if(!linkStr)linkStr=@"";
    if(!titleStr)titleStr=@"";
    
    NSString* format=LOCALIZE(@"LINKTAGBLANK");
    NSString* result=[NSString stringWithFormat:format, linkStr, titleStr];
    
    NSPasteboard*pb=[NSPasteboard generalPasteboard];
    [pb clearContents];
    [pb setString:result forType:NSPasteboardTypeString];

}


-(void)actCopyLinkTitleMenu:(id)sender
{
    NSDictionary* selectionInfo=[sender representedObject];
    NSURL* linkURL=selectionInfo[@"link"];
    NSString* linkStr=[linkURL absoluteString];
    NSString* titleStr=selectionInfo[@"label"];
    if(!linkStr)linkStr=@"";
    if(!titleStr)titleStr=@"";

    NSPasteboard*pb=[NSPasteboard generalPasteboard];
    [pb clearContents];
    [pb setString:titleStr forType:NSPasteboardTypeString];
}


-(void)actCopyLinkAndTitleMenu:(id)sender separator:(NSString*)sep
{
    NSDictionary* selectionInfo=[sender representedObject];
    NSURL* linkURL=selectionInfo[@"link"];
    NSString* linkStr=[linkURL absoluteString];
    NSString* titleStr=selectionInfo[@"label"];
    if(!linkStr)linkStr=@"";
    if(!titleStr)titleStr=@"";


    NSString* result=[NSString stringWithFormat:@"%@%@%@", titleStr, sep, linkStr];

    NSPasteboard*pb=[NSPasteboard generalPasteboard];
    [pb clearContents];
    [pb setString:result forType:NSPasteboardTypeString];
}


-(void)actCopyLinkAndTitleMenu:(id)sender
{
    [self actCopyLinkAndTitleMenu:sender separator:@"\n"];
}


-(void)actCopyLinkAndTitleSpaceMenu:(id)sender
{
    [self actCopyLinkAndTitleMenu:sender separator:@" "];
}


-(void)actWebArchiveSelectionMenu:(id)sender
{
    /*    Class webArchiver=NSClassFromString(@"WebArchiver");
     if(webArchiver){
     WebFrame* frame=[sender representedObject];
     WebArchive *archive = objc_msgSend(webArchiver, @selector(archiveSelectionInFrame:), frame);
     
     if(frame && archive){
     [HTWebClipwinCtl showWindowForWebArchive:archive webFrame:frame info:nil];
     }
     return;
     }
     */
    id wkView=[sender representedObject];
    // NSPasteboard 作成
    NSPasteboard* pb=[NSPasteboard pasteboardWithName:kSafariStandPBKey];
    [pb clearContents];
    // 書き込ませる
    [wkView writeSelectionToPasteboard:pb types:[NSArray arrayWithObject:WebArchivePboardType]];
    NSData* dat=[pb dataForType:WebArchivePboardType];
    WebArchive *archive=nil;
    if (dat) {
        //archive=[[[WebArchive alloc]initWithData:dat]autorelease];
        archive=[[WebArchive alloc]initWithData:dat];
    }
    [pb clearContents];

    if(archive){
        NSString* title=STSafariCurrentTitle();
        NSString* urlStr=STSafariCurrentURLString();
        
        if (!title)title=@"Web Archive";
        if (!urlStr)urlStr=@"";
        NSDictionary* info=[NSDictionary dictionaryWithObjectsAndKeys:title, @"title", urlStr, @"url", nil];
    
        [HTWebClipwinCtl showWindowForWebArchive:archive webFrame:nil info:info];
    }
}


- (id)initWithStand:(id)core
{
    self = [super initWithStand:core];
    if (!self) return nil;
    
    KZRMETHOD_SWIZZLING_("WKMenuTarget", "setMenuProxy:",
                         void, call, sel)
    ^(id slf, void *menuProxy)
    {
        call(slf, sel, menuProxy);
        
        KZRMETHOD_SWIZZLING_WITH_REVERT_("NSMenu", "+popUpContextMenu:withEvent:forView:", void, call, sel)
        ^(id slf, NSMenu *object, NSEvent *event, NSView *view) {
             [self injectToContextMenuWithButtonCell:object withVKView:view];
            
            call(self, sel, object, event, view);
            
            KZRSWIZZLE_REVERT;
        }_WITHBLOCK;
    }_WITHBLOCK;
    
    
    return self;
}

- (void)dealloc
{
//    self.squashSheetCtl=nil;
//    [super dealloc];
}


- (void)prefValue:(NSString*)key changed:(id)value
{
    //if([key isEqualToString:])
}


-(NSWindow*)advancedSquashSettingSheet
{
    if (!self.squashSheetCtl) {
        STSquashContextMenuSheetCtl* winCtl=[[STSquashContextMenuSheetCtl alloc]initWithWindowNibName:@"STSquashContextMenuSheetCtl"];
        [winCtl window];
        self.squashSheetCtl=winCtl;
//        [winCtl release];
    }
    return [self.squashSheetCtl window];
}

#pragma mark - image

- (NSMenu*)imagePageSubmenu
{
    NSMenu* menu=[[NSMenu alloc]initWithTitle:@""];
    
    NSMenuItem* itm;
    itm=[menu addItemWithTitle:@"Alignment" action:nil keyEquivalent:@""];
    [itm setEnabled:NO];
    
    itm=[menu addItemWithTitle:@"Align Left" action:@selector(actImagePageAlignment:) keyEquivalent:@""];
    [itm setRepresentedObject:@"0"];
    [itm setTarget:self];
    
    itm=[menu addItemWithTitle:@"Align Center" action:@selector(actImagePageAlignment:) keyEquivalent:@""];
    [itm setRepresentedObject:@"auto"];
    [itm setTarget:self];
    
    [menu addItem:[NSMenuItem separatorItem]];
    itm=[menu addItemWithTitle:@"Background Color" action:nil keyEquivalent:@""];
    [itm setEnabled:NO];
    
    itm=[menu addItemWithTitle:@"White (#FFFFFF)" action:@selector(actImagePageBackgroundColor:) keyEquivalent:@""];
    [itm setRepresentedObject:@"#ffffff"];
    [itm setTarget:self];
    itm=[menu addItemWithTitle:@"Black (#000000)" action:@selector(actImagePageBackgroundColor:) keyEquivalent:@""];
    [itm setRepresentedObject:@"#000000"];
    [itm setTarget:self];
    itm=[menu addItemWithTitle:@"Gray (#666666)" action:@selector(actImagePageBackgroundColor:) keyEquivalent:@""];
    [itm setRepresentedObject:@"#666666"];
    [itm setTarget:self];
    itm=[menu addItemWithTitle:@"Light Gray (#CCCCCC)" action:@selector(actImagePageBackgroundColor:) keyEquivalent:@""];
    [itm setRepresentedObject:@"#cccccc"];
    [itm setTarget:self];
    
    itm=[menu addItemWithTitle:@"Other Color..." action:@selector(actImagePageBackgroundOther:) keyEquivalent:@""];
    [itm setTarget:self];
    
    return menu;
}


- (void)actImagePageAlignment:(NSMenuItem*)sender
{
    NSString* value=[sender representedObject];
    NSString* scpt=[NSString stringWithFormat:@"document.body.childNodes[0].style.margin=\"%@\";", value];
    [STFakeJSCommand doScript:scpt onTarget:nil completionHandler:^(id result) { }];
}


- (void)actImagePageBackgroundColor:(NSMenuItem*)sender
{
    NSString* color=[sender representedObject];
    NSString* scpt=[NSString stringWithFormat:@"document.body.style.background=\"%@\"", color];
    [STFakeJSCommand doScript:scpt onTarget:nil completionHandler:^(id result) { }];
}


- (void)actImagePageBackgroundOther:(NSMenuItem*)sender
{
    NSColorPanel* panel=[NSColorPanel sharedColorPanel];
    
    [panel setTarget:self];
    [panel setAction:@selector(actImagePageBackgroundFromColorPanel:)];
    [panel makeKeyAndOrderFront:self];
}


- (void)actImagePageBackgroundFromColorPanel:(NSColorPanel*)sender
{
    NSColor* color=sender.color;
    NSString* scpt=[NSString stringWithFormat:@"document.body.style.background=\"rgb(%d,%d,%d)\"",
                    (int)(color.redComponent*255.0), (int)(color.greenComponent*255.0), (int)(color.blueComponent*255.0)];
    [STFakeJSCommand doScript:scpt onTarget:nil completionHandler:^(id result) { }];
}


#ifdef DEBUG_MENUDUMP

// WindowPolicy checker
- (NSMenu*)safariWindowPolicyTestMenuWithUserDataWrapper:(id)webUserDataWrapper
{
    NSInteger i;
    NSMenu* menu=[[NSMenu alloc]initWithTitle:@"WindowPolicyTest"];
    for (i=0; i<11; i++) {
        NSString* title=[NSString stringWithFormat:@"WindowPolicy %ld", (long)i];
        NSMenuItem* itm=[[NSMenuItem alloc]initWithTitle:title action:@selector(actWindowPolicyTest:) keyEquivalent:@""];
        [itm setTarget:self];
        [itm setTag:i];
        [itm setRepresentedObject:webUserDataWrapper];
        [menu addItem:itm];
    }
    return menu;
}

- (void)actWindowPolicyTest:(id)sender
{
    NSDictionary* selectionInfo=[sender representedObject];
    NSURL* linkURL=selectionInfo[@"link"];

    if(linkURL) STSafariGoToURLWithPolicy(linkURL, (int)[sender tag]);
}

#endif

@end
