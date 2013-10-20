//
//  MainViewController.m
//  Blanks
//
//  Created by Kai Kunze on 19/10/2013.
//  Copyright (c) 2013 Kai Kunze. All rights reserved.
//

#import "BlanksViewController.h"

@interface BlanksViewController ()

@end

@implementation BlanksViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    wordModel = [[WordModel alloc] init];
    
    //[self addGestureRecognizersToPiece:wordButton1];
    
    streak = 0.0;
    
    highestStreak = [[NSUserDefaults standardUserDefaults] objectForKey: @"HighScore"];
    if(!highestStreak){
        highestStreak =[NSNumber numberWithFloat:0.0];
        [[NSUserDefaults standardUserDefaults] setObject: highestStreak forKey: @"HighScore"];
    }
    NSArray *words=[wordModel getWords];
    //NSLog(@"@&",[words objectAtIndex:0]);
    [wordButton1 setTitle: (NSString*)[words objectAtIndex:0] forState: UIControlStateNormal];
    [wordButton2 setTitle: (NSString*)[words objectAtIndex:1] forState: UIControlStateNormal];
    [wordButton3 setTitle: (NSString*)[words objectAtIndex:2] forState: UIControlStateNormal];
    [wordButton4 setTitle: (NSString*)[words objectAtIndex:3] forState: UIControlStateNormal];
    
    [definitionTV setText:wordModel.definition];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Flipside View

- (void)optionsViewControllerDidFinish:(OptionsViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showAlternate"]) {
        [[segue destinationViewController] setDelegate:self];
    }
}

#pragma mark - Handling Touch

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    return true;
}

- (void)addGestureRecognizersToPiece:(UIView *)piece
{
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panPiece:)];
    [panGesture setMaximumNumberOfTouches:1];
    [panGesture setMinimumNumberOfTouches:1];
    [panGesture setDelegate:self];
    [piece addGestureRecognizer:panGesture];
    
}

- (void)panPiece:(UIPanGestureRecognizer *)gestureRecognizer
{
    UIView *piece = [gestureRecognizer view];
    
    //[self adjustAnchorPointForGestureRecognizer:gestureRecognizer];
    
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan){
        [self.view bringSubviewToFront:piece];
        CGPoint locationInSuperview = [gestureRecognizer locationInView:piece.superview];
        //[self animateFirstTouchAtPoint:locationInSuperview on:(WordView *)piece];
        
    }
    
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gestureRecognizer translationInView:[piece superview]];
        
        [piece setCenter:CGPointMake([piece center].x + translation.x, [piece center].y + translation.y)];
        [gestureRecognizer setTranslation:CGPointZero inView:[piece superview]];
    }
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateEnded){
        if(piece.center.y <= 110){ //&& point.x<=159){
            //  = selected;
            //selectedWord = selected.label.text;
            //[self animateWordToPlace:(WordContainerView*)piece];
            
        }
        piece.transform = CGAffineTransformIdentity;
        //piece.transform = CGAffineTransformMakeScale(0.7, 0.7);
        
        
	}
    
}

@end
