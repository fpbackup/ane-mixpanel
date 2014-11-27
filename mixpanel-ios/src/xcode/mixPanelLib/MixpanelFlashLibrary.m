#import "MixpanelFlashLibrary.h"

FREContext AirContext = nil;

void *SelfReference;

@implementation MixpanelFlashLibrary

//////////////////////////////////////////////////////////////////////////////////////
// INITIALIZATION
//////////////////////////////////////////////////////////////////////////////////////

- (id) init
{    
    self = [super init];
    if (self)
    {
        SelfReference = (__bridge void *)(self);
    }
    NSLog(@"MixPanel library: init");
    return self;
}

// this is called when the extension context is created.
void ContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet)
{
     NSLog(@"MixPanel library: init context");
    *numFunctionsToTest = 2;
    
    FRENamedFunction* func = (FRENamedFunction*) malloc(sizeof(FRENamedFunction) * *numFunctionsToTest);
    
    func[0].name = (const uint8_t*) "initWithToken";
    func[0].functionData = NULL;
    func[0].function = &initWithToken;
    
    func[1].name = (const uint8_t*) "track";
    func[1].functionData = NULL;
    func[1].function = &track;
    
    *functionsToSet = func;
    
    AirContext = ctx;
    
    if ((__bridge MixpanelFlashLibrary*)SelfReference == nil)
    {
        SelfReference = (__bridge void *)([[MixpanelFlashLibrary alloc] init]);
    }
    
}

// This method will set which methods to call when doing the actual initialization.
// The initializer node in the iPhone-ARM platform of the extension.xml file must have the same name as this function
void MixpanelLibInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet)
{
    NSLog(@"MixPanel library: init lib");

    *extDataToSet = NULL;
    *ctxInitializerToSet = &ContextInitializer;
}

//////////////////////////////////////////////////////////////////////////////////////
// INIT
//////////////////////////////////////////////////////////////////////////////////////

FREObject initWithToken(FREContext context, void* functionData, uint32_t argc, FREObject argv[])
{
    [(__bridge MixpanelFlashLibrary*)SelfReference logDebug: @"initializing"];
    uint32_t stringLength;
    
    const uint8_t *input;
    FREGetObjectAsUTF8(argv[0], &stringLength, &input);
    NSString *mixPanelToken = [NSString stringWithUTF8String:(char*)input];
    
    [Mixpanel sharedInstanceWithToken:mixPanelToken];
    return nil;
}

//////////////////////////////////////////////////////////////////////////////////////
// SEND EVENT
//////////////////////////////////////////////////////////////////////////////////////

FREObject track(FREContext context, void* functionData, uint32_t argc, FREObject argv[])
{
    [(__bridge MixpanelFlashLibrary*)SelfReference logDebug: @"track event"];
    uint32_t stringLength;
    
    const uint8_t *eventNameRaw;
    FREGetObjectAsUTF8(argv[1], &stringLength, &eventNameRaw);
    NSString *eventName = [NSString stringWithUTF8String:(char*)eventNameRaw];
    
    const uint8_t *propsRaw;
    FREGetObjectAsUTF8(argv[0], &stringLength, &propsRaw);
    NSString *properties = [NSString stringWithUTF8String:(char*)propsRaw];
    NSError * err;
    NSDictionary *props = [NSJSONSerialization JSONObjectWithData: [properties dataUsingEncoding:NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: &err];
    if (err != nil)
    {
        FREDispatchStatusEventAsync(context, (uint8_t*) "TRACK_ERROR", (uint8_t*)[@"Cannot parse JSON received from Flash." UTF8String]);
        return nil;

    }
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
    [mixpanel track:eventName properties:props];
    return nil;
}

//////////////////////////////////////////////////////////////////////////////////////
// DESTRUCTOR
//////////////////////////////////////////////////////////////////////////////////////

-(void)dealloc
{
    NSLog(@"MixPanel library: Deallocating");
    SelfReference = nil;
}

//////////////////////////////////////////////////////////////////////////////////////
// MISC
//////////////////////////////////////////////////////////////////////////////////////

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
    FREDispatchStatusEventAsync(AirContext ,(uint8_t*) "DEBUG", (uint8_t*) [str UTF8String] );
}

@end