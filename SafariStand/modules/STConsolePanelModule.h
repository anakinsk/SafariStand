//
//  STConsolePanelModule.h
//  SafariStand


@import AppKit;
#import "STCTabWithToolbarWinCtl.h"


@interface STConsolePanelModule : STCModule

@property(nonatomic, strong) NSMutableDictionary* panels;
@property(nonatomic, weak) id bookmarksSidebarViewController;

// register panel item. do not call outside of modulesDidFinishLoading:
- (void)addPanelWithIdentifier:(NSString*)identifier title:(NSString*)title icon:(NSImage*)icon weight:(NSInteger)weight loadHandler:(id(^)())loadHandler;

- (void)showConsolePanelAndSelectTab:(NSString*)identifier;
- (NSString*)selectedTabIdentifier;

@end


@interface STConsolePanelCtl : STCTabWithToolbarWinCtl

@property(nonatomic, assign) STConsolePanelModule* consolePanelModule;

- (void)commonConsolePanelCtlInitWithModule:(STConsolePanelModule*)consolePanelModule;
- (NSToolbarItem*)firstSelectableItem;
- (void)selectTab:(NSString*)identifier;
- (void)highlighteToolbarItemIdentifier:(NSString *)itemIdentifier;

@end


@interface STConsolePanelWindow : NSWindow

@end


@interface STConsolePanelToolbar : NSToolbar

@end
