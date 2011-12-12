//
//  TwitterAPI.m
//  BuggyWhipChat
//
//  Created by James Turner on 6/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TwitterAPI.h"

@implementation TwitterAPI

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

#pragma mark Authentication

-(NSError *) validateTwitterAccountForUser:(NSString *) user password:(NSString *) password {
    return NULL;
}

@end
