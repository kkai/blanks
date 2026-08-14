//
//  AppDelegate.m
//  Blanks
//
//  Created by Kai Kunze on 19/10/2013.
//  Copyright (c) 2013 Kai Kunze. All rights reserved.
//

#import "AppDelegate.h"
//#import "Purchases.h"

@implementation AppDelegate

NSMutableData *mutData;

@synthesize tosend;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    

    
    logging = false;
    NSString *url = @"http://kaikunze.de/bl.html";
    NSURL *urlRequest = [NSURL URLWithString:url];
    NSError *err = nil;
    
    NSString *h = [NSString stringWithContentsOfURL:urlRequest encoding:NSUTF8StringEncoding error:&err];
    //NSLog(@"%@",h);
    if([h isEqualToString:@"on\n"]){
        //NSLog(@"Logging is %@",h);
        logging = true;
    }
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    //NSLog(@"inactive");
    //NSLog(@"%@",tosend);

    
    if(logging){
        NSURL *url = [NSURL URLWithString:@"http://geist.kmd.keio.ac.jp:8000/"];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:3.0];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"bla-blup" forHTTPHeaderField:@"test"];
        
        //[request setValue:[NSString stringWithFormat:@"%ld", (unsigned long)[tosend length]] forHTTPHeaderField:@"Content-Length"];
        //[request setHTTPBody:tosend];
        //[request setValue:@"text/html" forHTTPHeaderField:@"Content-Type"];
        //NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        //[connection start];
        
        for(id key in tosend){
            //NSLog(@"key=%@ value=%@", key, [tosend objectForKey:key]);
            [request setValue: [tosend objectForKey:key] forHTTPHeaderField: key];
        }
        //NSError *err = nil;
        NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
        //NSString *urls = @"http://geist.kmd.keio.ac.jp:8000/";
        //NSURL *urlRequest = [NSURL URLWithString:urls];

        //NSString *h = [NSString stringWithContentsOfURL:urlRequest encoding:NSUTF8StringEncoding error:&err];

        //NSLog(@"return %@",h);
    }
}

@end
