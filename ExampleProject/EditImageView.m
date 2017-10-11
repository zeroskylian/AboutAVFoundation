//
//  EditImageView.m
//  ExampleProject
//
//  Created by 廉鑫博 on 2017/10/9.
//  Copyright © 2017年 廉鑫博. All rights reserved.
//

#import "EditImageView.h"
#import <Photos/Photos.h>

@interface EditImageView()
@property (strong, nonatomic)UIImageView *imageView;

@property (strong, nonatomic)UIButton *saveButton;

@property (strong, nonatomic)UIButton *cancelButton;
@end

@implementation EditImageView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 64, kScreenWidth, kScreenHeight - 64)];
        _imageView.userInteractionEnabled = true;
        [self addSubview:_imageView];
        
        _saveButton = [[UIButton alloc]initWithFrame:CGRectMake(0, kScreenHeight - 64 - 100, 80, 80)];
        _saveButton.layer.cornerRadius = 40;
        _saveButton.backgroundColor = [UIColor lightGrayColor];
        [_saveButton setTitle:@"保存" forState:UIControlStateNormal];
        [_saveButton addTarget:self action:@selector(saveImage) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_saveButton];
        
        _cancelButton = [[UIButton alloc]initWithFrame:CGRectMake(kScreenWidth - 80, kScreenHeight - 64 - 100, 80, 80)];
        _cancelButton.layer.cornerRadius = 40;
        _cancelButton.backgroundColor = [UIColor lightGrayColor];
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(cancelButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_cancelButton];
    }
    return self;
}
-(void)saveImage
{
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetChangeRequest *req = [PHAssetChangeRequest creationRequestForAssetFromImage:_image];
        NSLog(@"%@",req.placeholderForCreatedAsset.localIdentifier);
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            NSLog(@"保存成功");
        }else
        {
            NSLog(@"保存失败%@",error) ;
        }
    }];
    
//    UIImageWriteToSavedPhotosAlbum(_image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}
// 指定回调方法

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *) contextInfo

{
    NSString *msg = nil ;
    if(error != NULL){
        msg = @"保存图片失败" ;
    }else{
        msg = @"保存图片成功" ;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"保存图片结果提示"
                                                    message:msg
                                                   delegate:self
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
    [alert show];
}
-(void)cancelButtonClick
{
    self.hidden  = true;
    if ([self.delegate respondsToSelector:@selector(editImageViewCancelTakeImage)]) {
        [self.delegate editImageViewCancelTakeImage];
    }
}
-(void)setImage:(UIImage *)image
{
    _image = image;
    _imageView.image = image;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
