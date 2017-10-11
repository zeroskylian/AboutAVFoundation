//
//  QRCodeViewController.m
//  ExampleProject
//
//  Created by 廉鑫博 on 2017/10/9.
//  Copyright © 2017年 廉鑫博. All rights reserved.
//

#import "QRCodeViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface QRCodeViewController ()<AVCaptureMetadataOutputObjectsDelegate>
@property (strong, nonatomic)AVCaptureSession *session;
@property (strong, nonatomic)AVCaptureDevice *device;
@property (strong, nonatomic)AVCaptureDeviceInput *defaultInput;
@property (strong, nonatomic)AVCaptureVideoPreviewLayer *previewLayer;
@property (weak, nonatomic)AVCaptureMetadataOutput *output;
@end

@implementation QRCodeViewController

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

    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc]init];
    [self.session addOutput:output];
    [self.session canSetSessionPreset:AVCaptureSessionPreset1280x720];
    [output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
//    //设置扫码支持的编码格式(如下设置条形码和二维码兼容)
//    output.metadataObjectTypes=@[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
    
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    _output = output;
    
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.previewLayer.bounds = self.view.bounds;
    self.previewLayer.position = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
    [self.view.layer addSublayer:self.previewLayer];
    [self.session startRunning];

#warning ---  设置扫描作用域范围(中间透明的扫描框)
    CGRect intertRect = [self.previewLayer metadataOutputRectOfInterestForRect:CGRectMake(kScreenWidth*0.15, kScreenWidth*0.15+64, kScreenWidth*0.7, kScreenWidth*0.7)];
    output.rectOfInterest = intertRect;
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.opacity = 0.6;
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(kScreenWidth*0.15, kScreenWidth*0.15+64, kScreenWidth*0.7, kScreenWidth*0.7)];
    UIBezierPath *fillPath = [UIBezierPath bezierPathWithRect:self.view.bounds];
    [fillPath appendPath:path];
    maskLayer.path = fillPath.CGPath;
    maskLayer.fillRule = kCAFillRuleEvenOdd;
    [self.view.layer addSublayer:maskLayer];
    
    CALayer *lineLayer = [CALayer layer];
    lineLayer.frame = CGRectMake(kScreenWidth*0.15, kScreenWidth*0.15+64, kScreenWidth*0.7, 2);
    lineLayer.backgroundColor = [UIColor whiteColor].CGColor;
    [self.view.layer addSublayer:lineLayer];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    animation.fromValue  = @(0);
    animation.toValue = @( kScreenWidth*0.7);
    animation.duration  = 3;
    animation.removedOnCompletion = YES ; //yes 的话，又返回原位置了。
    animation.repeatCount = MAXFLOAT ;
    animation.fillMode = kCAFillModeForwards;
    [lineLayer addAnimation:animation forKey:@"frame.origin.y"];
    
    
    // Do any additional setup after loading the view.
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.session stopRunning];
}
- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    
    if (metadataObjects.count > 0) {
        [_session stopRunning];
        AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects objectAtIndex:0];
        NSLog(@"stringValue = %@",metadataObject.stringValue);
        if ([[metadataObject type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"结果" message:metadataObject.stringValue delegate:nil cancelButtonTitle:@"取消" otherButtonTitles: nil];
            [alertView show];
        }
    }
 
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
