//
//  TARecommendList.m
//  Tourism App
//
//  Created by Richard Lee on 8/10/12.
//
//

#import "TARecommendList.h"
#import "User.h"
#import "TAUserButton.h"

@implementation TARecommendList

@synthesize scrollView, delegate, selected;

- (id)initWithFrame:(CGRect)frame {
	
    self = [super initWithFrame:frame];
	
    if (self) {
		
		self.selected = [NSMutableArray array];
       
		UIScrollView *sv = [[UIScrollView alloc] initWithFrame:CGRectMake(10.0, 10.0, 272.0, 260.0)];
		[sv setBackgroundColor:[UIColor clearColor]];
		[sv setShowsHorizontalScrollIndicator:NO];
		[sv setShowsVerticalScrollIndicator:NO];
		
		self.scrollView = sv;
		
		[self addSubview:self.scrollView];
		
		CGRect doneBtnFrame = CGRectMake(10.0, 270.0, 272.0, 40.0);
		UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
		[doneBtn setFrame:doneBtnFrame];
		[doneBtn setBackgroundColor:[UIColor blueColor]];
		[doneBtn setTitle:@"DONE" forState:UIControlStateNormal];
		[doneBtn addTarget:self action:@selector(doneButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:doneBtn];
    }
	
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


- (void)setUsers:(NSArray *)newUsers {

	users = newUsers;
	
	[self createUserButtons];
}


- (void)createUserButtons {
	
	CGFloat xPos = 0.0;
	CGFloat yPos = 0.0;
	CGFloat buttonWidth = 272.0;
	CGFloat buttonHeight = 45.0;
	CGFloat buttonPadding = 3.0;
	
	for (User *user in users) {
		
		// USER BUTTON
		CGRect userBtnFrame = CGRectMake(xPos, yPos, buttonWidth, buttonHeight);
		
		TAUserButton *guideBtn = [[TAUserButton alloc] initWithFrame:userBtnFrame user:[user username] name:[user fullName] thumbURL:[user avatarURL]];
		[guideBtn setDelegate:self];
		
		[self.scrollView addSubview:guideBtn];
		
		yPos += (buttonHeight + buttonPadding);
	}
	
	[self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, yPos)];
}


- (void)doneButtonTapped:(id)sender {
	
	[self.delegate finishedSelectingUsers:self.selected];
}


#pragma UserButtonDelegate methods

- (void)userButtonTapped:(NSString *)username {
	
	if (![self.selected containsObject:username]) [self.selected addObject:username];
	else [self.selected removeObject:username];
}

@end
