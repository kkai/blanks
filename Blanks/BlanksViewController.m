//
//  MainViewController.m
//  Blanks
//
//  Created by Kai Kunze on 19/10/2013.
//  Copyright (c) 2013 Kai Kunze. All rights reserved.
//

#import "BlanksViewController.h"
#import <QuartzCore/QuartzCore.h>


@interface BlanksViewController ()

@end

@implementation BlanksViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    wordModel = [[WordModel alloc] init];
    
    streak = 0.0;
    
    highestStreak = [[NSUserDefaults standardUserDefaults] objectForKey: @"HighScore"];
    if(!highestStreak){
        highestStreak =[NSNumber numberWithFloat:0.0];
        [[NSUserDefaults standardUserDefaults] setObject: highestStreak forKey: @"HighScore"];
    }
    NSArray *words=[wordModel getWords];
    
    //word1 = [[WordView alloc] init];
    word1=[[[NSBundle mainBundle] loadNibNamed:@"WordView" owner:self options:nil] objectAtIndex:0];
    [word1 setOpaque:true];
    word1.backgroundColor = [UIColor clearColor];

    word2 = [[WordView alloc] init];
    word2=[[[NSBundle mainBundle] loadNibNamed:@"WordView" owner:self options:nil] objectAtIndex:0];
    [word2 setOpaque:true];
    word2.backgroundColor = [UIColor clearColor];
    word3 = [[WordView alloc] init];
    word3 =[[[NSBundle mainBundle] loadNibNamed:@"WordView" owner:self options:nil] objectAtIndex:0];
    [word3 setOpaque:true];
    word3.backgroundColor = [UIColor clearColor];
    
    word4 = [[WordView alloc] init];
    word4=[[[NSBundle mainBundle] loadNibNamed:@"WordView" owner:self options:nil] objectAtIndex:0];
    [word4 setOpaque:true];
    word4.backgroundColor = [UIColor clearColor];


    
    //NSLog(@"@&",[words objectAtIndex:0]);
    [wordButton1 setTitle: (NSString*)[words objectAtIndex:0] forState: UIControlStateNormal];
    [wordButton2 setTitle: (NSString*)[words objectAtIndex:1] forState: UIControlStateNormal];
    [wordButton3 setTitle: (NSString*)[words objectAtIndex:2] forState: UIControlStateNormal];
    [wordButton4 setTitle: (NSString*)[words objectAtIndex:3] forState: UIControlStateNormal];
    [definitionTV setText: wordModel.definition];
    
    [word1 addWord:(NSString*)[words objectAtIndex:0]];
    [word2 addWord:[words objectAtIndex:1]];
    [word3 addWord:[words objectAtIndex:2]];
    [word4 addWord:[words objectAtIndex:3]];
    
    score.text = [NSString stringWithFormat:@"streak: %5.0f\t\tword count: %.0f\t\tcorrect: %.0f%%",0.0, 0.0,0.0*100];

}
- (void) viewDidAppear:(BOOL)animated {
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"TappingUI"] != nil) {
        isTapping = [defaults boolForKey:@"TappingUI"];
    }else{
        [defaults setBool:NO forKey:@"TappingUI"];
        isTapping = NO;
    }
    
    if (!isTapping) {
        [self addGestureRecognizersToPiece:word1];
        [self addGestureRecognizersToPiece:word2];
        [self addGestureRecognizersToPiece:word3];
        [self addGestureRecognizersToPiece:word4];
        
        word1.hidden = NO;
        word2.hidden = NO;
        word3.hidden = NO;
        word4.hidden = NO;

        wordButton1.hidden = YES;
        wordButton2.hidden = YES;
        wordButton3.hidden = YES;
        wordButton4.hidden = YES;
        
    }else{
        word1.hidden = YES;
        word2.hidden = YES;
        word3.hidden = YES;
        word4.hidden = YES;
        
        wordButton1.hidden = NO;
        wordButton2.hidden = NO;
        wordButton3.hidden = NO;
        wordButton4.hidden = NO;
    }
    
    
    
    [word1 setFrame: wordButton1.frame];
    [word2 setFrame: wordButton2.frame];
    [word3 setFrame: wordButton3.frame];
    [word4 setFrame: wordButton4.frame];
    
    [self.view addSubview:word1];
    [self.view addSubview:word2];
    [self.view addSubview:word3];
    [self.view addSubview:word4];


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Check Answer

