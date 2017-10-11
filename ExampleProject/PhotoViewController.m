//
//  PhotoViewController.m
//  ExampleProject
//
//  Created by 廉鑫博 on 2017/10/9.
//  Copyright © 2017年 廉鑫博. All rights reserved.
//

#import "PhotoViewController.h"
#import "EditImageView.h"
#import <AVFoundation/AVFoundation.h>

@interface PhotoViewController ()<EditImageViewDelegate>

@property (strong, nonatomic)AVCaptureSession *session;
@property (strong, nonatomic)AVCaptureDevice *device;
@property (strong, nonatomic)AVCaptureDeviceInput *defaultInput;
@property (strong, nonatomic)AVCaptureVideoPreviewLayer *previewLayer;
@property (weak, nonatomic)AVCaptureStillImageOutput *imageOutput;
@property (strong, nonatomic)EditImageView *editImageView;
@end

@implementation PhotoViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.session = [[AVCaptureSession alloc]init];
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
   _defaultInput = [AVCaptureDeviceInput deviceInputWithDevice:_device error:&error];
    if (!error) {
        [self.session addInput:_defaultInput];
    }else
    {
        NSLog(@"%@",error.description);
        return;
    }
    [self.session canSetSessionPreset:AVCaptureSessionPreset1280x720];
    [self.session setSessionPreset:AVCaptureSessionPreset1280x720];
    AVCaptureStillImageOutput *imageOutput = [[AVCaptureStillImageOutput alloc]init];
    NSDictionary *outputSettings = @{AVVideoCodecKey : AVVideoCodecJPEG};
    [imageOutput setOutputSettings:outputSettings];
    [self.session addOutput:imageOutput];
    _imageOutput = imageOutput;
    
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.previewLayer.bounds = self.view.bounds;
    self.previewLayer.position = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
    [self.view.layer addSublayer:self.previewLayer];
    [self.session startRunning];
    
    UIButton *takePhotoButton = [[UIButton alloc]initWithFrame:CGRectMake(kScreenWidth/2 - 40, self.view.frame.size.height - 100, 80, 80)];
    [takePhotoButton setImage:[UIImage imageNamed:@"chooseImg"] forState:UIControlStateNormal];
    [takePhotoButton addTarget:self action:@selector(takePhotoButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:takePhotoButton];
    
    
    UIButton  *lightButton = [[UIButton alloc]initWithFrame:CGRectMake(kScreenWidth/4 - 40, self.view.frame.size.height - 100, 80, 80)];
    [lightButton setImage:[UIImage imageNamed:@"light_on"] forState:UIControlStateNormal];
    [lightButton setImage:[UIImage imageNamed:@"light_off"] forState:UIControlStateSelected];
    [lightButton addTarget:self action:@selector(lightButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:lightButton];
    if (![_device hasTorch]) {
       lightButton.hidden = true;
        return;
    }
    
    UIButton  *changeButton = [[UIButton alloc]initWithFrame:CGRectMake(kScreenWidth * 3 /4 - 40, self.view.frame.size.height - 100, 80, 80)];
    [changeButton setImage:[UIImage imageNamed:@"change"] forState:UIControlStateNormal];
    [changeButton addTarget:self action:@selector(changeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:changeButton];
    // Do any additional setup after loading the view.
}
-(void)takePhotoButtonClick
{
    AVCaptureConnection *connection = [_imageOutput connectionWithMediaType:AVMediaTypeVideo];
    [_imageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef  _Nullable imageDataSampleBuffer, NSError * _Nullable error) {
        if (imageDataSampleBuffer == NULL) {
            return;
        }
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        UIImage *image = [[UIImage alloc] initWithData:imageData];
        if (!_editImageView) {
            _editImageView = [[EditImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
            _editImageView.delegate = self;
            [self.view addSubview:_editImageView];
        }
        if (_editImageView.hidden) {
            _editImageView.hidden = false;
        }
        _editImageView.image = image;
        if ([_session isRunning]) {
            [_session stopRunning];
        }
    }];
    
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.session stopRunning];
}
-(void)editImageViewCancelTakeImage
{
    [self.session startRunning];
}
-(void)lightButtonClick:(UIButton *)sender
{
    sender.selected = !sender.selected;
    [_device lockForConfiguration:nil];
    [_device setTorchMode:sender.selected == 0?AVCaptureTorchModeOff:AVCaptureTorchModeOn];
    [_device unlockForConfiguration];
    
}
-(void)changeButtonClick:(UIButton *)sender
{
    [self changeCamera];
}
- (void)changeCamera{
    NSUInteger cameraCount = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
    if (cameraCount > 1) {
        NSError *error;
        //给摄像头的切换添加翻转动画
        CATransition *animation = [CATransition animation];
        animation.duration = .5f;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.type = @"oglFlip";
        AVCaptureDevice *newCamera = nil;
        AVCaptureDeviceInput *newInput = nil;
        //拿到另外一个摄像头位置
        AVCaptureDevicePosition position = [[_defaultInput device] position];
        if (position == AVCaptureDevicePositionFront){
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
            animation.subtype = kCATransitionFromLeft;//动画翻转方向
        }else {
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
            animation.subtype = kCATransitionFromRight;//动画翻转方向
        }
        //生成新的输入
        newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
        [self.previewLayer addAnimation:animation forKey:nil];
        if (newInput != nil) {
            [self.session beginConfiguration];
            [self.session removeInput:self.defaultInput];
            if ([self.session canAddInput:newInput]) {
                [self.session addInput:newInput];
                self.defaultInput = newInput;
            } else {
                [self.session addInput:self.defaultInput];
            }
            [self.session commitConfiguration];
        } else if (error) {
            NSLog(@"toggle carema failed, error = %@", error);
        }
    }
}
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices)
        if (device.position == position ){
            return device;
        }
    return nil;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
