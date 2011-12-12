#import <Foundation/Foundation.h>
#import "USAdditions.h"
#import <libxml/tree.h>
#import "USGlobals.h"
@class WeatherSvc_GetWeather;
@class WeatherSvc_GetWeatherResponse;
@interface WeatherSvc_GetWeather : NSObject {
	
/* elements */
	NSString * City;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (WeatherSvc_GetWeather *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (retain) NSString * City;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface WeatherSvc_GetWeatherResponse : NSObject {
	
/* elements */
	NSString * GetWeatherResult;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (WeatherSvc_GetWeatherResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (retain) NSString * GetWeatherResult;
/* attributes */
- (NSDictionary *)attributes;
@end
/* Cookies handling provided by http://en.wikibooks.org/wiki/Programming:WebObjects/Web_Services/Web_Service_Provider */
#import <libxml/parser.h>
#import "xsd.h"
#import "WeatherSvc.h"
@class WeatherSoapBinding;
@class WeatherSoap12Binding;
@interface WeatherSvc : NSObject {
	
}
+ (WeatherSoapBinding *)WeatherSoapBinding;
+ (WeatherSoap12Binding *)WeatherSoap12Binding;
@end
@class WeatherSoapBindingResponse;
@class WeatherSoapBindingOperation;
@protocol WeatherSoapBindingResponseDelegate <NSObject>
- (void) operation:(WeatherSoapBindingOperation *)operation completedWithResponse:(WeatherSoapBindingResponse *)response;
@end
@interface WeatherSoapBinding : NSObject <WeatherSoapBindingResponseDelegate> {
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
- (void)sendHTTPCallUsingBody:(NSString *)body soapAction:(NSString *)soapAction forOperation:(WeatherSoapBindingOperation *)operation;
- (void)addCookie:(NSHTTPCookie *)toAdd;
- (WeatherSoapBindingResponse *)GetWeatherUsingParameters:(WeatherSvc_GetWeather *)aParameters ;
- (void)GetWeatherAsyncUsingParameters:(WeatherSvc_GetWeather *)aParameters  delegate:(id<WeatherSoapBindingResponseDelegate>)responseDelegate;
@end
@interface WeatherSoapBindingOperation : NSOperation {
	WeatherSoapBinding *binding;
	WeatherSoapBindingResponse *response;
	id<WeatherSoapBindingResponseDelegate> delegate;
	NSMutableData *responseData;
	NSURLConnection *urlConnection;
}
@property (retain) WeatherSoapBinding *binding;
@property (readonly) WeatherSoapBindingResponse *response;
@property (nonatomic, assign) id<WeatherSoapBindingResponseDelegate> delegate;
@property (nonatomic, retain) NSMutableData *responseData;
@property (nonatomic, retain) NSURLConnection *urlConnection;
- (id)initWithBinding:(WeatherSoapBinding *)aBinding delegate:(id<WeatherSoapBindingResponseDelegate>)aDelegate;
@end
@interface WeatherSoapBinding_GetWeather : WeatherSoapBindingOperation {
	WeatherSvc_GetWeather * parameters;
}
@property (retain) WeatherSvc_GetWeather * parameters;
- (id)initWithBinding:(WeatherSoapBinding *)aBinding delegate:(id<WeatherSoapBindingResponseDelegate>)aDelegate
	parameters:(WeatherSvc_GetWeather *)aParameters
;
@end
@interface WeatherSoapBinding_envelope : NSObject {
}
+ (WeatherSoapBinding_envelope *)sharedInstance;
- (NSString *)serializedFormUsingHeaderElements:(NSDictionary *)headerElements bodyElements:(NSDictionary *)bodyElements;
@end
@interface WeatherSoapBindingResponse : NSObject {
	NSArray *headers;
	NSArray *bodyParts;
	NSError *error;
}
@property (retain) NSArray *headers;
@property (retain) NSArray *bodyParts;
@property (retain) NSError *error;
@end
@class WeatherSoap12BindingResponse;
@class WeatherSoap12BindingOperation;
@protocol WeatherSoap12BindingResponseDelegate <NSObject>
- (void) operation:(WeatherSoap12BindingOperation *)operation completedWithResponse:(WeatherSoap12BindingResponse *)response;
@end
@interface WeatherSoap12Binding : NSObject <WeatherSoap12BindingResponseDelegate> {
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
- (void)sendHTTPCallUsingBody:(NSString *)body soapAction:(NSString *)soapAction forOperation:(WeatherSoap12BindingOperation *)operation;
- (void)addCookie:(NSHTTPCookie *)toAdd;
- (WeatherSoap12BindingResponse *)GetWeatherUsingParameters:(WeatherSvc_GetWeather *)aParameters ;
- (void)GetWeatherAsyncUsingParameters:(WeatherSvc_GetWeather *)aParameters  delegate:(id<WeatherSoap12BindingResponseDelegate>)responseDelegate;
@end
@interface WeatherSoap12BindingOperation : NSOperation {
	WeatherSoap12Binding *binding;
	WeatherSoap12BindingResponse *response;
	id<WeatherSoap12BindingResponseDelegate> delegate;
	NSMutableData *responseData;
	NSURLConnection *urlConnection;
}
@property (retain) WeatherSoap12Binding *binding;
@property (readonly) WeatherSoap12BindingResponse *response;
@property (nonatomic, assign) id<WeatherSoap12BindingResponseDelegate> delegate;
@property (nonatomic, retain) NSMutableData *responseData;
@property (nonatomic, retain) NSURLConnection *urlConnection;
- (id)initWithBinding:(WeatherSoap12Binding *)aBinding delegate:(id<WeatherSoap12BindingResponseDelegate>)aDelegate;
@end
@interface WeatherSoap12Binding_GetWeather : WeatherSoap12BindingOperation {
	WeatherSvc_GetWeather * parameters;
}
@property (retain) WeatherSvc_GetWeather * parameters;
- (id)initWithBinding:(WeatherSoap12Binding *)aBinding delegate:(id<WeatherSoap12BindingResponseDelegate>)aDelegate
	parameters:(WeatherSvc_GetWeather *)aParameters
;
@end
@interface WeatherSoap12Binding_envelope : NSObject {
}
+ (WeatherSoap12Binding_envelope *)sharedInstance;
- (NSString *)serializedFormUsingHeaderElements:(NSDictionary *)headerElements bodyElements:(NSDictionary *)bodyElements;
@end
@interface WeatherSoap12BindingResponse : NSObject {
	NSArray *headers;
	NSArray *bodyParts;
	NSError *error;
}
@property (retain) NSArray *headers;
@property (retain) NSArray *bodyParts;
@property (retain) NSError *error;
@end
