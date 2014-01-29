//
//  WeatherViewController.m
//  WeatherApp
//
//  Created by Akbar Nurlybayev on 1/29/2014.
//  Copyright (c) 2014 Akbar Nurlybayev. All rights reserved.
//

#import "WeatherViewController.h"
#import "AppDelegate.h"

NSString *const FETCH_TIMESTAMP_KEY = @"FetchTimestamp";
NSString *const CURRENT_CONDITIONS_KEY = @"CurrentConditions";

@interface WeatherViewController ()

@property(nonatomic, strong) NSDictionary *currentConditions;
@property(nonatomic, strong) NSDictionary *forecast;

@property(nonatomic, readonly) AppDelegate *appDel;
@property(nonatomic, readonly) NSString *openWeatherMapApiKey;
@property(nonatomic, readonly) NSString *APIEndPoint;

@property(nonatomic, strong) NSURLSession *session;

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
    [self fetchCurrentConditions];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (NSString *)openWeatherMapApiKey
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"OpenWeatherMap"];
}

- (NSString *)APIEndPoint
{
    return @"http://api.openweathermap.org/data/2.5/";
}

- (BOOL)shouldUpdateCurrentConditions
{
    if (self.country && self.city) {
        NSMutableDictionary *countryCache = [self.appDel.currentConditionsCache objectForKey:self.country];
        NSDictionary *currentConditions = [countryCache objectForKey:self.city];
        NSDate *prevFetch = [currentConditions objectForKey:FETCH_TIMESTAMP_KEY];
        if (prevFetch) {
            NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSDateComponents *components = [calendar components:NSCalendarUnitMinute
                                                       fromDate:prevFetch
                                                         toDate:[NSDate date]
                                                        options:0];
            if (components.minute > 10) {
                return YES;
            } else {
                return NO;
            }
        } else {
            return YES;
        }
    } else {
        return NO;
    }
}

- (void)fetchCurrentConditions
{
    if ([self shouldUpdateCurrentConditions]) {
        NSString *endPoint = [NSString stringWithFormat:@"%@weather?q=%@,%@&units=metric&APPID=%@",
                              self.APIEndPoint,
                              [self.city stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                              [self.country stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                              self.openWeatherMapApiKey];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:endPoint]];
        NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                                 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                                     if (!error) {
                                                                         NSError *parseError = nil;
                                                                         NSMutableDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                                                                                                     options:NSJSONReadingMutableContainers
                                                                                                                                       error:&parseError];
                                                                         [json setObject:[NSDate date] forKey:FETCH_TIMESTAMP_KEY];
                                                                         self.currentConditions = json;
                                                                     }
                                                                 }];
        [task resume];
    } else {
        self.currentConditions = [[self.appDel.currentConditionsCache objectForKey:self.country] objectForKey:self.city];
    }
}

- (void)setCurrentConditions:(NSDictionary *)currentConditions
{
    _currentConditions = currentConditions;
    NSString *city = currentConditions[@"name"];
    NSMutableDictionary *countryCache = [self.appDel.currentConditionsCache objectForKey:self.country];
    if (!countryCache) {
        countryCache = [NSMutableDictionary dictionaryWithObject:currentConditions forKey:city];
    } else {
        [countryCache setObject:currentConditions forKey:city];
    }
    [self.appDel.currentConditionsCache setObject:countryCache forKey:self.country];
}

- (AppDelegate *)appDel
{
    return [[UIApplication sharedApplication] delegate];
}

@end
