//
//  main.m
//  BuggyWhipChat
//
//  Created by James Turner on 6/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BuggyWhipChatAppDelegate.h"

int main(int argc, char *argv[])
{
    int retVal = 0;
     NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        retVal = UIApplicationMain(argc, argv, nil, NSStringFromClass([BuggyWhipChatAppDelegate class]));
    [pool release];
    return retVal;
}
