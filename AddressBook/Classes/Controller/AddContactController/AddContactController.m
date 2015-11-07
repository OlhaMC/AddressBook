//
//  AddContactController.m
//  AddressBook
//
//  Created by Admin on 04.11.15.
//  Copyright (c) 2015 OlhaF. All rights reserved.
//

#import "AddContactController.h"

@interface AddContactController ()

@property (weak, nonatomic) IBOutlet UILabel *nameLable;
@property (weak, nonatomic) IBOutlet UILabel *lastNameLable;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumberLable;
@property (weak, nonatomic) IBOutlet UILabel *emailLable;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *EmailTextField;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *chooseImageButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIButton *photoButton;

@end

@implementation AddContactController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.deleteButton.enabled=NO;
    self.deleteButton.hidden = YES;
    
    if (self.contactProfile)
    {
        [self addRightNavigationButton];
        [self showInformationForContact: self.contactProfile];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated
{
    [self updateColors];
}

#pragma mark - Button actions
-(IBAction)saveAction:(UIButton*)sender
{
    [self.nameTextField resignFirstResponder];
    [self.lastNameTextField resignFirstResponder];
    [self.phoneTextField resignFirstResponder];
    [self.EmailTextField resignFirstResponder];
    
    NSString * name =[self.nameTextField text];
    NSString * lastName = [self.lastNameTextField text];
    NSString * phone = [self.phoneTextField text];
    NSString * email = [self.EmailTextField text];
    
    UIImage * photoImage = self.imageView.image;
    NSData * imageData = UIImagePNGRepresentation(photoImage);
    
    if ([name length] || [lastName length])
    {
        NSMutableDictionary * contactProperties;
        if (!self.contactProfile)
            contactProperties = [self createNewContactFile];
        else
            contactProperties = self.contactProfile;
        
        [contactProperties setValue:name forKey:@"Name"];
        [contactProperties setValue:lastName forKey:@"Last Name"];
        [contactProperties setValue:phone forKey:@"Phone Number"];
        [contactProperties setValue:email forKey:@"Email"];
        
        NSUInteger index = [[contactProperties valueForKey:@"index"] integerValue];
        NSString * newContactPath = [self getContactPathWithIndex:index];
        NSString * contactImagePath = [[newContactPath stringByDeletingPathExtension] stringByAppendingPathExtension:@"png"];
        
        [contactProperties writeToFile:newContactPath atomically:YES];
        [imageData writeToFile:contactImagePath atomically:YES];
    
        dispatch_async(dispatch_get_main_queue(), ^{
        [self blockEditing];
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Done" message:@"Successfully saved" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        });
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"No Name" message:@"Enter Name and Last name" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            });
    }
}

- (IBAction)chooseImageAction:(UIButton*)sender
{
    UIImagePickerController * piker = [[UIImagePickerController alloc] init];
    piker.delegate = self;
    piker.allowsEditing = YES;
    piker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:piker animated:YES completion:nil];
}

- (IBAction)choosePhotoAction:(UIButton*)sender
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController * piker = [[UIImagePickerController alloc] init];
        piker.delegate = self;
        piker.allowsEditing = YES;
        piker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:piker animated:YES completion:nil];
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"No Camera" message:@"Camera is unavailable" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        });
    }
}

- (IBAction)editContactAction:(id)sender
{
    self.chooseImageButton.enabled = YES;
    self.chooseImageButton.hidden = NO;
    self.photoButton.enabled = YES;
    self.photoButton.hidden = NO;
    self.saveButton.enabled = YES;
    self.saveButton.hidden = NO;
    self.deleteButton.enabled = NO;
    self.deleteButton.hidden = YES;
    
    self.nameTextField.enabled = YES;
    self.lastNameTextField.enabled = YES;
    self.phoneTextField.enabled = YES;
    self.EmailTextField.enabled = YES;
}

- (IBAction) deleteContactAction:(id)sender
{
    NSUInteger index = [[self.contactProfile valueForKey:@"index"] integerValue];
    NSString * contactPath =[self getContactPathWithIndex:index];
    
    [self deleteContactAtPath:contactPath];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self blockEditing];
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Done" message:@"Contact deleted" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    });
    
    UIViewController * contactListController = [self.storyboard instantiateViewControllerWithIdentifier:@"contactList"];
    [self.navigationController pushViewController:contactListController animated:YES];
}

