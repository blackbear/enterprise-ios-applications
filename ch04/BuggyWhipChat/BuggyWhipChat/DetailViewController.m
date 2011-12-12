//
//  DetailViewController.m
//  BuggyWhipChat
//
//  Created by James Turner on 6/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DetailViewController.h"

#import "RootViewController.h"
#import "WebServiceEndpointGenerator.h"
#import "DDXML.h"
#import "DDXMLElementAdditions.h"
#import "WeatherSvc.h"

@interface DetailViewController ()
@property (strong, nonatomic) UIPopoverController *popoverController;
- (void)configureView;
@end

@implementation DetailViewController

@synthesize detailItem = _detailItem;
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

- (void)handleError:(NSString *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Buggy Whip News Error" message: error
                                                   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)displayResponse:(NSData *)data
{
    UIAlertView *alert;
    NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    alert = [[UIAlertView alloc] initWithTitle:@"Buggy Whip News" 
                                       message: responseString delegate:self 
                             cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

-(IBAction) showNews:(id) sender {
    NSURL *url = [NSURL URLWithString:@"http://www.cnn.com/index.html"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection 
     sendAsynchronousRequest:request 
     queue:[NSOperationQueue currentQueue] 
     completionHandler:^(NSURLResponse *response, 
                         NSData *data, NSError *error) {
         if (error != nil) {
             [self handleError:[error localizedDescription]];
         } else {
             if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                 NSHTTPURLResponse *httpresp = 
                 (NSHTTPURLResponse *) response;
                 if ([httpresp statusCode] == 404) {
                     [self handleError:@"Page not found!"];
                 } else {
                     [self displayResponse:data];
                 }
             }
         }
     }];
}

-(void) sendNewsToServer:(NSString *) payload {
    NSURL *url = [NSURL URLWithString:@"http://thisis.a.bogus/url"];
    NSMutableURLRequest *request = [NSMutableURLRequest
                                    requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    NSMutableDictionary *headers = 
        [NSMutableDictionary dictionaryWithDictionary:[request allHTTPHeaderFields]];
    [headers setValue:@"text/xml" forKey:@"Content-Type"];
    [request setAllHTTPHeaderFields:headers];
    [request setTimeoutInterval:30];
    NSData *body = [payload dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:[NSMutableData dataWithData:body]];
    [NSURLConnection sendAsynchronousRequest:request 
                                       queue:[NSOperationQueue currentQueue] 
                           completionHandler:^(NSURLResponse *response, 
                                               NSData *data, NSError *error) {
                               if (error != nil) {
                                   [self handleError:error.description];
                               } else {
                                   [self displayResponse:data];
                               }
                           }];
}


- (void)gotZipCode:(NSData *)data
{
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error != nil) {
        [self handleError:error.description];
        return;
    }
        NSArray *postalCodes = [json valueForKey:@"postalcodes"];
        if ([postalCodes count] == 0) {
            NSLog(@"No postal codes found for requested code");
            return;
        }
        for (NSDictionary *postalCode in postalCodes) {
            NSLog(@"Postal Code: %@", [postalCode valueForKey:@"postalcode"]);
            NSLog(@"City: %@", [postalCode valueForKey:@"placeName"]);
            NSLog(@"County: %@", [postalCode valueForKey:@"adminName2"]);
            NSLog(@"State: %@", [postalCode valueForKey:@"adminName1"]);
            NSDecimalNumber *latitudeNum = [postalCode valueForKey:@"lat"];
            float latitude = [latitudeNum floatValue];
            NSString *northSouth = @"N";
            if (latitude < 0) {
                northSouth = @"S";
                latitude = - latitude;
            }
            NSLog(@"Latitude: %4.2f%@", latitude, northSouth);
            NSDecimalNumber *longitudeNum = [postalCode valueForKey:@"lng"];
            float longitude = [longitudeNum floatValue];
            NSString *eastWest = @"E";
            if (longitude < 0) {
                eastWest = @"W";
                longitude = - longitude;
            }
            NSLog(@"Longitude: %4.2f%@", longitude, eastWest);
    }
}



- (IBAction)lookupZipCode:(id)sender {
    NSURL *url = [WebServiceEndpointGenerator getZipCodeEndpointForZipCode:@"03038"
                                              country:@"US" username:@"buggywhipco"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request 
                                       queue:[NSOperationQueue currentQueue] 
                           completionHandler:^(NSURLResponse *response, 
                                               NSData *data, NSError *error) {
                               if (error != nil) {
                                   [self handleError:error.description];
                               } else {
                                   [self gotZipCode:data];
                               }
                           }];
}

-(id) getSingleStringValue:(DDXMLElement *) element 
                     xpath:(NSString *) xpath {
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


- (void)gotWeather:(NSData *)data
{
    UIAlertView *alert;
    NSError *error = nil;
    DDXMLDocument *ddDoc = [[DDXMLDocument alloc] 
                            initWithXMLString:[[NSString alloc] 
                                               initWithData:data 
                                               encoding:NSUTF8StringEncoding]
                            options:0 error:&error];
    if (error == nil) {
        NSArray *timelayouts =
        [ddDoc nodesForXPath:@"//data/time-layout" error:&error];
        NSMutableDictionary *timeDict = 
        [NSMutableDictionary new];
        for (DDXMLElement *timenode in timelayouts) {
            NSString *key = 
            [self getSingleStringValue:timenode 
                                 xpath:@"layout-key"];
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
            NSString *type = [self getSingleStringValue:tempnode 
                                                  xpath:@"@type"];
            NSString *units = [self getSingleStringValue:tempnode 
                                                   xpath:@"@units"];
            NSString *timeLayout = [self getSingleStringValue:tempnode 
                                                        xpath:@"@time-layout"];
            NSString *name = [self getSingleStringValue:tempnode xpath:@"name"];
            NSArray *values = [tempnode nodesForXPath:@"value" error:&error];
            int i = 0;
            NSArray *times = [timeDict valueForKey:timeLayout];
            NSLog(@"Type: %@, Units: %@", type, units);
            for (DDXMLElement *value in values) {
                NSString *val = [value stringValue];
                NSLog(@"%@, %@ = %@",
                      [times objectAtIndex:i], name, val);
                NSLog(@" ");
                i++;
            }
        }
        return;
    }
    alert = [[UIAlertView alloc] initWithTitle:@"Error parsing XML" 
                                       message: [error localizedDescription]
                                      delegate:self 
                             cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

        

- (IBAction)showWeather:(id)sender {
    NSURL *url = 
    [WebServiceEndpointGenerator 
     getForecastWebServiceEndpoint:@"03038" 
     startDate:[NSDate date] 
     endDate:[[NSDate date] 
              dateByAddingTimeInterval:3600*24*2]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection 
     sendAsynchronousRequest:request 
     queue:[NSOperationQueue currentQueue] 
     completionHandler:^(NSURLResponse *response, 
                         NSData *data, NSError *error) {
         if (error != nil) {
             [self handleError:error.description];
         } else {
             [self gotWeather:data];
         }
     }];
    
}


- (IBAction)showSOAPWeather:(id)sender {
    WeatherSoapBinding *binding = 
        [WeatherSvc WeatherSoapBinding];
    binding.logXMLInOut = YES;
    WeatherSvc_GetWeather *params = [[WeatherSvc_GetWeather alloc] init];
    params.City = @"Derry, NH";
    WeatherSoapBindingResponse  *response = 
    [binding 
     GetWeatherUsingParameters:params];
    for (id bodyPart in response.bodyParts) {
        if ([bodyPart isKindOfClass:[SOAPFault class]]) {
            NSLog(@"Got error: %@", 
                  ((SOAPFault *)bodyPart).simpleFaultString);
            continue;
        }
        
        if ([bodyPart isKindOfClass:
             [WeatherSvc_GetWeatherResponse class]]) {
            WeatherSvc_GetWeatherResponse *response = bodyPart;
            NSLog(@"Forecast: %@", response.GetWeatherResult);
        }
    }
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
    return xml;
}


- (IBAction)sendNews:(id)sender {
    NSLog(@"By Format: %@", [self constructNewsItemXMLByFormatWithSubject:@"This is a test subject" body:@"Buggy whips are cool, aren't they?"]);
    NSLog(@"By DOM: %@", [self constructNewsItemXMLByDOMWithSubject:@"This is a test subject" body:@"Buggy whips are cool, aren't they?"]);
    NSLog(@"By Format: %@", [self constructNewsItemXMLByFormatWithSubject:@"This is a test subject" body:@"Buggy whips are cool & neat, > all the rest, aren't they?"]);
    NSLog(@"By DOM: %@", [self constructNewsItemXMLByDOMWithSubject:@"This is a test subject" body:@"Buggy whips are cool & neat, > all the rest, aren't they?"]);
}






@end
