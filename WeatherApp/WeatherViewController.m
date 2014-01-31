//
//  WeatherViewController.m
//  WeatherApp
//
//  Created by Akbar Nurlybayev on 1/29/2014.
//  Copyright (c) 2014 Akbar Nurlybayev. All rights reserved.
//

#import "WeatherViewController.h"
#import "AppDelegate.h"
#import "PXAPI.h"

NSString *const FETCH_TIMESTAMP_KEY = @"FetchTimestamp";
NSString *const CURRENT_CONDITIONS_KEY = @"CurrentConditions";

@interface WeatherViewController ()

@property(nonatomic, strong) NSDictionary *currentConditions;
@property(nonatomic, strong) NSDictionary *forecast;

@property(nonatomic, readonly) AppDelegate *appDel;
@property(nonatomic, readonly) NSString *openWeatherMapApiKey;
@property(nonatomic, readonly) NSString *APIEndPoint;

@property(nonatomic, strong) NSURLSession *session;

@property (weak, nonatomic) IBOutlet UIImageView *wallpaper;
@property (weak, nonatomic) IBOutlet UILabel *currentTemperature;
@property (weak, nonatomic) IBOutlet UISegmentedControl *temperatureUnits;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@end

@implementation WeatherViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.currentTemperature.font = [[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline] fontWithSize:72.0];
    self.currentTemperature.textColor = [UIColor whiteColor];
    self.wallpaper.backgroundColor = [UIColor lightGrayColor];
    [self.spinner stopAnimating];
    [self fetchCurrentConditions];
    [self fetchWallpaper];
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
        [self.spinner startAnimating];
        __weak typeof(self) wself = self;
        NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                                 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                                     if (!error) {
                                                                         NSError *parseError = nil;
                                                                         NSMutableDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                                                                                                     options:NSJSONReadingMutableContainers
                                                                                                                                       error:&parseError];
                                                                         [json setObject:[NSDate date] forKey:FETCH_TIMESTAMP_KEY];
                                                                         
                                                                         dispatch_async(dispatch_get_main_queue(), ^{
                                                                             wself.currentConditions = json;
                                                                             [wself.spinner stopAnimating];
                                                                         });
                                                                     } else {
                                                                         dispatch_async(dispatch_get_main_queue(), ^{
                                                                             NSLog(@"%@", [error localizedDescription]);
                                                                             [wself.spinner stopAnimating];
                                                                         });
                                                                     }
                                                                     
                                                                 }];
        [task resume];
    } else {
        self.currentConditions = [[self.appDel.currentConditionsCache objectForKey:self.country] objectForKey:self.city];
    }
}

- (void)fetchWallpaper
{
    __weak typeof(self) wself = self;
    [PXRequest setConsumerKey:@"" consumerSecret:@""];
    
    [PXRequest requestForSearchTerm:[self.city stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                          searchTag:@"urban"
                          searchGeo:nil
                               page:1
                     resultsPerPage:20
                         photoSizes:PXPhotoModelSizeThumbnail
                             except:PXPhotoModelCategoryUncategorized
                         completion:^(NSDictionary *results, NSError *error) {
                             NSLog(@"%@", results);
                             NSArray *photos = [results objectForKey:@"photos"];
                             if (photos && [photos count]) {
                                 NSInteger photoIndex = arc4random() % [photos count];
                                 NSDictionary *photo = [photos objectAtIndex:photoIndex];
                                 NSString *imageURL = [[photo objectForKey:@"image_url"] lastObject];
                                 if (imageURL) {
                                     UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]]];
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                         wself.wallpaper.image = img;
                                         
                                     });
                                 }
                             }
                         }];

}

- (void)setCurrentConditions:(NSDictionary *)currentConditions
{
    _currentConditions = currentConditions;
    NSString *city = currentConditions[@"name"];
    if (!city) {
        self.currentTemperature.text = @"N/A";
        self.temperatureUnits.enabled = NO;
    } else {
        NSMutableDictionary *countryCache = [self.appDel.currentConditionsCache objectForKey:self.country];
        if (!countryCache) {
            countryCache = [NSMutableDictionary dictionaryWithObject:currentConditions forKey:city];
        } else {
            [countryCache setObject:currentConditions forKey:city];
        }
        [self.appDel.currentConditionsCache setObject:countryCache forKey:self.country];
        
        [self convertTemperatureToDifferentUnit:self.temperatureUnits];
    }
}

- (AppDelegate *)appDel
{
    return [[UIApplication sharedApplication] delegate];
}

#pragma mark - IBActions

- (IBAction)convertTemperatureToDifferentUnit:(UISegmentedControl *)sender
{
    CGFloat temp = [self.currentConditions[@"main"][@"temp"] floatValue];
    if (sender.selectedSegmentIndex == 0) {
        self.currentTemperature.text = [NSString stringWithFormat:@"%.f ℃", temp];
    } else {
        temp = temp * 1.8 + 32;
        self.currentTemperature.text = [NSString stringWithFormat:@"%.f ℉", temp];
    }
}


@end
