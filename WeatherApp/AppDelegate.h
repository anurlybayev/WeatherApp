//
//  AppDelegate.h
//  WeatherApp
//
//  Created by Akbar Nurlybayev on 1/29/2014.
//  Copyright (c) 2014 Akbar Nurlybayev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic, readonly) NSMutableDictionary *currentConditionsCache;

@end
