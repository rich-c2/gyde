//
//  EditProfileVC.h
//  GiftHype
//
//  Created by Richard Lee on 15/05/12.
//  Copyright (c) 2012 C2 Media Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TACitiesListVC.h"
#import <MobileCoreServices/MobileCoreServices.h>

@class HTTPFetcher;

@interface EditProfileVC : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, CitiesDelegate> {

	NSManagedObjectContext *managedObjectContext;
	
	BOOL loading;
	BOOL profileLoaded;
    
    BOOL newAvatarSelected;
	
	HTTPFetcher *updateProfileFetcher;
	HTTPFetcher *profileFetcher;
	
	UITextView *bioView;
	UITextField *emailField;
	UIView *currentTextField;
	
	IBOutlet UIButton *cityBtn;
	
	UIScrollView *formScrollView;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) IBOutlet UITextView *bioView;
@property (nonatomic, retain) IBOutlet UITextField *emailField; 
@property (nonatomic, retain) UIView *currentTextField;
@property (retain, nonatomic) IBOutlet UITextField *nameField;
@property (retain, nonatomic) IBOutlet UILabel *cityLabel;

@property (nonatomic, retain) IBOutlet UIImageView *avatarView;

@property (nonatomic, retain) IBOutlet UIButton *cityBtn;

@property (nonatomic, retain) IBOutlet UIScrollView *formScrollView;

- (IBAction)saveButtonTapped:(id)sender;
- (void)willLogout;
- (IBAction)selectCityButtonTapped:(id)sender;

@end
