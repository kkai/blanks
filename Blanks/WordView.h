//
//  WordView.h
//  Blanks
//
//  Created by Kai Kunze on 05.08.12.
//  Copyright (c) 2012 Kai Kunze. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WordView : UIView{
    UIImage *image;
    NSString *text;
    
    __weak IBOutlet UILabel *label;
}


-(void) addWord:(NSString*)word;
-(NSString*) getWord;


@end
