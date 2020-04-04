#import "cocos2d.h"
#import "BrowserViewController.h"

@interface Picker : CCLayerColor {
	CCLabelTTF *_gameNameLabel;
	BrowserViewController *_bvc;
}

@property (nonatomic, assign) id<BrowserViewControllerDelegate> delegate;
@property (nonatomic, copy) NSString *gameName;

- (id)initWithType:(NSString *)type;
- (void)onBack:(id)sender;

@end
