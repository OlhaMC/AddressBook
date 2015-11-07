//
//  ViewController.m
//  AddressBook
//
//  Created by Admin on 02.11.15.
//  Copyright (c) 2015 OlhaF. All rights reserved.
//

#import "ViewController.h"
#import "SettingsController.h"
#import "AddContactController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITableView * tableView;
@property (strong, nonatomic) NSMutableArray * contactsArray;

@end

@implementation ViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.contactsArray = [NSMutableArray array];
    self.title = @"Address Book";
    [self addLeftNavigationButton];
    [self addRightNavigationButton];
    
    [self verifyUserDefaults];
    [self reloadContactsArray];
    
    //NSLog(@"%@", [self.contactsArray description]);
}

- (void) viewWillAppear:(BOOL)animated
{
    [self reloadContactsArray];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Manage Contacts information

- (void) reloadContactsArray
{
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSString * contactDirectoryPath = [self getPathToContactsDirectory];
    
    NSError * error = nil;
    NSMutableArray * contactFilesArray = [[fileManager contentsOfDirectoryAtPath:contactDirectoryPath error:&error] copy];
    
    [self.contactsArray removeAllObjects];
    for (NSUInteger i=0; i < contactFilesArray.count ; i++)
    {
        if ([[contactFilesArray[i] pathExtension] isEqualToString: @"plist"])
        {
            NSString * contactProfilePath = [contactDirectoryPath stringByAppendingPathComponent:contactFilesArray[i]];
            NSMutableDictionary * contactProfile =
            [[NSMutableDictionary alloc] initWithContentsOfFile:contactProfilePath];
            [self.contactsArray addObject:contactProfile];
        }
    }
    
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSString * sortKey = [userDefaults boolForKey:@"SortByLastName"]?@"Last Name":@"Name";
    [self sortContactsByKey:sortKey];
}

- (void) sortContactsByKey: (NSString*) key
{
    NSSortDescriptor * sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:key ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray * arrayDescriptor = [NSArray arrayWithObject:sortDescriptor];
    NSArray * sortedArray = [self.contactsArray sortedArrayUsingDescriptors:arrayDescriptor];
    self.contactsArray = [sortedArray mutableCopy];
}

- (NSString *) getPathToContactsDirectory
{
    NSArray * pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * pathToDocumentDirectory = [pathArray objectAtIndex:0];
    NSString * contactDirectoryPath = [pathToDocumentDirectory stringByAppendingPathComponent:@"Contacts"];
    //NSLog(@"%@", pathToDocumentDirectory);
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSError * error = nil;
    if (![fileManager fileExistsAtPath:contactDirectoryPath])
    {
        [fileManager createDirectoryAtPath:contactDirectoryPath withIntermediateDirectories:NO attributes:nil error:&error];
    }
    return contactDirectoryPath;
}

- (void) deleteContactAtPath: (NSString*) path
{
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSError * error = nil;
    if ([fileManager fileExistsAtPath:path])
    {
        [fileManager removeItemAtPath:path error:&error];
    }
    NSString * imagePath = [[path stringByDeletingPathExtension] stringByAppendingPathExtension:@"png"];
    if ([fileManager fileExistsAtPath:imagePath])
    {
        [fileManager removeItemAtPath:imagePath error:&error];
    }
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
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.contactsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * identifier = @"cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier: identifier];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    NSMutableDictionary * contactProfile = [self.contactsArray objectAtIndex:indexPath.row];
    NSString * name = [contactProfile objectForKey:@"Name"];
    NSString * lastName = [contactProfile objectForKey:@"Last Name"];
    
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults boolForKey:@"SortByLastName"])
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", lastName, name];
    else
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", name, lastName];
    
    NSString * contactDirectoryPath = [self getPathToContactsDirectory];
    NSUInteger index = [[contactProfile valueForKey:@"index"] integerValue];
    NSString * pathComponent = [[NSString alloc] initWithFormat:@"Contact%ld.png", index];
    NSString * imagePath = [contactDirectoryPath stringByAppendingPathComponent:pathComponent];
    
    NSData * imageData = [NSData dataWithContentsOfFile:imagePath];
    UIImage * photoImage = [UIImage imageWithData:imageData];
    cell.imageView.image = photoImage;
    
    return cell;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView setEditing:NO];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    AddContactController * addContactController = [self.storyboard instantiateViewControllerWithIdentifier:@"AddContactView"];
    addContactController.title = @"Info";
    
    NSMutableDictionary * contactProfile = [self.contactsArray objectAtIndex:indexPath.row];
    addContactController.contactProfile = contactProfile;
    
    [self.navigationController pushViewController:addContactController animated:YES];
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults boolForKey:@"DarkInterface"])
    {
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.backgroundColor = [UIColor darkGrayColor];
    }
    else
    {
        cell.textLabel.textColor = [UIColor blackColor];
        cell.backgroundColor = [UIColor whiteColor];
    }
}

#pragma mark - NavigationBar Buttons

- (void) addLeftNavigationButton
{
    UIBarButtonItem * settingsButton = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStylePlain target:self action:@selector(settingsClickAction:)];
    [self.navigationItem setLeftBarButtonItem:settingsButton];
}

- (void) addRightNavigationButton
{
    UIBarButtonItem * newContactButton = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStylePlain target:self action:@selector(addContactClickAction:)];
    [self.navigationItem setRightBarButtonItem:newContactButton];
}

- (IBAction) settingsClickAction:(id)sender
{
    SettingsController * settingsController = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsView"];
    
    [self.navigationController pushViewController:settingsController animated:YES];
}

- (IBAction) addContactClickAction:(id)sender
{
    AddContactController * addContactController = [self.storyboard instantiateViewControllerWithIdentifier:@"AddContactView"];
    
    [self.navigationController pushViewController:addContactController animated:YES];
}

@end
