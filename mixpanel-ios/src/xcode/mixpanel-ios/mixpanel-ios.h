#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

#import "FlashRuntimeExtensions.h"
#import "Mixpanel.h"

@interface InAppPurchase_iOS : NSObject 

- (NSString *) dataToJSON:(id) data;

- (void)logDebug:(NSString *) str;

@end