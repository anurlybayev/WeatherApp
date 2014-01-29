//
//  ViewController.m
//  WeatherApp
//
//  Created by Akbar Nurlybayev on 1/29/2014.
//  Copyright (c) 2014 Akbar Nurlybayev. All rights reserved.
//

#import "ViewController.h"
#import "WeatherViewController.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, strong) NSArray *countries;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"countries" ofType:@"json"];
	NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSError *parseError = nil;
    id json = [NSJSONSerialization JSONObjectWithData:data
                                              options:0
                                                error:&parseError];
    if (!parseError) {
        if ([json isKindOfClass:[NSArray class]]) {
            NSArray *countries = json;
            self.countries = [countries sortedArrayUsingComparator:^NSComparisonResult(NSDictionary* country1, NSDictionary* country2) {
                return [country1[@"capital"] compare:country2[@"capital"]];
            }];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[WeatherViewController class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        NSDictionary *country = self.countries[indexPath.row];
        WeatherViewController *wvc = (WeatherViewController *)segue.destinationViewController;
        wvc.country = country[@"name"];
        wvc.city = country[@"capital"];
    }
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.countries count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *country = self.countries[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CapitalCell" forIndexPath:indexPath];
    cell.textLabel.text = country[@"capital"];
    cell.detailTextLabel.text = country[@"name"];
    
    return cell;
}

@end
