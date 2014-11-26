#import <Foundation/Foundation.h>

#import "FlashRuntimeExtensions.h"
#import "Mixpanel.h"

@interface MixpanelFlashLibrary : NSObject

- (NSString *) dataToJSON:(id) data;

- (void)logDebug:(NSString *) str;

@end