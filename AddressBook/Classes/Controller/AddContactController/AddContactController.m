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

@end

@implementation AddContactController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.contactProfile)
    {
        [self addRightNavigationButton];
        [self showInformationForContact: self.contactProfile];
    }
    
   // [self updateColors];
    
    //[self reloadInputViews];
    // Do any additional setup after loading the view.
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
    //hide keyboard
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
    
   // NSString * newContactPath = [self createNewContactFileAndGetPath];
    if ([name length] || [lastName length])
    {
    NSMutableDictionary * contactProperties;
    if (!self.contactProfile)
        contactProperties = [self createNewContactFile];
    else
        contactProperties = self.contactProfile;
    //[[NSMutableDictionary alloc] initWithContentsOfFile:newContactPath];
    [contactProperties setValue:name forKey:@"Name"];
    [contactProperties setValue:lastName forKey:@"Last Name"];
    [contactProperties setValue:phone forKey:@"Phone Number"];
    [contactProperties setValue:email forKey:@"Email"];
    
    NSString * contactDirectoryPath = [self getContactDirectoryPath];
    
    NSUInteger index = [[contactProperties valueForKey:@"index"] integerValue];
    NSString * pathComponent = [[NSString alloc] initWithFormat:@"Contact%ld.plist", index];
    NSString * newContactPath = [contactDirectoryPath stringByAppendingPathComponent:pathComponent];

    NSString * contactImagePath = [[newContactPath stringByDeletingPathExtension] stringByAppendingPathExtension:@"png"];
    //[contactProperties setValue:contactImagePath forKey:@"imagePath"];
    //[contactProperties setValue:newContactPath forKey:@"contactPath"];
    
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

- (IBAction)editContactAction:(id)sender
{
    self.chooseImageButton.enabled = YES;
    self.chooseImageButton.hidden = NO;
    self.saveButton.enabled = YES;
    self.saveButton.hidden = NO;
    
    self.nameTextField.enabled = YES;
    self.lastNameTextField.enabled = YES;
    self.phoneTextField.enabled = YES;
    self.EmailTextField.enabled = YES;
}
#pragma mark - Additional methods
- (NSMutableDictionary*) createNewContactFile
{
    NSFileManager * fileManager = [NSFileManager defaultManager];
    
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSUInteger contactNumerator = [userDefaults integerForKey:@"numeratorOfCreatedContacts"]+1;
    
    NSError * error = nil;
    NSString * contactDirectoryPath = [self getContactDirectoryPath];
    
    // NSLog([fileManager fileExistsAtPath:contactDirectoryPath]?@"YES":@"NO");
    NSString * sampleFilePath = [[NSBundle mainBundle] pathForResource:@"SampleFile" ofType:@"plist"];
    NSString * newContactPath =
    [contactDirectoryPath stringByAppendingPathComponent:
     [NSString stringWithFormat:@"Contact%ld.plist", contactNumerator]];
    
    if (![fileManager fileExistsAtPath:newContactPath])
    {
        [fileManager copyItemAtPath:sampleFilePath toPath:newContactPath error:&error];
        [userDefaults setInteger:contactNumerator forKey:@"numeratorOfCreatedContacts"];
        [userDefaults synchronize];
    }
    
    NSMutableDictionary * newContact = [[NSMutableDictionary alloc] initWithContentsOfFile:newContactPath];
    [newContact setObject: @(contactNumerator) forKey:@"index"];
    //NSLog([fileManager copyItemAtPath:sampleFilePath toPath:newContactPath error:&error]?@"YES":@"NO");
    return newContact;
}

- (NSString*) getContactDirectoryPath
{
    NSArray * pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * pathToDocumentDirectory = [pathArray objectAtIndex:0];
    NSString * contactDirectoryPath = [pathToDocumentDirectory stringByAppendingPathComponent:@"Contacts"];
    return contactDirectoryPath;
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
    
    NSString * contactDirectoryPath = [self getContactDirectoryPath];
    NSUInteger index = [[contactProfile valueForKey:@"index"] integerValue];
    NSString * pathComponent = [[NSString alloc] initWithFormat:@"Contact%ld.png", index];
    NSString * imagePath = [contactDirectoryPath stringByAppendingPathComponent:pathComponent];
    
    NSData * imageData = [NSData dataWithContentsOfFile:imagePath];
    UIImage * photoImage = [UIImage imageWithData:imageData];
    self.imageView.image = photoImage;
    
    [self blockEditing];
}

- (void) blockEditing
{
    self.chooseImageButton.enabled = NO;
    self.chooseImageButton.hidden = YES;
    self.saveButton.enabled = NO;
    self.saveButton.hidden = YES;
    
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
    /*else
    {
        self.view.backgroundColor = [UIColor whiteColor];
        self.nameLable.textColor = [UIColor blackColor];
       // self.nameLable.backgroundColor = [UIColor whiteColor];
        self.lastNameLable.textColor = [UIColor blackColor];
       // self.lastNameLable.backgroundColor = [UIColor whiteColor];
        self.phoneNumberLable.textColor = [UIColor blackColor];
        //self.phoneNumberLable.backgroundColor = [UIColor whiteColor];
        self.emailLable.textColor = [UIColor blackColor];
       // self.emailLable.backgroundColor = [UIColor whiteColor];
        //self.chooseImageButton.titleLabel.textColor = [UIColor blueColor];
        //self.saveButton.titleLabel.textColor = [UIColor blueColor];
    }*/
    
}
/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
