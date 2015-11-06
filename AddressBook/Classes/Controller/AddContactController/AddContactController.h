//
//  AddContactController.h
//  AddressBook
//
//  Created by Admin on 04.11.15.
//  Copyright (c) 2015 OlhaF. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddContactController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) NSMutableDictionary * contactProfile;

- (void) showInformationForContact: (NSMutableDictionary*) contactProfile;

@end
