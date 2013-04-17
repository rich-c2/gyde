//
//  TALoginVC.h
//  Tourism App
//
//  Created by Richard Lee on 28/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LoginDelegate

- (void)loginSuccessful:(NSDictionary *)userData;

@end

@class HTTPFetcher;

@interface TALoginVC : UIViewController {
	
	id <LoginDelegate> delegate;

	HTTPFetcher *loginRequest;
	
	IBOutlet UITextField *passwordField;
	IBOutlet UITextField *usernameField;
}

@property (nonatomic, retain) id <LoginDelegate> delegate;

@property (nonatomic, retain) IBOutlet UITextField *passwordField;
@property (nonatomic, retain) IBOutlet UITextField *usernameField;

- (IBAction)forgottenPasswordButtonTapped:(id)sender;
- (IBAction)goBack:(id)sender;

@end
