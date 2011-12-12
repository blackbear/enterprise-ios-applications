#import <Foundation/Foundation.h>
#import "USAdditions.h"
#import <libxml/tree.h>
#import "USGlobals.h"
@class WeatherForecastSvc_GetWeatherByZipCode;
@class WeatherForecastSvc_GetWeatherByZipCodeResponse;
@class WeatherForecastSvc_WeatherForecasts;
@class WeatherForecastSvc_ArrayOfWeatherData;
@class WeatherForecastSvc_WeatherData;
@class WeatherForecastSvc_GetWeatherByPlaceName;
@class WeatherForecastSvc_GetWeatherByPlaceNameResponse;
@interface WeatherForecastSvc_GetWeatherByZipCode : NSObject {
	
/* elements */
	NSString * ZipCode;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (WeatherForecastSvc_GetWeatherByZipCode *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (retain) NSString * ZipCode;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface WeatherForecastSvc_WeatherData : NSObject {
	
/* elements */
	NSString * Day;
	NSString * WeatherImage;
	NSString * MaxTemperatureF;
	NSString * MinTemperatureF;
	NSString * MaxTemperatureC;
	NSString * MinTemperatureC;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (WeatherForecastSvc_WeatherData *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (retain) NSString * Day;
@property (retain) NSString * WeatherImage;
@property (retain) NSString * MaxTemperatureF;
@property (retain) NSString * MinTemperatureF;
@property (retain) NSString * MaxTemperatureC;
@property (retain) NSString * MinTemperatureC;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface WeatherForecastSvc_ArrayOfWeatherData : NSObject {
	
/* elements */
	NSMutableArray *WeatherData;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (WeatherForecastSvc_ArrayOfWeatherData *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
- (void)addWeatherData:(WeatherForecastSvc_WeatherData *)toAdd;
@property (readonly) NSMutableArray * WeatherData;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface WeatherForecastSvc_WeatherForecasts : NSObject {
	
/* elements */
	NSNumber * Latitude;
	NSNumber * Longitude;
	NSNumber * AllocationFactor;
	NSString * FipsCode;
	NSString * PlaceName;
	NSString * StateCode;
	NSString * Status;
	WeatherForecastSvc_ArrayOfWeatherData * Details;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (WeatherForecastSvc_WeatherForecasts *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (retain) NSNumber * Latitude;
@property (retain) NSNumber * Longitude;
@property (retain) NSNumber * AllocationFactor;
@property (retain) NSString * FipsCode;
@property (retain) NSString * PlaceName;
@property (retain) NSString * StateCode;
@property (retain) NSString * Status;
@property (retain) WeatherForecastSvc_ArrayOfWeatherData * Details;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface WeatherForecastSvc_GetWeatherByZipCodeResponse : NSObject {
	
/* elements */
	WeatherForecastSvc_WeatherForecasts * GetWeatherByZipCodeResult;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (WeatherForecastSvc_GetWeatherByZipCodeResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (retain) WeatherForecastSvc_WeatherForecasts * GetWeatherByZipCodeResult;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface WeatherForecastSvc_GetWeatherByPlaceName : NSObject {
	
/* elements */
	NSString * PlaceName;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (WeatherForecastSvc_GetWeatherByPlaceName *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (retain) NSString * PlaceName;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface WeatherForecastSvc_GetWeatherByPlaceNameResponse : NSObject {
	
/* elements */
	WeatherForecastSvc_WeatherForecasts * GetWeatherByPlaceNameResult;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (WeatherForecastSvc_GetWeatherByPlaceNameResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (retain) WeatherForecastSvc_WeatherForecasts * GetWeatherByPlaceNameResult;
/* attributes */
- (NSDictionary *)attributes;
@end
/* Cookies handling provided by http://en.wikibooks.org/wiki/Programming:WebObjects/Web_Services/Web_Service_Provider */
#import <libxml/parser.h>
#import "xsd.h"
#import "WeatherForecastSvc.h"
@class WeatherForecastSoapBinding;
@class WeatherForecastSoap12Binding;
@interface WeatherForecastSvc : NSObject {
	
}
+ (WeatherForecastSoapBinding *)WeatherForecastSoapBinding;
+ (WeatherForecastSoap12Binding *)WeatherForecastSoap12Binding;
@end
@class WeatherForecastSoapBindingResponse;
@class WeatherForecastSoapBindingOperation;
@protocol WeatherForecastSoapBindingResponseDelegate <NSObject>
- (void) operation:(WeatherForecastSoapBindingOperation *)operation completedWithResponse:(WeatherForecastSoapBindingResponse *)response;
@end
@interface WeatherForecastSoapBinding : NSObject <WeatherForecastSoapBindingResponseDelegate> {
	NSURL *address;
	NSTimeInterval defaultTimeout;
	NSMutableArray *cookies;
	BOOL logXMLInOut;
	BOOL synchronousOperationComplete;
	NSString *authUsername;
	NSString *authPassword;
}
@property (copy) NSURL *address;
@property (assign) BOOL logXMLInOut;
@property (assign) NSTimeInterval defaultTimeout;
@property (nonatomic, retain) NSMutableArray *cookies;
@property (nonatomic, retain) NSString *authUsername;
@property (nonatomic, retain) NSString *authPassword;
- (id)initWithAddress:(NSString *)anAddress;
- (void)sendHTTPCallUsingBody:(NSString *)body soapAction:(NSString *)soapAction forOperation:(WeatherForecastSoapBindingOperation *)operation;
- (void)addCookie:(NSHTTPCookie *)toAdd;
- (WeatherForecastSoapBindingResponse *)GetWeatherByZipCodeUsingParameters:(WeatherForecastSvc_GetWeatherByZipCode *)aParameters ;
- (void)GetWeatherByZipCodeAsyncUsingParameters:(WeatherForecastSvc_GetWeatherByZipCode *)aParameters  delegate:(id<WeatherForecastSoapBindingResponseDelegate>)responseDelegate;
- (WeatherForecastSoapBindingResponse *)GetWeatherByPlaceNameUsingParameters:(WeatherForecastSvc_GetWeatherByPlaceName *)aParameters ;
- (void)GetWeatherByPlaceNameAsyncUsingParameters:(WeatherForecastSvc_GetWeatherByPlaceName *)aParameters  delegate:(id<WeatherForecastSoapBindingResponseDelegate>)responseDelegate;
@end
@interface WeatherForecastSoapBindingOperation : NSOperation {
	WeatherForecastSoapBinding *binding;
	WeatherForecastSoapBindingResponse *response;
	id<WeatherForecastSoapBindingResponseDelegate> delegate;
	NSMutableData *responseData;
	NSURLConnection *urlConnection;
}
@property (retain) WeatherForecastSoapBinding *binding;
@property (readonly) WeatherForecastSoapBindingResponse *response;
@property (nonatomic, assign) id<WeatherForecastSoapBindingResponseDelegate> delegate;
@property (nonatomic, retain) NSMutableData *responseData;
@property (nonatomic, retain) NSURLConnection *urlConnection;
- (id)initWithBinding:(WeatherForecastSoapBinding *)aBinding delegate:(id<WeatherForecastSoapBindingResponseDelegate>)aDelegate;
@end
@interface WeatherForecastSoapBinding_GetWeatherByZipCode : WeatherForecastSoapBindingOperation {
	WeatherForecastSvc_GetWeatherByZipCode * parameters;
}
@property (retain) WeatherForecastSvc_GetWeatherByZipCode * parameters;
- (id)initWithBinding:(WeatherForecastSoapBinding *)aBinding delegate:(id<WeatherForecastSoapBindingResponseDelegate>)aDelegate
	parameters:(WeatherForecastSvc_GetWeatherByZipCode *)aParameters
;
@end
@interface WeatherForecastSoapBinding_GetWeatherByPlaceName : WeatherForecastSoapBindingOperation {
	WeatherForecastSvc_GetWeatherByPlaceName * parameters;
}
@property (retain) WeatherForecastSvc_GetWeatherByPlaceName * parameters;
- (id)initWithBinding:(WeatherForecastSoapBinding *)aBinding delegate:(id<WeatherForecastSoapBindingResponseDelegate>)aDelegate
	parameters:(WeatherForecastSvc_GetWeatherByPlaceName *)aParameters
;
@end
@interface WeatherForecastSoapBinding_envelope : NSObject {
}
+ (WeatherForecastSoapBinding_envelope *)sharedInstance;
- (NSString *)serializedFormUsingHeaderElements:(NSDictionary *)headerElements bodyElements:(NSDictionary *)bodyElements;
@end
@interface WeatherForecastSoapBindingResponse : NSObject {
	NSArray *headers;
	NSArray *bodyParts;
	NSError *error;
}
@property (retain) NSArray *headers;
@property (retain) NSArray *bodyParts;
@property (retain) NSError *error;
@end
@class WeatherForecastSoap12BindingResponse;
@class WeatherForecastSoap12BindingOperation;
@protocol WeatherForecastSoap12BindingResponseDelegate <NSObject>
- (void) operation:(WeatherForecastSoap12BindingOperation *)operation completedWithResponse:(WeatherForecastSoap12BindingResponse *)response;
@end
@interface WeatherForecastSoap12Binding : NSObject <WeatherForecastSoap12BindingResponseDelegate> {
	NSURL *address;
	NSTimeInterval defaultTimeout;
	NSMutableArray *cookies;
	BOOL logXMLInOut;
	BOOL synchronousOperationComplete;
	NSString *authUsername;
	NSString *authPassword;
}
@property (copy) NSURL *address;
@property (assign) BOOL logXMLInOut;
@property (assign) NSTimeInterval defaultTimeout;
@property (nonatomic, retain) NSMutableArray *cookies;
@property (nonatomic, retain) NSString *authUsername;
@property (nonatomic, retain) NSString *authPassword;
- (id)initWithAddress:(NSString *)anAddress;
- (void)sendHTTPCallUsingBody:(NSString *)body soapAction:(NSString *)soapAction forOperation:(WeatherForecastSoap12BindingOperation *)operation;
- (void)addCookie:(NSHTTPCookie *)toAdd;
- (WeatherForecastSoap12BindingResponse *)GetWeatherByZipCodeUsingParameters:(WeatherForecastSvc_GetWeatherByZipCode *)aParameters ;
- (void)GetWeatherByZipCodeAsyncUsingParameters:(WeatherForecastSvc_GetWeatherByZipCode *)aParameters  delegate:(id<WeatherForecastSoap12BindingResponseDelegate>)responseDelegate;
- (WeatherForecastSoap12BindingResponse *)GetWeatherByPlaceNameUsingParameters:(WeatherForecastSvc_GetWeatherByPlaceName *)aParameters ;
- (void)GetWeatherByPlaceNameAsyncUsingParameters:(WeatherForecastSvc_GetWeatherByPlaceName *)aParameters  delegate:(id<WeatherForecastSoap12BindingResponseDelegate>)responseDelegate;
@end
@interface WeatherForecastSoap12BindingOperation : NSOperation {
	WeatherForecastSoap12Binding *binding;
	WeatherForecastSoap12BindingResponse *response;
	id<WeatherForecastSoap12BindingResponseDelegate> delegate;
	NSMutableData *responseData;
	NSURLConnection *urlConnection;
}
@property (retain) WeatherForecastSoap12Binding *binding;
@property (readonly) WeatherForecastSoap12BindingResponse *response;
@property (nonatomic, assign) id<WeatherForecastSoap12BindingResponseDelegate> delegate;
@property (nonatomic, retain) NSMutableData *responseData;
@property (nonatomic, retain) NSURLConnection *urlConnection;
- (id)initWithBinding:(WeatherForecastSoap12Binding *)aBinding delegate:(id<WeatherForecastSoap12BindingResponseDelegate>)aDelegate;
@end
@interface WeatherForecastSoap12Binding_GetWeatherByZipCode : WeatherForecastSoap12BindingOperation {
	WeatherForecastSvc_GetWeatherByZipCode * parameters;
}
@property (retain) WeatherForecastSvc_GetWeatherByZipCode * parameters;
- (id)initWithBinding:(WeatherForecastSoap12Binding *)aBinding delegate:(id<WeatherForecastSoap12BindingResponseDelegate>)aDelegate
	parameters:(WeatherForecastSvc_GetWeatherByZipCode *)aParameters
;
@end
@interface WeatherForecastSoap12Binding_GetWeatherByPlaceName : WeatherForecastSoap12BindingOperation {
	WeatherForecastSvc_GetWeatherByPlaceName * parameters;
}
@property (retain) WeatherForecastSvc_GetWeatherByPlaceName * parameters;
- (id)initWithBinding:(WeatherForecastSoap12Binding *)aBinding delegate:(id<WeatherForecastSoap12BindingResponseDelegate>)aDelegate
	parameters:(WeatherForecastSvc_GetWeatherByPlaceName *)aParameters
;
@end
@interface WeatherForecastSoap12Binding_envelope : NSObject {
}
+ (WeatherForecastSoap12Binding_envelope *)sharedInstance;
- (NSString *)serializedFormUsingHeaderElements:(NSDictionary *)headerElements bodyElements:(NSDictionary *)bodyElements;
@end
@interface WeatherForecastSoap12BindingResponse : NSObject {
	NSArray *headers;
	NSArray *bodyParts;
	NSError *error;
}
@property (retain) NSArray *headers;
@property (retain) NSArray *bodyParts;
@property (retain) NSError *error;
@end
