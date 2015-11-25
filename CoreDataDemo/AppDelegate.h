//
//  AppDelegate.h
//  CoreDataDemo
//
//  Created by RYAN on 15/11/11.
//  Copyright © 2015年 ryan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (assign, nonatomic) UIBackgroundTaskIdentifier backgroundUpdateTask;
@property (strong, nonatomic) NSTimer *myTimer;
@end