- (IBAction)answerPressed:(id) sender
{
    if (isTapping){
    UIButton *s = (UIButton *)sender;
    selected = s.titleLabel.text;
    UIImageView* result;
    if ([selected isEqualToString:wordModel.correct]){
        correct = true;
        result = tickView;
        //put this in WordModel or Statsmodel
        correctCount++;
        streak ++;
        if(streak > [highestStreak floatValue]){
            highestStreak = [NSNumber numberWithFloat:streak];
            [[NSUserDefaults standardUserDefaults] setObject: highestStreak forKey: @"HighScore"];
//highscore.text = [NSString stringWithFormat:@"highest streak: %5.0f\t",streak];
            
        }
    }else{
        correct = false;
        result = crossView;
        wrongCount ++;
        streak =0.0;
        
    }
    //[self.view bringSubviewToFront:result];
    result.hidden = NO;
	[self animateCorrectWrongView:result];
    }
}


-(void)animateCorrectWrongView:(UIImageView *) selectedView {
    //NSLog(@"Animate");
    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.6];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(grow3AnimationDidStop:finished:context:)];
	CGAffineTransform transform = CGAffineTransformMakeScale(1.3, 1.3);
	selectedView.transform = transform;
	[UIView commitAnimations];
	//selectedView.center = touchPoint;
	//[UIView commitAnimations];
}


/*- (void)grow3AnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    tickView.hidden = YES;
    crossView.hidden = YES;
    tickView.transform =CGAffineTransformIdentity;
    crossView.transform =CGAffineTransformIdentity;
    
    if (correct){
        [wordModel selectNextWord];
        NSArray *words=[wordModel getWords];
        //NSLog(@"@&",[words objectAtIndex:0]);
        [wordButton1 setTitle: (NSString*)[words objectAtIndex:0] forState: UIControlStateNormal];
        [wordButton2 setTitle: (NSString*)[words objectAtIndex:1] forState: UIControlStateNormal];
        [wordButton3 setTitle: (NSString*)[words objectAtIndex:2] forState: UIControlStateNormal];
        [wordButton4 setTitle: (NSString*)[words objectAtIndex:3] forState:UIControlStateNormal];
        [definitionTV setText:wordModel.definition];
    }
}*/




#pragma mark - Option View

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

// adds a set of gesture recognizers to one of our piece subviews
- (void)addGestureRecognizersToPiece:(UIView *)piece
{
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panPiece:)];
    [panGesture setMaximumNumberOfTouches:1];
    [panGesture setMinimumNumberOfTouches:1];
    [panGesture setDelegate:self];
    [piece addGestureRecognizer:panGesture];
    
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

// shift the piece's center by the pan amount
// reset the gesture recognizer's translation to {0, 0} after applying so the next callback is a delta from the current position
- (void)panPiece:(UIPanGestureRecognizer *)gestureRecognizer
{
    UIView *piece = [gestureRecognizer view];
    
    [self adjustAnchorPointForGestureRecognizer:gestureRecognizer];
    
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan){
        [self.view bringSubviewToFront:piece];
        CGPoint locationInSuperview = [gestureRecognizer locationInView:piece.superview];
        [self animateFirstTouchAtPoint:locationInSuperview on:(WordView *)piece];
        
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
            [self animateWordToPlace:(WordView*)piece];
            
        }
        piece.transform = CGAffineTransformIdentity;
        //piece.transform = CGAffineTransformMakeScale(0.7, 0.7);
        
        
	}
    
}

// scale and rotation transforms are applied relative to the layer's anchor point
// this method moves a gesture recognizer's view's anchor point between the user's fingers
- (void)adjustAnchorPointForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        UIView *piece = gestureRecognizer.view;
        CGPoint locationInSuperview = [gestureRecognizer locationInView:piece.superview];
        piece.center = locationInSuperview;
    }
}


#define GROW_ANIMATION_DURATION_SECONDS 0.15
#define SHRINK_ANIMATION_DURATION_SECONDS 0.15

- (void)animateFirstTouchAtPoint:(CGPoint)touchPoint  on:(WordView *) selectedView {
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:GROW_ANIMATION_DURATION_SECONDS];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(growAnimationDidStop:finished:context:)];
	CGAffineTransform transform = CGAffineTransformMakeScale(1.3, 1.3);
	selectedView.transform = transform;
	[UIView commitAnimations];
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:GROW_ANIMATION_DURATION_SECONDS + SHRINK_ANIMATION_DURATION_SECONDS];
	selectedView.center = touchPoint;
	[UIView commitAnimations];
}


- (void)growAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:SHRINK_ANIMATION_DURATION_SECONDS];
	//self.transform = CGAffineTransformMakeScale(1.1, 1.1);
	[UIView commitAnimations];
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
    
    UIImageView* result;
    if ([selected isEqualToString:wordModel.correct]){
        correct = true;
        result = tickView;
        //put this in WordModel or Statsmodel
        correctCount++;
        streak ++;
        if(streak > [highestStreak floatValue]){
            highestStreak = [NSNumber numberWithFloat:streak];
            [[NSUserDefaults standardUserDefaults] setObject: highestStreak forKey: @"HighScore"];
            //highscore.text = [NSString stringWithFormat:@"highest streak: %5.0f\t",streak];
            
        }
    }else{
        correct = false;
        result = crossView;
        wrongCount ++;
        streak =0.0;
        
    }
    //[self.view bringSubviewToFront:result];
    result.hidden = NO;
	[self animateCorrectWrongView:result];
	//[self checkWord:self.selectedV];
}