#pragma mark - Manage files

- (NSMutableDictionary*) createNewContactFile
{
    NSFileManager * fileManager = [NSFileManager defaultManager];
    
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSUInteger contactNumerator = [userDefaults integerForKey:@"numeratorOfCreatedContacts"]+1;
    
    NSError * error = nil;
    NSString * sampleFilePath = [[NSBundle mainBundle] pathForResource:@"SampleFile" ofType:@"plist"];
    NSString * newContactPath = [self getContactPathWithIndex:contactNumerator];
    
    if (![fileManager fileExistsAtPath:newContactPath])
    {
        [fileManager copyItemAtPath:sampleFilePath toPath:newContactPath error:&error];
        [userDefaults setInteger:contactNumerator forKey:@"numeratorOfCreatedContacts"];
        [userDefaults synchronize];
    }
    
    NSMutableDictionary * newContact = [[NSMutableDictionary alloc] initWithContentsOfFile:newContactPath];
    [newContact setObject: @(contactNumerator) forKey:@"index"];

    return newContact;
}

- (NSString*) getContactDirectoryPath
{
    NSArray * pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * pathToDocumentDirectory = [pathArray objectAtIndex:0];
    NSString * contactDirectoryPath = [pathToDocumentDirectory stringByAppendingPathComponent:@"Contacts"];
    return contactDirectoryPath;
}

- (NSString*) getContactPathWithIndex: (NSUInteger) index
{
    NSString * contactDirectoryPath = [self getContactDirectoryPath];
    NSString * contactPath =
    [contactDirectoryPath stringByAppendingPathComponent:
     [NSString stringWithFormat:@"Contact%ld.plist", index]];
    return contactPath;
}

- (NSString*) getImagePathWithIndex: (NSUInteger) index
{
    NSString * contactDirectoryPath = [self getContactDirectoryPath];
    NSString * imagePath =
    [contactDirectoryPath stringByAppendingPathComponent:
     [NSString stringWithFormat:@"Contact%ld.png", index]];
    return imagePath;
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
        [fileManager removeItemAtPath:imagePath error:&error];
}

#pragma mark - ImagePickerDelegate

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    self.imageView.image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Show and Edit contact

- (void) addRightNavigationButton
{
    UIBarButtonItem * editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(editContactAction:)];
    [self.navigationItem setRightBarButtonItem:editButton];
}

- (void) showInformationForContact: (NSDictionary*) contactProfile
{
    self.nameTextField.text = [contactProfile valueForKey:@"Name"];
    self.lastNameTextField.text = [contactProfile valueForKey:@"Last Name"];
    self.phoneTextField.text = [contactProfile valueForKey:@"Phone Number"];
    self.EmailTextField.text = [contactProfile valueForKey:@"Email"];
    
    NSUInteger index = [[contactProfile valueForKey:@"index"] integerValue];
    NSString * imagePath = [self getImagePathWithIndex:index];
    
    NSData * imageData = [NSData dataWithContentsOfFile:imagePath];
    UIImage * photoImage = [UIImage imageWithData:imageData];
    self.imageView.image = photoImage;
    
    [self blockEditing];
}

- (void) blockEditing
{
    self.chooseImageButton.enabled = NO;
    self.chooseImageButton.hidden = YES;
    self.photoButton.enabled = NO;
    self.photoButton.hidden = YES;
    self.saveButton.enabled = NO;
    self.saveButton.hidden = YES;
    self.deleteButton.enabled = YES;
    self.deleteButton.hidden = NO;
    
    [self blockTextFields];
}

- (void) blockTextFields
{
    self.nameTextField.enabled = NO;
    self.lastNameTextField.enabled = NO;
    self.phoneTextField.enabled = NO;
    self.EmailTextField.enabled = NO;
}

- (void) updateColors
{
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults boolForKey:@"DarkInterface"])
    {
        self.view.backgroundColor = [UIColor darkGrayColor];
        self.nameLable.textColor = [UIColor whiteColor];
        self.lastNameLable.textColor = [UIColor whiteColor];
        self.phoneNumberLable.textColor = [UIColor whiteColor];
        self.emailLable.textColor = [UIColor whiteColor];
        UIColor * color = [UIColor greenColor];
        [self.chooseImageButton setTitleColor:color forState:UIControlStateNormal];
        [self.saveButton setTitleColor:color forState:UIControlStateNormal];
    }
}


@end
