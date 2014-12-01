#import "MixpanelFlashLibrary.h"
#import <objc/runtime.h>
#import <objc/message.h>

FREContext AirContext = nil;

void *SelfReference;

@implementation MixpanelFlashLibrary

//empty delegate functions, stubbed signature is so we can find this method in the delegate and override it with our custom implementation
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings: (UIUserNotificationSettings *)notificationSettings{}

//- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
//{
//    NSLog(@"Received push notification");
//    if ([identifier isEqualToString:@"declineAction"]){ }
//    else if ([identifier isEqualToString:@"answerAction"]){ }
//}
#endif

-(NSString *)dataToJSON:(id)data
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:0 error:&error];
    if (!jsonData)
    {
        return [NSString stringWithFormat:@"ERROR Unable to parse JSON %@ %@", error.description, error.debugDescription];
    }
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

-(void)logDebug:(NSString *) str
{
    NSLog(str, nil);
    if ( AirContext != nil )
    {
        FREDispatchStatusEventAsync(AirContext ,(uint8_t*) "DEBUG", (uint8_t*) [str UTF8String] );
    }
}

@end
//////////////////////////////////////////////////////////////////////////////////////
// INITIALIZATION
//////////////////////////////////////////////////////////////////////////////////////

// this is called when the extension context is created.
void ContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet)
{
    NSLog(@"initializing context");
    
    //injects our modified delegate functions into the sharedApplication delegate
    
    id delegate = [[UIApplication sharedApplication] delegate];
    
    Class objectClass = object_getClass(delegate);
    
    NSString *newClassName = [NSString stringWithFormat:@"Custom_%@", NSStringFromClass(objectClass)];
    Class modDelegate = NSClassFromString(newClassName);
    if (modDelegate == nil) {
        // this class doesn't exist; create it
        modDelegate = objc_allocateClassPair(objectClass, [newClassName UTF8String], 0);
        
        SEL selectorToOverride1 = @selector(application:didRegisterForRemoteNotificationsWithDeviceToken:);
        SEL selectorToOverride2 = @selector(application:didFailToRegisterForRemoteNotificationsWithError:);
        SEL selectorToOverride3 = @selector(application:didReceiveRemoteNotification:);
        
        #if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
        SEL selectorToOverride4 = @selector(application:didRegisterUserNotificationSettings:);
        #endif
        
        // get the info on the method we're going to override
        Method m1 = class_getInstanceMethod(objectClass, selectorToOverride1);
        Method m2 = class_getInstanceMethod(objectClass, selectorToOverride2);
        Method m3 = class_getInstanceMethod(objectClass, selectorToOverride3);
        #if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
        Method m4 = class_getInstanceMethod(objectClass, selectorToOverride4);
        #endif
        // add the method to the new class
        class_addMethod(modDelegate, selectorToOverride1, (IMP)didRegisterForRemoteNotificationsWithDeviceToken, method_getTypeEncoding(m1));
        class_addMethod(modDelegate, selectorToOverride2, (IMP)didFailToRegisterForRemoteNotificationsWithError, method_getTypeEncoding(m2));
        class_addMethod(modDelegate, selectorToOverride3, (IMP)didReceiveRemoteNotification, method_getTypeEncoding(m3));
        #if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
        class_addMethod(modDelegate, selectorToOverride4, (IMP)didRegisterUserNotificationSettings, method_getTypeEncoding(m4));
        #endif
        // register the new class with the runtime
        objc_registerClassPair(modDelegate);
    }
    // change the class of the object
    object_setClass(delegate, modDelegate);
    
    ///////// end of delegate injection / modification code
    
    *numFunctionsToTest = 5;
    
    FRENamedFunction* func = (FRENamedFunction*) malloc(sizeof(FRENamedFunction) * *numFunctionsToTest);
    
    func[0].name = (const uint8_t*) "initWithToken";
    func[0].functionData = NULL;
    func[0].function = &initWithToken;
    
    func[1].name = (const uint8_t*) "track";
    func[1].functionData = NULL;
    func[1].function = &track;
    
    func[2].name = (const uint8_t*) "registerForRemoteNotifications";
    func[2].functionData = NULL;
    func[2].function = &registerForRemoteNotifications;
    
    func[3].name = (const uint8_t*) "identify";
    func[3].functionData = NULL;
    func[3].function = &identify;
    
    func[4].name = (const uint8_t*) "createAlias";
    func[4].functionData = NULL;
    func[4].function = &createAlias;
    *functionsToSet = func;
    
    AirContext = ctx;
    
    if ((MixpanelFlashLibrary*)SelfReference == nil)
    {
        SelfReference = (void *)([[MixpanelFlashLibrary alloc] init]);
    }
    
}

// This method will set which methods to call when doing the actual initialization.
// The initializer node in the iPhone-ARM platform of the extension.xml file must have the same name as this function
void MixpanelLibInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet)
{
    *extDataToSet = NULL;
    *ctxInitializerToSet = &ContextInitializer;
}

//////////////////////////////////////////////////////////////////////////////////////
// INIT
//////////////////////////////////////////////////////////////////////////////////////

FREObject initWithToken(FREContext context, void* functionData, uint32_t argc, FREObject argv[])
{
    [(MixpanelFlashLibrary*)SelfReference logDebug: @"initializing with token"];
    uint32_t stringLength;
    
    const uint8_t *input;
    FREGetObjectAsUTF8(argv[0], &stringLength, &input);
    NSString *mixPanelToken = [NSString stringWithUTF8String:(char*)input];
    
    [Mixpanel sharedInstanceWithToken:mixPanelToken];
    return nil;
}

