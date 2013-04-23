//
//  GydeTabBarController.m
//  Gyde
//
//  Created by Richard Lee on 23/04/13.
//  Copyright (c) 2013 Richard Lee. All rights reserved.
//

#import "GydeTabBarController.h"

@interface GydeTabBarController ()

@end

@implementation GydeTabBarController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // customise tab bar appearance
	[self setupAppearance];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)setupAppearance
{
	[[UITabBar appearance] setBackgroundImage:[UIImage imageNamed:@"tabbar_bg.png"]];
	self.tabBar.selectedImageTintColor = [UIColor clearColor];
	self.tabBar.selectionIndicatorImage = [[UIImage alloc] init];
    
    [[self.tabBar.items objectAtIndex:0] setFinishedSelectedImage:[UIImage imageNamed:@"feed_tab_button-on.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"feed_tab_button.png"]];
    [[self.tabBar.items objectAtIndex:1] setFinishedSelectedImage:[UIImage imageNamed:@"explore_tab_button-on.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"explore_tab_button.png"]];
    [[self.tabBar.items objectAtIndex:2] setFinishedSelectedImage:[UIImage imageNamed:@"share_tab_button-on.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"share_tab_button.png"]];
    [[self.tabBar.items objectAtIndex:3] setFinishedSelectedImage:[UIImage imageNamed:@"news_tab_button-on.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"news_tab_button.png"]];
    [[self.tabBar.items objectAtIndex:4] setFinishedSelectedImage:[UIImage imageNamed:@"account_tab_button-on.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"account_tab_button.png"]];
}

@end
