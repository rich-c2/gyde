//
//  TACreateGuideForm.m
//  Tourism App
//
//  Created by Richard Lee on 26/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TACreateGuideForm.h"

#define TITLE_FIELD_INDEX 0
#define CITY_FIELD_INDEX 1
#define TAG_FIELD_INDEX 2
#define PRIVATE_FIELD_INDEX 3

@implementation TACreateGuideForm

@synthesize delegate, titleField, isPrivate;

- (id)initWithFrame:(CGRect)frame city:(NSString *)city tag:(NSString *)tagTitle  {
	
    self = [super initWithFrame:frame];
	
    if (self) {
       
		CGFloat xPos = 8.0;
		CGFloat yPos = 10.0;
		CGFloat bgWidth = 274.0;
		CGFloat bgHeight = 45.0;
		CGFloat padding = 1.0;
		
		CGFloat labelXPos = 22.0;
		CGFloat labelYPos = 26.0;
		CGFloat labelPadding = 46.0;
		
		CGFloat fieldXPos = 70.0;
		CGFloat fieldYPos = 19.0;
		CGFloat fieldWidth = 194.0;
		CGFloat fieldHeight = 22.0;
		
		// Add form field bgs
		UIImage *fieldBGImage = [UIImage imageNamed:@"form-field-bg-small.png"];
		
		NSArray *labelImages = [NSArray arrayWithObjects:@"form-label-title.png", @"form-label-city.png", @"form-label-tag.png", @"form-label-private.png", nil];
		
		for (int i = 0; i < 4; i++) {
			
			// FORM FIELD BG
			CGRect fieldFrame1 = CGRectMake(xPos, yPos, bgWidth, bgHeight);
			UIImageView *fieldViewBG = [[UIImageView alloc] initWithFrame:fieldFrame1];
			[fieldViewBG setImage:fieldBGImage];
			
			[self addSubview:fieldViewBG];
			
			
			// FORM LABEL
			UIImage *labelImage = [UIImage imageNamed:[labelImages objectAtIndex:i]];
			CGRect labelFrame1 = CGRectMake(labelXPos, labelYPos, labelImage.size.width, labelImage.size.height);
			UIImageView *labelView = [[UIImageView alloc] initWithFrame:labelFrame1];
			[labelView setImage:labelImage];
			
			[self addSubview:labelView];

			
			CGRect fieldFrame;
			
			switch (i) {
					
				case TITLE_FIELD_INDEX:
				{
					fieldFrame = CGRectMake(fieldXPos, fieldYPos, fieldWidth, fieldHeight);
					UITextField *textField = [[UITextField alloc] initWithFrame:fieldFrame];
					[textField setFont:[UIFont boldSystemFontOfSize:18.0]];
					[textField setReturnKeyType:UIReturnKeyDone];
					[textField setDelegate:self];
					[textField setAutocorrectionType:UITextAutocapitalizationTypeNone];
					[textField setClearButtonMode:UITextFieldViewModeWhileEditing];
					
					self.titleField = textField;

					[self addSubview:self.titleField];

					break;
				}
                    
				case CITY_FIELD_INDEX:
				{
					fieldFrame = CGRectMake(fieldXPos, fieldYPos, fieldWidth, fieldHeight);
					UILabel *cityLabel = [[UILabel alloc] initWithFrame:fieldFrame];
					[cityLabel setFont:[UIFont boldSystemFontOfSize:18.0]];
					
					[cityLabel setText:city];
					
					[self addSubview:cityLabel];
					
					break;
                }
            
				case TAG_FIELD_INDEX:
				{
					fieldFrame = CGRectMake(fieldXPos, fieldYPos, fieldWidth, fieldHeight);
					UILabel *tagLabel = [[UILabel alloc] initWithFrame:fieldFrame];
					[tagLabel setFont:[UIFont boldSystemFontOfSize:18.0]];
					
					[tagLabel setText:tagTitle];
					
					[self addSubview:tagLabel];
					
					break;
				}
                    
				case PRIVATE_FIELD_INDEX:
                {
					
					fieldFrame = CGRectMake(fieldXPos, fieldYPos, fieldWidth, fieldHeight);
					UILabel *privateLabel = [[UILabel alloc] initWithFrame:fieldFrame];
					[privateLabel setFont:[UIFont boldSystemFontOfSize:13.0]];
					[privateLabel setTextColor:[UIColor colorWithRed:166.0/255.0 green:166.0/255.0 blue:166.0/255.0 alpha:1.0]];
					
					[privateLabel setText:@"Only visible to your friends"];
					
					[self addSubview:privateLabel];
					
					break;
				}
				default:
					break;
			}
			
			

			fieldYPos += labelPadding;
			labelYPos += labelPadding;
			yPos += (bgHeight + padding);
		}
		
		
		// FOCUS ON THE TITLE FIELD - REVEAL THE KEYBOARD
		[self.titleField becomeFirstResponder];
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


#pragma mark - UITextField delegations
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    // remove the keyboard
	[textField resignFirstResponder];
	
	// Pass the guide details the user
	// set back "up the chain" via the delegate
	[self.delegate createGuide:self.titleField.text privateGuide:isPrivate];
    
    return YES;
}





@end
