//
//  MainViewController.h
//  Blanks
//
//  Created by Kai Kunze on 19/10/2013.
//  Copyright (c) 2013 Kai Kunze. All rights reserved.
//

#import "OptionsViewController.h"
#import "WordModel.h"

@interface BlanksViewController : UIViewController <OptionsViewControllerDelegate>{
    
    WordModel *wordModel;
    IBOutlet UIButton* wordButton1;
    IBOutlet UIButton* wordButton2;
    IBOutlet UIButton* wordButton3;
    IBOutlet UIButton* wordButton4;
    
    IBOutlet UITextView *definitionTV;
    IBOutlet UIImageView *tickView;
    IBOutlet UIImageView *crossView;
    
    // XXX TODO better in word model??
    float correctCount;
    float wrongCount;
    float streak;
    NSNumber *highestStreak;
}

@end
