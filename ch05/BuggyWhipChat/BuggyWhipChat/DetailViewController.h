//
//  DetailViewController.h
//  BuggyWhipChat
//
//  Created by James Turner on 6/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate> {
    UITextView *_outputView;
}

- (IBAction)lookupZipCode:(id)sender;

@property (retain, nonatomic) id detailItem;
@property (nonatomic, retain) IBOutlet UITextView *outputView;

@property (retain, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
- (IBAction)showWeather:(id)sender;
- (IBAction)showSOAPWeather:(id)sender;

- (IBAction)sendNews:(id)sender;
@property (retain, nonatomic) IBOutlet UIToolbar *toolbar;
-(IBAction)showNews:(id)sender;
@end
