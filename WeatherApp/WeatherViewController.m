//
//  WeatherViewController.m
//  WeatherApp
//
//  Created by Akbar Nurlybayev on 1/29/2014.
//  Copyright (c) 2014 Akbar Nurlybayev. All rights reserved.
//

#import "WeatherViewController.h"

@interface WeatherViewController ()

@property(nonatomic, readonly) NSString *openWeatherMapApiKey;

@end

@implementation WeatherViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"%@", self.openWeatherMapApiKey);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)openWeatherMapApiKey
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"OpenWeatherMap"];
}

@end
