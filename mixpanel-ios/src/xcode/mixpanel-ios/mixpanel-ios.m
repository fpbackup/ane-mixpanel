#import "mixpanel-ios.h"

#define MIXPANEL_TOKEN @"YOUR_TOKEN"

FREContext AirContext = nil;

void *SelfReference;

NSArray * avaiableProducts = nil;

BOOL hasTransactionObserver = NO;

BOOL isPurchasedItemsQuery = NO;

@implementation InAppPurchase_iOS

//////////////////////////////////////////////////////////////////////////////////////
// INITIALIZATION
//////////////////////////////////////////////////////////////////////////////////////

- (id) init
{    
    self = [super init];
    if (self)
    {
        SelfReference = self;
    }
    return self;
}

// this is called when the extension context is created.
void InAppPurchaseContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet)
{
    *numFunctionsToTest = 1;
    
    FRENamedFunction* func = (FRENamedFunction*) malloc(sizeof(FRENamedFunction) * *numFunctionsToTest);
    
    func[0].name = (const uint8_t*) "getProductInfo";
    func[0].functionData = NULL;
    func[0].function = &getProductsInfo;

    
    *functionsToSet = func;
    
    AirContext = ctx;
    
    if ((InAppPurchase_iOS*)SelfReference == nil)
    {
        SelfReference = [[InAppPurchase_iOS alloc] init];
    }
    
}

// This method will set which methods to call when doing the actual initialization.
// The initializer node in the iPhone-ARM platform of the extension.xml file must have the same name as this function
void InAppPurchaseInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet)
{
    *extDataToSet = NULL;
    *ctxInitializerToSet = &InAppPurchaseContextInitializer;
}


//////////////////////////////////////////////////////////////////////////////////////
// PRODUCT INFO
//////////////////////////////////////////////////////////////////////////////////////

// get what is avaiable to purchase and its details
FREObject getProductsInfo(FREContext context, void* functionData, uint32_t argc, FREObject argv[])
{
    [(InAppPurchase_iOS*)SelfReference logDebug: @"Getting product info"];
    
    FREObject arr = argv[0];
    uint32_t arr_len;
    FREGetArrayLength(arr, &arr_len);
    
    NSMutableSet* productsIdentifiers = [[[NSMutableSet alloc] init] autorelease];
    
    for(int32_t i=arr_len-1; i>=0;i--)
    {
        FREObject element;
        FREGetArrayElementAt(arr, i, &element);
        
        // convert it to NSString
        uint32_t stringLength;
        const uint8_t *string;
        FREGetObjectAsUTF8(element, &stringLength, &string);
        NSString *productIdentifier = [NSString stringWithUTF8String:(char*)string];
        
        [productsIdentifiers addObject:productIdentifier];
    }
    
    if (avaiableProducts != nil)
    {
        [avaiableProducts release];
        avaiableProducts = nil;
    }
    return nil;
}

//////////////////////////////////////////////////////////////////////////////////////
// DESTRUCTOR
//////////////////////////////////////////////////////////////////////////////////////

-(void)dealloc
{
    NSLog(@"Purchase library: Deallocating");
    hasTransactionObserver = NO;
    SelfReference = nil;
    if (avaiableProducts != nil)
    {
        [avaiableProducts release];
        avaiableProducts = nil;
    }
    [super dealloc];
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