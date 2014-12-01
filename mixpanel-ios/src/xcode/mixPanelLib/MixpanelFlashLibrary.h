#import <Foundation/Foundation.h>

#import "FlashRuntimeExtensions.h"
#import "Mixpanel.h"

@interface MixpanelFlashLibrary : NSObject <UIApplicationDelegate>

- (NSString *) dataToJSON:(id) data;

- (void)logDebug:(NSString *) str;

@end


FREObject initWithToken(FREContext context, void* functionData, uint32_t argc, FREObject argv[]);
FREObject identify(FREContext context, void* functionData, uint32_t argc, FREObject argv[]);
FREObject createAlias(FREContext context, void* functionData, uint32_t argc, FREObject argv[]);
FREObject track(FREContext context, void* functionData, uint32_t argc, FREObject argv[]);
FREObject registerForRemoteNotifications(FREContext context, void* functionData, uint32_t argc, FREObject argv[]);


void didRegisterForRemoteNotificationsWithDeviceToken(id self, SEL _cmd, UIApplication* application, NSData* deviceToken);
void didFailToRegisterForRemoteNotificationsWithError(id self, SEL _cmd, UIApplication* application, NSError* error);
void didReceiveRemoteNotification(id self, SEL _cmd, UIApplication* application,NSDictionary *userInfo);
void didRegisterUserNotificationSettings(id self, SEL _cmd, UIApplication * application, UIUserNotificationSettings *notificationSettings);
//void handleActionWithIdentifier(id self, SEL _cmd, UIApplication * application, NSString* identifier, NSDictionary* userInfo, void(^)() completionHandler);
