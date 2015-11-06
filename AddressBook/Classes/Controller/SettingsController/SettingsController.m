//
//  SettingsController.m
//  AddressBook
//
//  Created by Admin on 03.11.15.
//  Copyright (c) 2015 OlhaF. All rights reserved.
//

#import "SettingsController.h"
@interface SettingsController ()

@property (weak, nonatomic) IBOutlet UILabel * nameSortLable;
@property (weak, nonatomic) IBOutlet UILabel * darkInterfaceLable;
@property (weak, nonatomic) IBOutlet UISwitch * nameSortSwitch;
@property (weak, nonatomic) IBOutlet UISwitch * darkInterfaceSwitch;

@end

@implementation SettingsController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Settings";
    [self verifyUserDefaults];

}
- (void) viewWillAppear:(BOOL)animated
{
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    self.nameSortSwitch.on = [userDefaults boolForKey:@"SortByLastName"];
    self.darkInterfaceSwitch.on = [userDefaults boolForKey:@"DarkInterface"];
    [self updateColors];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) verifyUserDefaults
{
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:@"numeratorOfCreatedContacts"] == 0)
    {
        [userDefaults setBool:NO forKey:@"SortByLastName"];
        [userDefaults setBool:NO forKey:@"DarkInterface"];
        [userDefaults setInteger:0 forKey:@"numeratorOfCreatedContacts"];
        [userDefaults synchronize];
    }
    self.nameSortSwitch.on = [userDefaults boolForKey:@"SortByLastName"];
    self.darkInterfaceSwitch.on = [userDefaults boolForKey:@"DarkInterface"];
}

#pragma mark - Switch actions

- (IBAction)changeSortParameterAction:(UISwitch*)sender
{
   NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];

    [userDefaults setBool:sender.on forKey:@"SortByLastName"];
    [userDefaults synchronize];
}

- (IBAction)changeInterfaceColorAction:(UISwitch*)sender
{
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:sender.on forKey:@"DarkInterface"];
    [userDefaults synchronize];

    [self updateColors];
}

- (void) updateColors
{
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults boolForKey:@"DarkInterface"])
    {
        self.view.backgroundColor = [UIColor darkGrayColor];
        self.nameSortLable.textColor = [UIColor whiteColor];
        self.darkInterfaceLable.textColor = [UIColor whiteColor];
    }
    else
    {
        self.view.backgroundColor = [UIColor whiteColor];
        self.nameSortLable.textColor = [UIColor blackColor];
        self.darkInterfaceLable.textColor = [UIColor blackColor];
    }
}

@end
