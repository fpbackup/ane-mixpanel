#import <Foundation/Foundation.h>

#import "FlashRuntimeExtensions.h"
#import "Mixpanel.h"

@interface MixpanelFlashLibrary : NSObject <UIApplicationDelegate>

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error;

- (NSString *) dataToJSON:(id) data;

- (void)logDebug:(NSString *) str;

@end

