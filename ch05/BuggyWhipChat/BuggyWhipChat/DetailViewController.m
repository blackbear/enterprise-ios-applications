//
//  DetailViewController.m
//  BuggyWhipChat
//
//  Created by James Turner on 6/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DetailViewController.h"

#import "RootViewController.h"
#import "ASIHTTPRequest.h"
#import "WebServiceEndpointGenerator.h"
#import "DDXML.h"
#import "DDXMLElementAdditions.h"
#import "SBJson.h"
#import "WeatherForecastSvc.h"

@interface DetailViewController ()
@property (retain, nonatomic) UIPopoverController *popoverController;
- (void)configureView;
@end

@implementation DetailViewController

@synthesize detailItem = _detailItem;
@synthesize outputView = _outputView;
@synthesize detailDescriptionLabel = _detailDescriptionLabel;
@synthesize toolbar = _toolbar;
@synthesize popoverController = _myPopoverController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Detail", @"Detail");
    }
    return self;
}

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }

    if (self.popoverController != nil) {
        [self.popoverController dismissPopoverAnimated:YES];
    }        
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        self.detailDescriptionLabel.text = [self.detailItem description];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)viewDidUnload
{
    [self setOutputView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController: (UIPopoverController *)pc
{
    barButtonItem.title = @"Master";
    NSMutableArray *items = [[self.toolbar items] mutableCopy];
    [items insertObject:barButtonItem atIndex:0];
    [self.toolbar setItems:items animated:YES];
    self.popoverController = pc;
}

- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    NSMutableArray *items = [[self.toolbar items] mutableCopy];
    [items removeObjectAtIndex:0];
    [self.toolbar setItems:items animated:YES];
    self.popoverController = nil;
}

-(IBAction) showNews:(id) sender {
    NSURL *url = [NSURL URLWithString:@"http://www.cnn.com/index.html"];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setTimeOutSeconds:30];
    [request setDelegate:self];
    [request startAsynchronous];
    [url release];
}

-(void) sendNewsToServer:(NSString *) payload {
    NSURL *url = [NSURL URLWithString:@"http://thisis.a.bogus/url"];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setPostBody:[NSMutableData dataWithData:[payload dataUsingEncoding:NSUTF8StringEncoding]]];
    [request addRequestHeader:@"Content-Type" value:@"text/xml"];
    [request setRequestMethod:@"POST"];
    [request setTimeOutSeconds:30];
    [request setDelegate:self];
    [request startAsynchronous];
    [url release];
}

- (IBAction)lookupZipCode:(id)sender {
    NSURL *url = [[WebServiceEndpointGenerator getZipCodeEndpointForZipCode:@"03038"
                                              country:@"US" username:@"buggywhipco"] retain];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setTimeOutSeconds:30];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(gotZipCode:)];
    [request startAsynchronous];
    [url release];
}

- (void)gotZipCode:(ASIHTTPRequest *)request
{
    UIAlertView *alert;
    if ([request responseStatusCode] == 404) {
        alert = [[UIAlertView alloc] initWithTitle:@"Page Not Found" 
                                           message: @"The requested page was not found" delegate:self 
                                 cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    } else {
        NSDictionary *json = [[request responseString] JSONValue];
        NSArray *postalCodes = [json valueForKey:@"postalcodes"];
        if ([postalCodes count] == 0) {
            NSLog(@"No postal codes found for requested code");
            return;
        }
        [json JSONRepresentation];
        NSString *result = @"";
        for (NSDictionary *postalCode in postalCodes) {
            result = [result stringByAppendingFormat:@"Postal Code: %@\n", [postalCode valueForKey:@"postalcode"]];
            result = [result stringByAppendingFormat:@"City: %@\n", [postalCode valueForKey:@"placeName"]];
            result = [result stringByAppendingFormat:@"County: %@\n", [postalCode valueForKey:@"adminName2"]];
            result = [result stringByAppendingFormat:@"State: %@\n", [postalCode valueForKey:@"adminName1"]];
            NSDecimalNumber *latitudeNum = [postalCode valueForKey:@"lat"];
            float latitude = [latitudeNum floatValue];
            NSString *northSouth = @"N";
            if (latitude < 0) {
                northSouth = @"S";
                latitude = - latitude;
            }
            result = [result stringByAppendingFormat:@"Latitude: %4.2f%@\n", latitude, northSouth];
            NSDecimalNumber *longitudeNum = [postalCode valueForKey:@"lng"];
            float longitude = [longitudeNum floatValue];
            NSString *eastWest = @"E";
            if (longitude < 0) {
                eastWest = @"W";
                longitude = - longitude;
            }
            result = [result stringByAppendingFormat:@"Longitude: %4.2f%@\n", longitude, eastWest];
        }
        self.outputView.text = result;
    }
}
        

- (IBAction)showWeather:(id)sender {
    NSURL *url = [[WebServiceEndpointGenerator 
                   getForecastWebServiceEndpoint:@"03038" 
                   startDate:[NSDate date] 
                   endDate:[[NSDate date] dateByAddingTimeInterval:3600*24*2]]
                  retain];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setTimeOutSeconds:30];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(gotWeather:)];
    [request startAsynchronous];
    [url release];
}

