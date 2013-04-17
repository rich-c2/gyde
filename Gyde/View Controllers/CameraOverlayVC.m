//
//  CameraOverlayVC.m
//  Tourism App
//
//  Created by Richard Lee on 11/10/12.
//
//

#import "CameraOverlayVC.h"
#import "AppDelegate.h"

@interface CameraOverlayVC ()

@end

@implementation CameraOverlayVC

@synthesize pickerReference, pickedImage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    NSLog(@"IMAGE SIZE:%.2f|%.2f", self.pickedImage.size.width, self.pickedImage.size.height);
    
    CGFloat ratio = 3.825;
        
    /*CGRect cropRect = CGRectMake(0.0, 152.0, self.pickedImage.size.width, self.pickedImage.size.width);
    CGImageRef imageRef = CGImageCreateWithImageInRect([self.pickedImage CGImage], cropRect);
    UIImage *image = [UIImage imageWithCGImage:imageRef];*/

    [self.imageView setImage:self.pickedImage];
    UIImage *newImg = [self imageWithView:self.imageView];
    
    [self.imageView setImage:newImg];
    
   // UIImage *resizedImage = [self imageWithImage:self.pickedImage scaledToSize:CGSizeMake((self.pickedImage.size.width/ratio), (self.pickedImage.size.height/ratio))];
   // [self.imageView setImage:resizedImage];
}


- (UIImage *) imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}



- (UIImage*)imageWithImage:(UIImage*)image
              scaledToSize:(CGSize)newSize;
{
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}



- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize {
    
    UIImage *sourceImage = self.pickedImage;
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
        {
            scaleFactor = widthFactor; // scale to fit height
        }
        else
        {
            scaleFactor = heightFactor; // scale to fit width
        }
        
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
        {
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
        }
    }
    
    UIGraphicsBeginImageContext(targetSize); // this will crop
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    if(newImage == nil)
    {
        NSLog(@"could not scale image");
    }
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    
    return newImage;
}



#pragma mark - Private Methods
- (AppDelegate *)appDelegate {
	
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)takePhotoButtonTapped:(id)sender {

    [self.pickerReference takePicture];
}


- (IBAction)cancelButtonTapped:(id)sender {
    
    [[self appDelegate] quitCamera];
}



- (void)viewDidUnload {
    [self setImageView:nil];
    [super viewDidUnload];
}

@end
