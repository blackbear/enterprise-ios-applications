//
//  BuggyWhipChatTests.m
//  BuggyWhipChatTests
//
//  Created by James Turner on 6/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BuggyWhipChatTests.h"
#import "BuggyWhipChatAppDelegate.h"
#import "RootViewController.h"
#import "DetailViewController.h"

@implementation BuggyWhipChatTests

BuggyWhipChatAppDelegate *delegate;

- (void)setUp
{
    [super setUp];
    delegate = [[UIApplication sharedApplication] delegate];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}


- (void) testUIElementsPresent {
    RootViewController *controller = delegate.rootViewController;
    STAssertNotNil(controller, @"Root view controller not found");
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        STAssertNotNil(controller.detailViewController, @"Detail view controller not found on iPad");
    }
}

-(void) testSOAPWeather {
    RootViewController *controller = delegate.rootViewController;
    DetailViewController *detail = controller.detailViewController;
    detail.outputView.text = @"";
    [detail showSOAPWeather:nil];
    int i;
    for (i = 0; i < 30; i++) {
        [[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1]];
        if ([detail.outputView.text length] > 0) {
            break;
        }
    }
    STAssertTrue([detail.outputView.text length] > 0, @"Detail view is blank");
}

-(void) testZipCode {
    RootViewController *controller = delegate.rootViewController;
    DetailViewController *detail = controller.detailViewController;
    detail.outputView.text = @"";
    [detail lookupZipCode:nil];
    int i;
    for (i = 0; i < 30; i++) {
        [[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1]];
        if ([detail.outputView.text length] > 0) {
            break;
        }
    }
    STAssertTrue([detail.outputView.text length] > 0, @"Detail view is blank");
}


@end
