//
//  ImageCropper.m
//  Created by http://github.com/iosdeveloper
//

#import "ImageCropper.h"

@implementation ImageCropper

@synthesize scrollView, imageView;
@synthesize delegate;

- (id)initWithImage:(UIImage *)image {
    
	self = [super init];
	
	if (self) {
        
        // This is aligned to the top of the screen and
        // contains the 'photo library' button and cancel button
        CGFloat topToolbarHeight = 76;
        CGFloat topToolbarWidth = 320;
        UIView *topToolbar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, topToolbarWidth, topToolbarHeight)];
        [topToolbar setBackgroundColor:[UIColor blackColor]];
        
        UIButton *cancelCameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelCameraBtn setFrame:CGRectMake(254, 25, 43, 27)];
        [cancelCameraBtn setImage:[UIImage imageNamed:@"close-camera-button.png"] forState:UIControlStateNormal];
        [cancelCameraBtn addTarget:self action:@selector(cancelCropping) forControlEvents:UIControlEventTouchUpInside];
        
        [topToolbar addSubview:cancelCameraBtn];
        
        [[self view] addSubview:topToolbar];        
        
		
		scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 76.0, 320.0, 320.0)];
		[scrollView setBackgroundColor:[UIColor blackColor]];
		[scrollView setDelegate:self];
		[scrollView setShowsHorizontalScrollIndicator:NO];
		[scrollView setShowsVerticalScrollIndicator:NO];
		[scrollView setMaximumZoomScale:1.0];
		
		imageView = [[UIImageView alloc] initWithImage:image];
		
		CGRect rect;
		rect.size.width = image.size.width;
		rect.size.height = image.size.height;
		
		[imageView setFrame:rect];
		
		[scrollView setContentSize:[imageView frame].size];
		[scrollView setMinimumZoomScale:[scrollView frame].size.width / [imageView frame].size.width];
		[scrollView setZoomScale:[scrollView minimumZoomScale]];
		[scrollView addSubview:imageView];
		
		[[self view] addSubview:scrollView];
        
        
        // This takes the place of where the default
        // camera tools toolbar would have been
        CGFloat toolbarHeight = 84;
        CGFloat toolbarWidth = 320;
        UIView *toolbar = [[UIView alloc] initWithFrame:CGRectMake(0, (480 - toolbarHeight), toolbarWidth, toolbarHeight)];
        [toolbar setBackgroundColor:[UIColor blackColor]];
        
        
        UIButton *takeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [takeBtn setFrame:CGRectMake(25, 26, 270, 35)];
        [takeBtn setImage:[UIImage imageNamed:@"camera-done-button.png"] forState:UIControlStateNormal];
        [takeBtn setImage:[UIImage imageNamed:@"camera-done-button-on.png"] forState:UIControlStateHighlighted];
        [takeBtn addTarget:self action:@selector(finishCropping) forControlEvents:UIControlEventTouchUpInside];
        
        [toolbar addSubview:takeBtn];
        
        [[self view] addSubview:toolbar];
        
	}
	
	return self;
}

- (void)cancelCropping {
	[delegate imageCropperDidCancel:self]; 
}

- (void)finishCropping {
    
	float zoomScale = 1.0 / [scrollView zoomScale];
	
	CGRect rect;
	rect.origin.x = [scrollView contentOffset].x * zoomScale;
	rect.origin.y = [scrollView contentOffset].y * zoomScale;
	rect.size.width = [scrollView bounds].size.width * zoomScale;
	rect.size.height = [scrollView bounds].size.height * zoomScale;
    
	CGImageRef cr = CGImageCreateWithImageInRect([[imageView image] CGImage], rect);
	
	UIImage *cropped = [UIImage imageWithCGImage:cr];
	
	CGImageRelease(cr);
	
	[delegate imageCropper:self didFinishCroppingWithImage:cropped];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return imageView;
}


@end