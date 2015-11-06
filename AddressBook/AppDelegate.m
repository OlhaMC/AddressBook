//
//  AppDelegate.m
//  AddressBook
//
//  Created by Admin on 02.11.15.
//  Copyright (c) 2015 OlhaF. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    UINavigationController * navigationController = [[UINavigationController alloc] initWithRootViewController:self.window.rootViewController];
    self.window.rootViewController = navigationController;
    
    return YES;
}

@end
