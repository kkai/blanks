//
//  FlipsideViewController.h
//  Blanks
//
//  Created by Kai Kunze on 19/10/2013.
//  Copyright (c) 2013 Kai Kunze. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OptionsViewController;

@protocol OptionsViewControllerDelegate
- (void) optionsViewControllerDidFinish:(OptionsViewController *)controller;
@end

@interface OptionsViewController : UIViewController

@property (weak, nonatomic) id <OptionsViewControllerDelegate> delegate;

- (IBAction)done:(id)sender;

@end
