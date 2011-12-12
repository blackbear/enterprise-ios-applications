//
//  TwitterAPI.h
//  BuggyWhipChat
//
//  Created by Mary on 6/29/11.
//  Copyright 2011 BuggyWhipLLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TwitterAPI : NSObject

-(NSError *) validateTwitterAccountForUser:(NSString *) user password:(NSString *) password;
@end
