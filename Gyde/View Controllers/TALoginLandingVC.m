//
//  TALoginLandingVC.m
//  Tourism App
//
//  Created by Richard Lee on 10/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TALoginLandingVC.h"
#import "AppDelegate.h"

static NSString *kSkipLoginLandingKey = @"skipLoginLandingKey";

@interface TALoginLandingVC ()

@end

@implementation TALoginLandingVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}


#pragma mark - Private Methods
- (AppDelegate *)appDelegate {
	
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (IBAction)findButtonTapped:(id)sender {
	
	// The user has now used this screen once
	// so we need to store the fact that we're
	// going to skip this on future log-ins.
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:kSkipLoginLandingKey];

	AppDelegate *appDelegate = [self appDelegate];
	
	// Show tab bar view controllers
	appDelegate.window.rootViewController = appDelegate.tabBarController;
	appDelegate.tabBarController.selectedIndex = 1;
}


- (IBAction)shareButtonTapped:(id)sender {
	
	// The user has now used this screen once
	// so we need to store the fact that we're
	// going to skip this on future log-ins.
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:kSkipLoginLandingKey];
	
	AppDelegate *appDelegate = [self appDelegate];
	
	// Show tab bar view controllers
	appDelegate.window.rootViewController = appDelegate.tabBarController;
	appDelegate.tabBarController.selectedIndex = 2;
}



@end
