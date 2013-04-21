//
//  TALandingVC.m
//  Tourism App
//
//  Created by Richard Lee on 10/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TALandingVC.h"
#import "TALoginVC.h"
#import "TARegisterVC.h"
#import "AppDelegate.h"
#import "TANotificationsVC.h"
#import "TAProfileVC.h"
#import "TAExploreVC.h"
#import "TACameraVC.h"

@interface TALandingVC ()

@end

@implementation TALandingVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
	
    [super viewDidLoad];
}

- (void)viewDidUnload {
	
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillAppear:(BOOL)animated {

	// Hide the default navigation bar
	[self initNavBar];
}


- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
	// Fade in the login and register buttons
	//[self fadeView:self.loginBtn alpha:1.0 duration:0.75];
    //[self fadeView:self.registerBtn alpha:1.0 duration:0.75];
}


#pragma mark - Private Methods
- (AppDelegate *)appDelegate {
	
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}


#pragma MY METHODS

- (void)initNavBar {

    self.title = @"Back";
	[self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (IBAction)loginButtonTapped:(id)sender {

	TALoginVC *loginVC = [[TALoginVC alloc] initWithNibName:@"TALoginVC" bundle:nil];
	[self.navigationController pushViewController:loginVC animated:YES];
}

- (IBAction)signUpButtonTapped:(id)sender {

	TARegisterVC *registerVC = [[TARegisterVC alloc] initWithNibName:@"TARegisterVC" bundle:nil];
	[self.navigationController pushViewController:registerVC animated:YES];
}

- (void)logout {
    
    // Clear objects
    AppDelegate *appDelegate = [self appDelegate];
    
    // Reset workordersLoaded
	[appDelegate setUserLoggedIn:NO];
    appDelegate.loggedInUsername = nil;
	appDelegate.sessionToken = nil;
    
    // Re-configure each tab's view controllers
    [(MeVC *)[[(UINavigationController *)[appDelegate.tabBarController.viewControllers objectAtIndex:0] viewControllers] objectAtIndex:0] willLogout];
    
    [(TAExploreVC *)[[(UINavigationController *)[appDelegate.tabBarController.viewControllers objectAtIndex:1] viewControllers] objectAtIndex:0] willLogout];
    
    [(TACameraVC *)[[(UINavigationController *)[appDelegate.tabBarController.viewControllers objectAtIndex:2] viewControllers] objectAtIndex:0] willLogout];
	
    [(TANotificationsVC *)[(UINavigationController *)[appDelegate.tabBarController.viewControllers objectAtIndex:3] topViewController] willLogout];
    
    [(TAProfileVC *)[(UINavigationController *)[appDelegate.tabBarController.viewControllers objectAtIndex:4] topViewController] willLogout];
	
    // Reset Window to display Landing page
    [appDelegate.landingNav popToRootViewControllerAnimated:NO];
    appDelegate.window.rootViewController = appDelegate.landingNav;
	
}

- (void)fadeView:(UIView *)view alpha:(CGFloat)alpha duration:(CGFloat)duration {
    
	[UIView animateWithDuration:duration animations:^{
		
		view.alpha = alpha;
		
	} completion:^(BOOL finished) {
		
		view.userInteractionEnabled = YES;
	}];
}


@end
