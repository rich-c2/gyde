//
//  TAForgottenPasswordVC.h
//  Tourism App
//
//  Created by Richard Lee on 10/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HTTPFetcher;

@interface TAForgottenPasswordVC : UIViewController {
	
	HTTPFetcher *sendPasswordfetcher;
	
	IBOutlet UITextField *usernameField;
}

@property (nonatomic, retain) IBOutlet UITextField *usernameField;

- (IBAction)goBack:(id)sender;

@end
