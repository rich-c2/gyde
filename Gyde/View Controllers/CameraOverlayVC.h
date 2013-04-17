//
//  CameraOverlayVC.h
//  Tourism App
//
//  Created by Richard Lee on 11/10/12.
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface CameraOverlayVC : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic,retain) UIImagePickerController *pickerReference;
@property (nonatomic,retain) UIImage *pickedImage;

@property (retain, nonatomic) IBOutlet UIImageView *imageView;


@end