- (void)grow3AnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    
    [word1 setFrame: wordButton1.frame];
    [word2 setFrame: wordButton2.frame];
    [word3 setFrame: wordButton3.frame];
    [word4 setFrame: wordButton4.frame];
    
    [self.view bringSubviewToFront:word3];
    [self.view bringSubviewToFront:word4];
    
    
    tickView.hidden = YES;
    crossView.hidden = YES;
    tickView.transform =CGAffineTransformIdentity;
    crossView.transform =CGAffineTransformIdentity;
    
    if (correct){
        [wordModel selectNextWord];
        NSArray *words=[wordModel getWords];
        //NSLog(@"@&",[words objectAtIndex:0]);
        [word1 addWord:(NSString*)[words objectAtIndex:0]];
        [word2 addWord:[words objectAtIndex:1]];
        [word3 addWord:[words objectAtIndex:2]];
        [word4 addWord:[words objectAtIndex:3]];
        
        [wordButton1 setTitle: (NSString*)[words objectAtIndex:0] forState: UIControlStateNormal];
        [wordButton2 setTitle: (NSString*)[words objectAtIndex:1] forState: UIControlStateNormal];
        [wordButton3 setTitle: (NSString*)[words objectAtIndex:2] forState: UIControlStateNormal];
        [wordButton4 setTitle: (NSString*)[words objectAtIndex:3] forState:UIControlStateNormal];
        
        [definitionTV setText: wordModel.definition];
    }
    float percentage = correctCount/(correctCount+wrongCount);
	if(correctCount== 0)
		percentage = 0.0;
    //XXX TODO String extern def
	NSString *showing = [NSString stringWithFormat:@"streak: %5.0f\t\tword count: %.0f\t\tcorrect: %.0f%%",streak,correctCount,percentage*100];
    score.text =showing;
}



- (void)animateWordToPlace:(WordView *) selectedView {
	
	// Bounces the placard back to the center
	
	CALayer *welcomeLayer = selectedView.layer;
	
	// Create a keyframe animation to follow a path back to the center
	CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
	bounceAnimation.removedOnCompletion = NO;
	
	CGFloat animationDuration = 0.1;
	
	
	// Create the path for the bounces
	CGMutablePathRef thePath = CGPathCreateMutable();
	
	CGFloat midX = gapLabel.center.x;
	CGFloat midY = gapLabel.center.y;
	CGFloat originalOffsetX = selectedView.center.x - midX;
	CGFloat originalOffsetY = selectedView.center.y - midY;
	CGFloat offsetDivider = 4.0;
	
	BOOL stopBouncing = NO;
	
	// Start the path at the placard's current location
	CGPathMoveToPoint(thePath, NULL, selectedView.center.x, selectedView.center.y);
	CGPathAddLineToPoint(thePath, NULL, midX, midY);
	
	// Add to the bounce path in decreasing excursions from the center
	while (stopBouncing != YES) {
		CGPathAddLineToPoint(thePath, NULL, midX + originalOffsetX/offsetDivider, midY + originalOffsetY/offsetDivider);
		CGPathAddLineToPoint(thePath, NULL, midX, midY);
		
		offsetDivider += 4;
		animationDuration += 1/offsetDivider;
		if ((abs(originalOffsetX/offsetDivider) < 6) && (abs(originalOffsetY/offsetDivider) < 6)) {
			stopBouncing = YES;
		}
	}
	
	bounceAnimation.path = thePath;
	bounceAnimation.duration = animationDuration;
	
	
	// Create a basic animation to restore the size of the placard
	//CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
	//transformAnimation.removedOnCompletion = YES;
	//transformAnimation.duration = animationDuration;
	//transformAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
	
	// Create an animation group to combine the keyframe and basic animations
	CAAnimationGroup *theGroup = [CAAnimationGroup animation];
	
	// Set self as the delegate to allow for a callback to reenable user interaction
	theGroup.delegate = self;
	theGroup.duration = animationDuration;
	theGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
	
	theGroup.animations = [NSArray arrayWithObjects:bounceAnimation, nil];
	
	
	// Add the animation group to the layer
	[welcomeLayer addAnimation:theGroup forKey:@"animatePlacardViewToCenter"];
	
	// Set the placard view's center and transformation to the original values in preparation for the end of the animation
	selectedView.center = gapLabel.center;
	selectedView.transform = CGAffineTransformIdentity;
    selected = [selectedView getWord];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    return true;
}


@end