//////////////////////////////////////////////////////////////////////////////////////
// IDENTIFY
//////////////////////////////////////////////////////////////////////////////////////

// should be called on each app startup
FREObject identify(FREContext context, void* functionData, uint32_t argc, FREObject argv[])
{
    [(MixpanelFlashLibrary*)SelfReference logDebug: @"Identify user"];
    uint32_t stringLength;
    
    const uint8_t *input;
    FREGetObjectAsUTF8(argv[0], &stringLength, &input);
    NSString *userID = [NSString stringWithUTF8String:(char*)input];
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    // Associate all future events sent from the library with the user ID
    [mixpanel identify:userID];
    return nil;
}

//////////////////////////////////////////////////////////////////////////////////////
// CREATE ALIAS
//////////////////////////////////////////////////////////////////////////////////////

// should be called on the first startup
FREObject createAlias(FREContext context, void* functionData, uint32_t argc, FREObject argv[])
{
    [(MixpanelFlashLibrary*)SelfReference logDebug: @"Create alias"];
    uint32_t stringLength;
    
    const uint8_t *input;
    FREGetObjectAsUTF8(argv[0], &stringLength, &input);
    NSString *userID = [NSString stringWithUTF8String:(char*)input];
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    // This makes the current ID (an auto-generated GUID) and userID interchangeable distinct ids.
    [mixpanel createAlias:userID forDistinctID:mixpanel.distinctId];
    
    return nil;
}

//////////////////////////////////////////////////////////////////////////////////////
// TRACK
//////////////////////////////////////////////////////////////////////////////////////

FREObject track(FREContext context, void* functionData, uint32_t argc, FREObject argv[])
{
    [(MixpanelFlashLibrary*)SelfReference logDebug: @"track event"];
    
    uint32_t nameLength;
    const uint8_t *eventNameRaw;
    FREGetObjectAsUTF8(argv[0], &nameLength, &eventNameRaw);
    NSString *eventName = [NSString stringWithUTF8String:(char*)eventNameRaw];
    
    uint32_t stringLength;
    const uint8_t *propsRaw;
    FREGetObjectAsUTF8(argv[1], &stringLength, &propsRaw);
    NSString *properties = [NSString stringWithUTF8String:(char*)propsRaw];
    NSError * err;
    NSDictionary *props = [NSJSONSerialization JSONObjectWithData: [properties dataUsingEncoding:NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: &err];
    if (!props)
    {
        NSString * errStr = [NSString stringWithFormat:@"%@,%@", @"Cannot parse JSON received from Flash.", [err debugDescription]];
        NSLog(@"Error parsing JSON: %@", err);
        FREDispatchStatusEventAsync(context, (uint8_t*) "TRACK_ERROR", (uint8_t*)[errStr UTF8String]);
        return nil;
    }
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
    [mixpanel track:eventName properties:props];
    return nil;
}

//////////////////////////////////////////////////////////////////////////////////////
// REGISTER FOR PUSH NOTIFICATIONS
//////////////////////////////////////////////////////////////////////////////////////

FREObject registerForRemoteNotifications(FREContext context, void* functionData, uint32_t argc, FREObject argv[])
{
    [(MixpanelFlashLibrary*)SelfReference logDebug: @"Register for remote notifications"];
    NSLog(@"registerForRemoteNotifications");
    #if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
        UIUserNotificationSettings* settings = [UIUserNotificationSettings settingsForTypes:
                                            UIUserNotificationTypeAlert |
                                            UIUserNotificationTypeBadge |
                                            UIUserNotificationTypeSound categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    #else
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeBadge |
          UIRemoteNotificationTypeSound |
          UIRemoteNotificationTypeAlert)];
     #endif
    
    return nil;
}

void didRegisterForRemoteNotificationsWithDeviceToken(id self, SEL _cmd, UIApplication* application, NSData* deviceToken)
{
    NSLog(@"Registering for remote notifications success");
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel.people addPushDeviceToken:deviceToken];
    
    NSString* tokenString = [NSString stringWithFormat:@"%@", deviceToken];
    
    if ( AirContext != nil )
    {
        FREDispatchStatusEventAsync(AirContext, (uint8_t*) "REMOTE_NOTIFICATIONS_REGISTER_SUCCESS", (uint8_t*)[tokenString UTF8String]);
    }
}

void didFailToRegisterForRemoteNotificationsWithError(id self, SEL _cmd, UIApplication* application, NSError* error)
{
    
    NSLog(@"Failed to register for push notifications");
    
    if ( AirContext != nil )
    {
        FREDispatchStatusEventAsync(AirContext, (uint8_t*)"REMOTE_NOTIFICATIONS_REGISTER_ERROR", (uint8_t*)[error description]);
    }
}

void didReceiveRemoteNotification(id self, SEL _cmd, UIApplication* application, NSDictionary *userInfo)
{
    NSLog(@"Received remote notification");
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
void didRegisterUserNotificationSettings(id self, SEL _cmd, UIApplication* application, UIUserNotificationSettings *notificationSettings)
{
    NSLog(@"Register for notifications");
    [application registerForRemoteNotifications];
}
#endif

