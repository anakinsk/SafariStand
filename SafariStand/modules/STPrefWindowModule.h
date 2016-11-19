//
//  STPrefWindowModule.h
//  SafariStand


@import AppKit;
#import "STCTabWithToolbarWinCtl.h"



@class STCTabWithToolbarWinCtl;


@interface STPrefWindowModule : STCModule

- (void)addPane:(NSView*)view withIdentifier:(NSString*)identifier title:(NSString*)title icon:(NSImage*)icon;
- (IBAction)actShowPrefWindow:(id)sender;

@end


@interface STPrefWindowCtl : STCTabWithToolbarWinCtl

@property(nonatomic, assign) IBOutlet NSTextField* oCurrentVarsionLabel;
@property(nonatomic, assign) IBOutlet NSProgressIndicator* oUpdateChekingPie;
@property(nonatomic, assign) IBOutlet NSButton* oGoBackForwardByDeleteKeyCB;
@property(nonatomic, strong) NSString* currentVersionString;

- (IBAction)actShowDownloadFolderAdvanedSetting:(id)sender;
- (IBAction)actShowSquashCMAdvanedSetting:(id)sender;

- (IBAction)actGoBackForwardByDeleteKeyCB:(id)sender;

@end

