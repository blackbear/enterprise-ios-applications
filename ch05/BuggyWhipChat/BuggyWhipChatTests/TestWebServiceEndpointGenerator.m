//
//  TestWebServiceEndpointGenerator.m
//  BuggyWhipChat
//

#import "TestWebServiceEndpointGenerator.h"
#import "WebServiceEndpointGenerator.h"

@implementation TestWebServiceEndpointGenerator

NSDate *testStartDate;
NSDate *testEndDate;

-(void) setUp {
    NSDateFormatter *df = [NSDateFormatter new];
    [df setDateFormat:@"YY-MM-dd"];
    testStartDate = [df dateFromString:@"2011-08-01"];
    testEndDate = [df dateFromString:@"2011-08-02"];
}

-(void) testGetForecastWebServiceEndpointSuccess {
    NSURL *url = [WebServiceEndpointGenerator getForecastWebServiceEndpoint:@"03038"
                       startDate:testStartDate  endDate:testEndDate];
    STAssertNotNil(url, @"No URL returned");
    NSString *correctURL = @"";
    NSString *urlString = [url absoluteString];
    STAssertEqualObjects(@"http://www.weather.gov/forecasts/xml/sample_products/browser_interface/ndfdXMLclient.php?zipCodeList=03038&product=time-series&begin=2011-08-01T12:00:00&end=2011-08-02T12:00:00&maxt=maxt&mint=mint", urlString, @"The generated URL, %@, did not match the expected URL, %@", urlString, correctURL);
}

-(void) testGetForecastWebServiceEndpointMissingZip {
    @try {
        [WebServiceEndpointGenerator getForecastWebServiceEndpoint:nil
                                  startDate:testStartDate  endDate:testEndDate];
    } @catch (NSException * e) {
        STAssertEqualObjects(@"Missing Argument Exception",e.name, @"Wrong exception type");
        return;
    }
    STFail(@"Call did not generate exception");
}

-(void) testGetForecastWebServiceEndpointMissingStartDate {
    @try {
        [WebServiceEndpointGenerator getForecastWebServiceEndpoint:@"03038"
                                                         startDate:nil  endDate:testEndDate];
    } @catch (NSException * e) {
        STAssertEqualObjects(@"Missing Argument Exception",e.name, @"Wrong exception type");
        return;
    }
    STFail(@"Call did not generate exception");
}

-(void) testGetForecastWebServiceEndpointMissingEndDate {
    @try {
        [WebServiceEndpointGenerator getForecastWebServiceEndpoint:@"03038"
                                                         startDate:testStartDate  endDate:nil];
    } @catch (NSException * e) {
        STAssertEqualObjects(@"Missing Argument Exception",e.name, @"Wrong exception type");
        return;
    }
    STFail(@"Call did not generate exception");
}

-(void) testGetForecastWebServiceEndpointDatesInWrongOrder {
    @try {
        [WebServiceEndpointGenerator getForecastWebServiceEndpoint:@"03038"
                                                         startDate:testEndDate endDate:testStartDate];
    } @catch (NSException * e) {
        STAssertEqualObjects(@"Date Order Exception",e.name, @"Wrong exception type");
        return;
    }
    STFail(@"Call did not generate exception");
}

@end
