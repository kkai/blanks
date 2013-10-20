//
//  WordModel.h
//  Blanks
//
//  Created by Kai Kunze on 05.08.12.
//  Copyright (c) 2012 Kai Kunze. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WordModel : NSObject{
	NSArray *wordsArray;
    NSArray *falseWordArray;
	NSString *difficulty;
	
	NSString *correct;
	NSString *definition;
	NSMutableArray *falseWords;
}

@property (nonatomic, retain) NSString *correct;
@property (nonatomic, retain) NSString *definition;
@property (nonatomic, retain) NSString *difficulty;

//@property (nonatomic, retain) NSArray *falseWordArray;

-(id) init;
-(void) checkOptions;
-(NSArray*) getWords;
-(void) selectNextWord;
-(BOOL) didListChange;


@end
