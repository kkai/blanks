//
//  WordModel.m
//  Blanks
//
//  Created by Kai Kunze on 05.08.12.
//  Copyright (c) 2012 Kai Kunze. All rights reserved.
//

#import "WordModel.h"

@implementation WordModel

@synthesize correct,definition,difficulty;

-(id) init{
	self=[super init];
    if (self) {
        srandom(time(NULL));
        NSString *filename =@"average";
        difficulty = [[NSUserDefaults standardUserDefaults] objectForKey: @"Difficulty"];
        if(!difficulty){
            difficulty =@"average";
            [[NSUserDefaults standardUserDefaults] setObject: difficulty forKey: @"Difficulty"];
        }else{
            filename = difficulty;
        }
        //XXX TODO fix filename stuff
        filename = @"average";
        NSString *path = [[NSBundle mainBundle]  pathForResource:filename ofType:@"plist"];
        wordsArray = [[NSMutableArray alloc] initWithContentsOfFile:path];
        
        int randWordID = random() % [wordsArray count];
        NSMutableDictionary *element = [wordsArray objectAtIndex:randWordID];
        self.correct=[element objectForKey:(id)@"word"];
        self.definition=[element objectForKey:(id)@"definition"];
        falseWordArray=[element objectForKey:(id)@"false"];
        return self;

    }
    return self;
}

-(BOOL) didListChange{
	NSString *newDifficulty = [[NSUserDefaults standardUserDefaults] objectForKey: @"Difficulty"];
	return ![difficulty isEqualToString:newDifficulty];
}

///XXX TODO  XXX fix duplicate code
-(void) checkOptions{
	NSString *newDifficulty = [[NSUserDefaults standardUserDefaults] objectForKey: @"Difficulty"];
	if( ![difficulty isEqualToString:newDifficulty]){
		difficulty = newDifficulty;
		NSString *path = [[NSBundle mainBundle]  pathForResource:difficulty ofType:@"plist"];
		wordsArray = [[NSMutableArray alloc] initWithContentsOfFile:path];
		srandom(time(NULL));
        [self selectNextWord];
	}
}
-(void) selectNextWord{
    int randWordID = random() % [wordsArray count];
	NSMutableDictionary *element = [wordsArray objectAtIndex:randWordID];
	self.correct=[element objectForKey:(id)@"word"];
	self.definition=[element objectForKey:(id)@"definition"];
	falseWordArray=[element objectForKey:(id)@"false"];
	//NSLog(@"correct %@, definition %@", correct, definition);
	
}


-(NSArray*) getWords{
	NSMutableArray *words= [[NSMutableArray alloc] initWithCapacity:4];
	int first = random() % [falseWordArray count];
	int second = random() % [falseWordArray count];
	while(first == second){
		second = random() % [falseWordArray count];
	}
	int third = random() % [falseWordArray count];
	while((third == first) ||(third == second)){
		third = random() % [falseWordArray count];
	}
	
	[words insertObject:[falseWordArray objectAtIndex:first] atIndex:0];
	[words insertObject:[falseWordArray objectAtIndex:second] atIndex:1];
	[words insertObject:[falseWordArray objectAtIndex:third] atIndex:2];
	[words insertObject:correct atIndex:3];
    
	int firstObject = 0;
	for (int i = 0; i<[words count];i++) {
		NSUInteger randomIndex = random() % [words count];
		[words exchangeObjectAtIndex:firstObject withObjectAtIndex:randomIndex];
		firstObject +=1;
	}
	
	return words;
}



@end