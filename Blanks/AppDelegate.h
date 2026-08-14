//
//  AppDelegate.h
//  Blanks
//
//  Created by Kai Kunze on 19/10/2013.
//  Copyright (c) 2013 Kai Kunze. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>{
    NSDictionary *tosend;
    bool logging;
}

@property (retain, atomic) NSDictionary *tosend;
@property (strong, nonatomic) UIWindow *window;

@end
