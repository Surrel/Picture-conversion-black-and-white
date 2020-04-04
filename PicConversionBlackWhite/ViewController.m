//
//  ViewController.m
//  PicConversionBlackWhite
//
//  Created by mac on 2020/4/4.
//  Copyright © 2020 mac. All rights reserved.
//

#import "ViewController.h"
#import <PhotosUI/PhotosUI.h>
#import <Photos/Photos.h>

@interface ViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *transPic;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
     PHAuthorizationStatus authStatusAlbm  = [PHPhotoLibrary authorizationStatus];
    UIImage *defultImage = [UIImage imageNamed:@"IMG_0565"];
    self.transPic.frame = CGRectMake(self.transPic.frame.origin.x, self.transPic.frame.origin.y, defultImage.size.width, defultImage.size.height);
}
- (IBAction)saveAlbum:(id)sender {  UIImageWriteToSavedPhotosAlbum(self.transPic.image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
}

//必要实现的协议方法, 不然会崩溃
-(void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    UIAlertController *ua = [UIAlertController alertControllerWithTitle:nil message:@"保存成功" preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:ua animated:YES completion:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
             [self dismissViewControllerAnimated:YES completion:nil];
        });
        
    }];
}

- (IBAction)transAction:(id)sender {
      UIImagePickerController *picker = [[UIImagePickerController alloc] init];
      picker.delegate = self;
      picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
      [self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:^{
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        self.transPic.frame = CGRectMake(self.transPic.frame.origin.x, self.transPic.frame.origin.y, image.size.width, image.size.height);
        self.transPic.image = [ViewController greyImageWithImage:image];
    }];
}

//取消获取照片
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

+ (UIImage*)greyImageWithImage:(UIImage*)image
{
    //根据设备的屏幕缩放比例调整生成图片的尺寸，避免在图片变糊
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize resultSize = CGSizeMake(image.size.width*scale, image.size.height*scale);
    
    CGRect imageRect = CGRectMake(0, 0, resultSize.width, resultSize.height);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate(nil, resultSize.width, resultSize.height, 8, 0, colorSpace, kCGImageAlphaPremultipliedLast);//使用kCGImageAlphaPremultipliedLast保留Alpha通道，避免透明区域变成黑色。
    CGContextDrawImage(context, imageRect, [image CGImage]);
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    UIImage *newImage = [UIImage imageWithCGImage:imageRef];
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    CFRelease(imageRef);
    return newImage;
}

@end
