//
//  WebServiceEndpointGenerator.m
//  BuggyWhipChat
//
//  Created by James Turner on 7/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "WebServiceEndpointGenerator.h"

@implementation WebServiceEndpointGenerator

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

+(NSURL *) getForecastWebServiceEndpoint:(NSString *) zipcode startDate:(NSDate *) startDate endDate:(NSDate *) endDate {
    if ((zipcode == NULL) || (startDate == NULL) || (endDate == NULL)) {
        NSException *exception = 
            [NSException exceptionWithName:@"Missing Argument Exception"
                                    reason:@"An argument was missing" userInfo:nil];
        @throw exception;
    }
    if ([endDate compare:startDate] == NSOrderedAscending) {
        NSException *exception = 
        [NSException exceptionWithName:@"Date Order Exception"
                                reason:@"The start date can not be after the end date" userInfo:nil];
        @throw exception;
    }
    NSDateFormatter *df = [NSDateFormatter new];
    [df setDateFormat:@"YYYY-MM-dd'T'hh:mm:ss"];
    NSString *url = 
        [NSString stringWithFormat:@"http://www.weather.gov/forecasts/xml/sample_products/browser_interface/ndfdXMLclient.php?zipCodeList=%@&product=time-series&begin=%@&end=%@&maxt=maxt&mint=mint",
         zipcode, [df stringFromDate:startDate], [df stringFromDate:endDate]];
    [df release];
    return [NSURL URLWithString:url];
}

+(NSURL *) getZipCodeEndpointForZipCode:(NSString *) zipcode country:(NSString *) country username:(NSString *) username {
    NSString *url = 
    [NSString stringWithFormat:@"http://api.geonames.org/postalCodeLookupJSON?postalcode=%@&country=%@&username=%@",
        zipcode, country, username];
    return [NSURL URLWithString:url];
    
}
@end
