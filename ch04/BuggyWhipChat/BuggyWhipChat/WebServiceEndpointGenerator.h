//
//  WebServiceEndpointGenerator.h
//  BuggyWhipChat
//
//  Created by James Turner on 7/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebServiceEndpointGenerator : NSObject
+(NSURL *) getForecastWebServiceEndpoint:(NSString *) zipcode startDate:(NSDate *) startDate endDate:(NSDate *) endDate;
+(NSURL *) getZipCodeEndpointForZipCode:(NSString *) zipcode country:(NSString *) country username:(NSString *) username;
@end
