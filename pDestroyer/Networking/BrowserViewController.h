#import <cocos2d.h>
#import <Foundation/NSNetServices.h>

@class BrowserViewController;

@protocol BrowserViewControllerDelegate <NSObject>
@required
- (void) browserViewController:(BrowserViewController *)bvc didResolveInstance:(NSNetService *)ref;
@end

@interface BrowserViewController : CCNode <NSNetServiceDelegate, NSNetServiceBrowserDelegate> {
	id<BrowserViewControllerDelegate> delegate;
	NSNetService *ownEntry;
	NSMutableArray* services;
	NSNetServiceBrowser* netServiceBrowser;
	NSNetService* currentResolve;
    
    CCMenu* serviceList;
}

@property (nonatomic, assign) id<BrowserViewControllerDelegate> delegate;
@property (nonatomic, copy) NSString *ownName;

- (BOOL) searchForServicesOfType:(NSString *)type inDomain:(NSString *)domain;
- (void) updateService;
- (void) onSelect:(id)sender;

@end
