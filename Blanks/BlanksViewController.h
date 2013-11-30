//
//  MainViewController.h
//  Blanks
//
//  Created by Kai Kunze on 19/10/2013.
//  Copyright (c) 2013 Kai Kunze. All rights reserved.
//

#import "OptionsViewController.h"
#import "WordModel.h"
#import "WordView.h"

@interface BlanksViewController : UIViewController <OptionsViewControllerDelegate>{
    
    WordModel *wordModel;
    
    bool isTapping;
    IBOutlet UIButton* wordButton1;
    IBOutlet UIButton* wordButton2;
    IBOutlet UIButton* wordButton3;
    IBOutlet UIButton* wordButton4;
    
    __weak IBOutlet UILabel *score;
    
    WordView * word1;
    WordView * word2;
    WordView * word3;
    WordView * word4;
    
    __weak IBOutlet UILabel *gapLabel;
    IBOutlet UITextView *definitionTV;
    IBOutlet UIImageView *tickView;
    IBOutlet UIImageView *crossView;
    
    // XXX TODO better in word model??
    float correctCount;
    float wrongCount;
    float streak;
    NSNumber *highestStreak;
    
    NSString *selected;
    bool correct;
}

@end
