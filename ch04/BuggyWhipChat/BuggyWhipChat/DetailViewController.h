//
//  DetailViewController.h
//  BuggyWhipChat
//
//  Created by James Turner on 6/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate>
- (IBAction)lookupZipCode:(id)sender;

@property (strong, nonatomic) id detailItem;

@property (strong, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
- (IBAction)showWeather:(id)sender;
- (IBAction)showSOAPWeather:(id)sender;

- (IBAction)sendNews:(id)sender;
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;
-(IBAction)showNews:(id)sender;
@end