- (IBAction)showSOAPWeather:(id)sender {
    WeatherForecastSoapBinding *binding = [WeatherForecastSvc WeatherForecastSoapBinding];
    binding.logXMLInOut = YES;
    WeatherForecastSvc_GetWeatherByZipCode *request = [[WeatherForecastSvc_GetWeatherByZipCode new] autorelease];
    [request setZipCode:@"03038"];
    WeatherForecastSoapBindingResponse *response = [binding GetWeatherByZipCodeUsingParameters:request];
    NSString *result = @"";
    for (id bodyPart in response.bodyParts) {
        if ([bodyPart isKindOfClass:[SOAPFault class]]) {
            NSLog(@"Got error: %@", ((SOAPFault *)bodyPart).simpleFaultString);
            continue;
        }
        if ([bodyPart isKindOfClass:[WeatherForecastSvc_GetWeatherByZipCodeResponse class]]) {
            WeatherForecastSvc_GetWeatherByZipCodeResponse *response = bodyPart;
            WeatherForecastSvc_WeatherForecasts *forecasts = response.GetWeatherByZipCodeResult;
            WeatherForecastSvc_ArrayOfWeatherData *details = forecasts.Details;
            NSArray *weatherData = details.WeatherData;
            for (WeatherForecastSvc_WeatherData *data in weatherData) {
                result = [result stringByAppendingFormat:@"Date: %@\n", data.Day];
                result = [result stringByAppendingFormat:@"High: %@\n", data.MaxTemperatureF];
                result = [result stringByAppendingFormat:@"Low: %@\n", data.MinTemperatureF];
                result = [result stringByAppendingFormat:@"Date: %@\n\n", data.Day];
            }
        }
    }
    self.outputView.text = result;
    
    
    
}

-(id) getSingleStringValue:(DDXMLElement *) element xpath:(NSString *) xpath {
    NSError *error = nil;
    NSArray *vals = [element nodesForXPath:xpath error:&error];
    if (error != nil) {
        return nil;
    }
    if ([vals count] != 1) {
        return nil;
    }
    DDXMLElement *val = [vals objectAtIndex:0];
    return [val stringValue];
}

-(NSString *) constructNewsItemXMLByFormatWithSubject:(NSString *) subject body:(NSString *) body {
    NSDate *now = [NSDate date];
    NSDateFormatter *df = [NSDateFormatter new];
    [df setDateFormat:@"YYYY-MM-dd"];
    NSDateFormatter *tf = [NSDateFormatter new];
    [tf setDateFormat:@"hh:mm"];

    NSString *xml = [NSString stringWithFormat:@"<newsitem postdate=\"%@\" posttime=\"%@\">\
                     <subject>%@<subject><body>%@</body></newsitem>", 
                     [df stringFromDate:now], [tf stringFromDate:now], subject, body];
    [df release];
    [tf release];
    return xml;
}

-(NSString *) constructNewsItemXMLByDOMWithSubject:(NSString *) subject body:(NSString *) body {
    NSDate *now = [NSDate date];
    NSDateFormatter *df = [NSDateFormatter new];
    [df setDateFormat:@"YYYY-MM-dd"];
    NSDateFormatter *tf = [NSDateFormatter new];
    [tf setDateFormat:@"hh:mm"];
    DDXMLElement *postdate = [DDXMLElement attributeWithName:@"postdate" stringValue:[df stringFromDate:now]];
    DDXMLElement *posttime = [DDXMLElement attributeWithName:@"posttime" stringValue:[tf stringFromDate:now]];
    NSArray *attributes = [NSArray arrayWithObjects:postdate, posttime, nil];
    DDXMLElement *subjectNode = [DDXMLElement elementWithName:@"subject" stringValue:subject];
    DDXMLElement *bodyNode = [DDXMLElement elementWithName:@"body" stringValue:body];
    NSArray *children = [NSArray arrayWithObjects:subjectNode, bodyNode, nil];
    DDXMLElement *doc = [DDXMLElement elementWithName:@"newsitem" children:children attributes:attributes];
    NSString *xml = [doc XMLString];
    [df release];
    [tf release];
    return xml;
}


