//
//  STSafariConnect.h
//  SafariStand


@import AppKit;
@import WebKit;


//飛ぶ
//0==普通 1==普通うしろ
//2==新規ウィンドウ  5==新規ウィンドウうしろ
//4==tab 5==tabうしろ

//8.0
//0==普通 1==普通うしろ？
//2==新規ウィンドウ
//3==プライベートウィンドウ
//4==新規ウィンドウうしろ
//5==tab前
//6==tabうしろ

//9.0
//0==普通 1==普通うしろ？
//2==新規ウィンドウ
//3==新規ウィンドウ?
//4==プライベートウィンドウ新規ウィンドウ
//5==新規ウィンドウうしろ
//6==tab
//7==tabうしろ
//8==tab or existing blank tab

//check command
//po STSafariGoToURLWithPolicy((id)[NSURL URLWithString:@"http://127.0.0.1/"], 1);

enum safariWindowPolicy {
    poNormal=0, //000
    poNormal_back=1, //001
    poNewWindow=2, //010
    poNewWindow_back=5, //011
    poNewTab=6, //100
    poNewTab_back=7, //101
    poNewPrivateWindow=4
};

enum webbookmarktype {
    wbInvalid = -1,
    wbBookmark = 0,
    wbFolder = 1
};

struct TabPlacementHint {
    void * m_browserWindowController;
    void * m_browserContentViewController;
    _Bool m_contentViewIsAncestorTab;
};
typedef struct TabPlacementHint TabPlacementHint;

struct BrowserContentViewController {
};
typedef struct BrowserContentViewController BrowserContentViewController;

#define kSafariBrowserWindowController @"BrowserWindowController"
#define kSafariBrowserWindowControllerCstr "BrowserWindowController"
#define BrowserWindowControllerMacTabsInWindowDidChangeNotification @"BrowserWindowControllerMacTabsInWindowDidChangeNotification"

#define kSafariURLWindowPolicyDecider @"URLWindowPolicyDecider" //Safari 8

/*

STSafariEnumerateBrowserWindow(^(NSWindow* win, NSWindowController* winCtl, BOOL* stop){
    *stop=YES;
});

 */
void STSafariEnumerateBrowserWindow( void(^blk)(NSWindow* window, NSWindowController* winCtl, BOOL* stop) );

/*

STSafariEnumerateBrowserTabViewItem(^(NSTabViewItem* tabViewItem, BOOL* stop){
    *stop=YES;
});
 
 */
void STSafariEnumerateBrowserTabViewItem( void(^blk)(NSTabViewItem* tabViewItem, BOOL* stop) );
void STSafariEnumerateTabButton( void(^blk)(NSButton* tabBtn, BOOL* stop) );



NSString* STSafariWebpagePreviewsPath();
NSString* STSafariThumbnailForURLString(NSString* URLString, NSString* ext);

BOOL STSafariOpenNewTabsInFront();
int STSafariWindowPolicyNewTab();
int STSafariWindowPolicyNewTabRespectingCurrentEvent();
int STSafariWindowPolicyFromCurrentEvent();

void STSafariGoToURL(NSURL* url);
void STSafariGoToURLWithPolicy(NSURL* url, int policy);
void STSafariGoToURLWithPolicyAndPlacementHint(NSURL* url, int policy, TabPlacementHint placementHint);
void STSafariGoToRequestWithPolicy(NSURLRequest* req, int policy);

NSString* STSafariDownloadDestinationWithFileName(NSString* fileName);
void STSafariDownloadURL(NSURL* url, BOOL removeEntryWhenDone);
void STSafariDownloadRequest(NSURLRequest* req, BOOL removeEntryWhenDone);
void STSafariDownloadURLWithFileName(NSURL* url, NSString* fileName);
void STSafariDownloadRequestWithFileName(NSURLRequest* req, NSString* fileName);

//Safari
void STSafariNewTabAction();
NSTabViewItem* STSafariCreateWKViewOrWebViewAtIndexAndShow(id winCtl, NSInteger idx, BOOL show);
NSTabViewItem* STSafariCreateEmptyTab();
void STSafariCreateTabForURLAtIndex(NSURL *url, NSInteger index);

id STSafariCurrentDocument();
NSWindow* STSafariCurrentBrowserWindow();
id STSafariCurrentTitle();
id STSafariCurrentURLString();
id STSafariCurrentWKView();
id STSafariWKViewForTabViewItem(id tabViewItem);
void* STSafariStructBrowserTabForTabViewItem(id tabViewItem);
id STSafariTabViewItemForWKView(id wkView);
NSTabView* STSafariTabViewForWindow(NSWindow* win);
NSTabView* STSafariTabViewForBrowserWindowCtl(id winCtl);
NSView* /* TabContentView */ STSafariTabContentViewForTabView(NSView* tabView);

void STSafariMoveTabViewItemToIndex(id tabViewItem, NSInteger idx);
void STSafariMoveTabToNewWindow(NSTabViewItem* item);
void STSafariMoveTabToOtherWindow(NSTabViewItem* itemToMove, NSWindow* destWindow, NSInteger destIndex, BOOL show);
void STSafariReloadTab(NSTabViewItem* item);
BOOL STSafariCanReloadTab(NSTabViewItem* item);

id STSafariBrowserWindowControllerForWKView(id wkView);
id STSafariBrowserWindowControllerForDocument(id doc);
BOOL STSafariUsesWebKit2(id anyObject);
id STTabSwitcherForWinCtl(id winCtl);

NSInteger STSafariSelectedTabIndexForWindow(NSWindow* win);

NSImage* STSafariBundleImageNamed(NSString* name);
NSImage* STSafariBundleBookmarkImage();
NSImage* STSafariBundleHistoryImage();
NSImage* STSafariBundleReadinglistmage();

//WebBookmark, WebBookmarkLeaf

void STSafariAddSearchStringHistory(NSString* str);

const char* STSafariBookmarksControllerClass();
int STSafariWebBookmarkType(id webBookmark);
NSString* STSafariWebBookmarkURLString(id webBookmark);
NSString* STSafariWebBookmarkTitle(id webBookmark);
NSImage* STSafariWebBookmarkIcon(id webBookmark);
NSString* STSafariWebBookmarkUUID(id webBookmark);

id STSafariQuickWebsiteSearchController();
NSArray* STSafariQuickWebsiteSearchItems();
