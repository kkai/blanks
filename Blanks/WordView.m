//
//  WordView.m
//  Blanks
//
//  Created by Kai Kunze on 05.08.12.
//  Copyright (c) 2012 Kai Kunze. All rights reserved.
//

#import "WordView.h"

@implementation WordView

-(void) addWord:(NSString*)word{
    label.text = word;
}

-(NSString*) getWord{
    return label.text;
}


@end