- (IBAction)sendNews:(id)sender {
    NSLog(@"By Format: %@", [self constructNewsItemXMLByFormatWithSubject:@"This is a test subject" body:@"Buggy whips are cool, aren't they?"]);
    NSLog(@"By DOM: %@", [self constructNewsItemXMLByDOMWithSubject:@"This is a test subject" body:@"Buggy whips are cool, aren't they?"]);
    NSLog(@"By Format: %@", [self constructNewsItemXMLByFormatWithSubject:@"This is a test subject" body:@"Buggy whips are cool & neat, > all the rest, aren't they?"]);
    NSLog(@"By DOM: %@", [self constructNewsItemXMLByDOMWithSubject:@"This is a test subject" body:@"Buggy whips are cool & neat, > all the rest, aren't they?"]);
}

- (void)gotWeather:(ASIHTTPRequest *)request
{
    UIAlertView *alert;
    if ([request responseStatusCode] == 404) {
        alert = [[UIAlertView alloc] initWithTitle:@"Page Not Found" 
                                           message: @"The requested page was not found" delegate:self 
                                 cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    } else {
        NSError *error = nil;
        DDXMLDocument *ddDoc = [[DDXMLDocument alloc] 
                                initWithXMLString:[request responseString] 
                                options:0 error:&error];
        if (error == nil) {
            NSArray *timelayouts =
                [ddDoc nodesForXPath:@"//data/time-layout" error:&error];
            NSMutableDictionary *timeDict = 
                [NSMutableDictionary new];
            for (DDXMLElement *timenode in timelayouts) {
                NSString *key = [self getSingleStringValue:timenode xpath:@"layout-key"];
                if (key != nil) {
                    NSArray *dates =
                        [timenode nodesForXPath:@"start-valid-time" error:&error];
                    NSMutableArray *dateArray = [NSMutableArray new];
                    for (DDXMLElement *date in dates) {
                        [dateArray addObject:[date stringValue]];
                    }
                    [timeDict setObject:dateArray forKey:key];
                }
            }
            NSArray *temps =
                [ddDoc nodesForXPath:@"//parameters/temperature" error:&error];
            for (DDXMLElement *tempnode in temps) {
                NSString *type = [self getSingleStringValue:tempnode xpath:@"@type"];
                NSString *units = [self getSingleStringValue:tempnode xpath:@"@units"];
                NSString *timeLayout = [self getSingleStringValue:tempnode xpath:@"@time-layout"];
                NSString *name = [self getSingleStringValue:tempnode xpath:@"name"];
                NSArray *values = [tempnode nodesForXPath:@"value" error:&error];
                int i = 0;
                NSArray *times = [timeDict valueForKey:timeLayout];
                for (DDXMLElement *value in values) {
                    NSString *val = [value stringValue];
                    NSLog(@"Type: %@, Units: %@, Time: %@",
                          type, units, [times objectAtIndex:i]);
                    NSLog(@"Name: %@, Value: %@",
                          name, val);
                    NSLog(@" ");
                    i++;
                }
            }
            return;
        }
        [ddDoc release];
        alert = [[UIAlertView alloc] initWithTitle:@"Error parsing XML" 
                message: [error localizedDescription]
                delegate:self 
                cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    }
    [alert show];
    [alert release];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    UIAlertView *alert;
    if ([request responseStatusCode] == 404) {
        alert = [[UIAlertView alloc] initWithTitle:@"Page Not Found" 
                                           message: @"The requested page was not found" delegate:self 
                                 cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    } else {
        NSString *responseString = [[request responseString] retain];
        self.outputView.text = responseString;
        [responseString release];
    }
    [alert show];
    [alert release];

}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Buggy Whip News Error" message: [error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    [alert release];
}

- (void)dealloc {
    [_outputView release];
    [super dealloc];
}
@end
