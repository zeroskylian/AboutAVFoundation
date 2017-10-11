//
//  ShotViewController.m
//  ExampleProject
//
//  Created by 廉鑫博 on 2017/10/9.
//  Copyright © 2017年 廉鑫博. All rights reserved.
//

#import "ShotViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import "PlayVideoView.h"

@interface ShotViewController ()<AVCaptureFileOutputRecordingDelegate,PlayVideoViewDelegate>
@property (strong, nonatomic) AVCaptureSession *session;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;
@property (strong, nonatomic) AVCaptureMovieFileOutput *captureMovieFileOutput;
@property (nonatomic, strong) AVCaptureDevice *captureVideoDevice;
@property (nonatomic, strong) AVCaptureDeviceInput *captureVideoDeviceInput;
@property (nonatomic, strong) AVCaptureDevice *captureAudioDevice;
@property (nonatomic, strong) AVCaptureDeviceInput *captureAudioDeviceInput;

@property (weak, nonatomic)AVCaptureConnection *captureConnection;

@property (strong, nonatomic)UIButton *shotButton;

@property (assign, nonatomic)BOOL canSave;

@property (nonatomic, strong) NSURL *videoUrl;
@property (strong, nonatomic)NSTimer *timer;

@property (strong, nonatomic)UILabel  *timeLabel;
@property (assign, nonatomic)int time;

@property (strong, nonatomic)PlayVideoView *playVideoView;

@end

@implementation ShotViewController
-(PlayVideoView *)playVideoView
{
    if (!_playVideoView) {
        _playVideoView = [[PlayVideoView alloc]initWithFrame:self.view.frame];
        _playVideoView.delegate = self;
        [self.view addSubview:self.playVideoView];
    }
    return _playVideoView;
}

-(UILabel *)timeLabel
{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(kScreenWidth/2 - 40, self.view.frame.size.height - 100 - 50, 80, 20)];
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:_timeLabel];
        
    }
    return _timeLabel;
}
-(NSTimer *)timer
{
    if (!_timer) {
        _timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(timerRun) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    return _timer;
}
-(void)timerRun
{
    int minute = self.time / 60 % 60;
    int second = self.time % 60;
    self.timeLabel.text = [NSString stringWithFormat:@"%02d:%02d",minute,second];
    self.time ++;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.time = 0;
    self.session = [[AVCaptureSession alloc]init];
    if ([self.session canSetSessionPreset:AVCaptureSessionPresetHigh]) {
        [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    }else
    {
        [self.session setSessionPreset:AVCaptureSessionPreset1280x720];
    }
    self.captureVideoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    [self addVideoInput];
    [self addVideoOutput];
    [self addAudio];
    
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.session];
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
    self.previewLayer.frame  = self.view.bounds;
    [self.view.layer addSublayer:self.previewLayer];
    [self.session startRunning];
    
    
    _shotButton = [[UIButton alloc]initWithFrame:CGRectMake(kScreenWidth/2 - 40, self.view.frame.size.height - 100, 80, 80)];
    [_shotButton setImage:[UIImage imageNamed:@"chooseImg"] forState:UIControlStateNormal];
    [_shotButton addTarget:self action:@selector(shotButtonButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_shotButton];
    UIButton  *lightButton = [[UIButton alloc]initWithFrame:CGRectMake(kScreenWidth/4 - 40, self.view.frame.size.height - 100, 80, 80)];
    [lightButton setImage:[UIImage imageNamed:@"light_on"] forState:UIControlStateNormal];
    [lightButton setImage:[UIImage imageNamed:@"light_off"] forState:UIControlStateSelected];
    [lightButton addTarget:self action:@selector(lightButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:lightButton];
    if (![_captureVideoDevice hasTorch]) {
        lightButton.hidden = true;
        return;
    }
    
    UIButton  *changeButton = [[UIButton alloc]initWithFrame:CGRectMake(kScreenWidth * 3 /4 - 40, self.view.frame.size.height - 100, 80, 80)];
    [changeButton setImage:[UIImage imageNamed:@"change"] forState:UIControlStateNormal];
    [changeButton addTarget:self action:@selector(changeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:changeButton];
    
}
-(void)lightButtonClick:(UIButton *)sender
{
    sender.selected = !sender.selected;
    [_captureVideoDevice lockForConfiguration:nil];
    [_captureVideoDevice setTorchMode:sender.selected == 0?AVCaptureTorchModeOff:AVCaptureTorchModeOn];
    [_captureVideoDevice unlockForConfiguration];
    
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
        AVCaptureDevicePosition position = [[_captureVideoDeviceInput device] position];
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
            [self.session removeInput:self.captureVideoDeviceInput];
            if ([self.session canAddInput:newInput]) {
                [self.session addInput:newInput];
                self.captureVideoDeviceInput = newInput;
            } else {
                [self.session addInput:self.captureVideoDeviceInput];
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

- (void)addVideoInput
{
    NSError *error;
    self.captureVideoDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:self.captureVideoDevice error:&error];
    if (error) {
        return;
    }
    
    if ([self.session canAddInput:self.captureVideoDeviceInput]) {
        [self.session addInput:self.captureVideoDeviceInput];
    }
}
- (void)addVideoOutput
{
    self.captureMovieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    if ([self.session canAddOutput:self.captureMovieFileOutput]) {
        [self.session addOutput:self.captureMovieFileOutput];
    }
    //设置链接管理对象
    AVCaptureConnection *captureConnection = [self.captureMovieFileOutput connectionWithMediaType:AVMediaTypeVideo];
    self.captureConnection = captureConnection;
    //视频旋转方向设置
    captureConnection.videoScaleAndCropFactor = captureConnection.videoMaxScaleAndCropFactor;;
    //视频稳定设置
    if ([captureConnection isVideoStabilizationSupported]) {
        captureConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
    }
}
- (void)addAudio
{
    NSError *error;
    self.captureAudioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    self.captureAudioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:self.captureAudioDevice error:&error];
    if (error) {
        return;
    }
    if ([self.session canAddInput:self.captureAudioDeviceInput]) {
        [self.session addInput:self.captureAudioDeviceInput];
    }
}
-(void)shotButtonButtonClick:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if (!sender.selected) {
        [self.captureMovieFileOutput stopRecording];
        [_timer invalidate];
        _timer = nil;
        
    }else{
        [self.timer fire];
        NSLog(@"录制开始");
        [self.captureMovieFileOutput startRecordingToOutputFileURL:[self outPutFileURL] recordingDelegate:self];
    }
    
    
}
- (NSURL *)outPutFileURL
{
    return [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), @"outPut.mov"]];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.session stopRunning];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//录制结束调用的代理方法

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    NSLog(@"---- 录制结束 ---%@-%@ ",outputFileURL,captureOutput.outputFileURL);
    
    if (outputFileURL.absoluteString.length == 0 && captureOutput.outputFileURL.absoluteString.length == 0 ) {
        return;
    }
    [self.session stopRunning];
    self.videoUrl = outputFileURL;
   
    self.playVideoView.hidden = false;
    self.playVideoView.url = outputFileURL;
}
-(void)playVideoViewCancel
{
    [self.session startRunning];
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
