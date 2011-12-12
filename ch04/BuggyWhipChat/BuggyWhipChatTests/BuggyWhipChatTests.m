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
    delegate = [BuggyWhipChatAppDelegate new];
    [delegate application:[UIApplication sharedApplication] didFinishLaunchingWithOptions:nil];
    
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
    DetailViewController *detail = controller.detailViewController;
    [detail showNews:nil];
    [detail showSOAPWeather:nil];
}

- (void)testExample
{
    
//    STFail(@"Unit tests are not implemented yet in BuggyWhipChatTests");
}

@end
