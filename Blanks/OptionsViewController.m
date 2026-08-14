//
//  FlipsideViewController.m
//  Blanks
//
//  Created by Kai Kunze on 19/10/2013.
//  Copyright (c) 2013 Kai Kunze. All rights reserved.
//

#import "OptionsViewController.h"
#import "MoreBlanks-Swift.h"

@interface OptionsViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *dragSwitch;

@end

@implementation OptionsViewController


- (IBAction)buyCoffee:(id)sender {
    UIViewController *vc = [SwiftUIViewFactory makeSwiftUIViewWithDismissHandler:^{
        [[self presentedViewController] dismissViewControllerAnimated:YES completion:nil];
    }];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    bool tapping =  self.dragSwitch.on;
    
    if ([defaults objectForKey:@"TappingUI"] != nil) {
        tapping = [defaults boolForKey:@"TappingUI"];
    }
        
    self.dragSwitch.on  = tapping;
	// Do any additional setup after loading the view, typically from a nib.
}

- (void) viewDidAppear:(BOOL)animated{

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions
- (IBAction)toggleDragging:(id)sender {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    //NSLog(@"%d",self.dragSwitch.isOn);
    [prefs setBool:self.dragSwitch.isOn forKey:@"TappingUI"];
    [prefs synchronize];
    //NSLog(@"%d",[prefs boolForKey:@"theBoolKey"]);
}

- (IBAction)done:(id)sender
{
    [self.delegate optionsViewControllerDidFinish:self];
}

@end
