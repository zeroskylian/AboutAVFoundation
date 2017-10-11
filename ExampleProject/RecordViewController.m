//
//  RecordViewController.m
//  ExampleProject
//
//  Created by 廉鑫博 on 2017/10/11.
//  Copyright © 2017年 廉鑫博. All rights reserved.
//

#import "RecordViewController.h"
@import AVFoundation;

@interface RecordViewController ()

@property (strong, nonatomic)AVAudioRecorder *record;
@property (strong, nonatomic)AVAudioPlayer * player ;

@end

@implementation RecordViewController

-(AVAudioRecorder *)record
{
    if (!_record) {
        NSMutableDictionary *recordSetting = [NSMutableDictionary dictionary];
        // 录音格式 kAudioFormat...
        [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
        // 录音采样率 8000(电话所用采样率) 44100(音频 CD) 96000( DVD-Audio、一些 LPCM DVD 音轨、BD-ROM（蓝光盘）音轨、和 HD-DVD （高清晰度 DVD）音轨所用所用采样率)
        [recordSetting setValue:[NSNumber numberWithInt:44100] forKey:AVSampleRateKey];
        // 录音通道数 1 或 2 单声道或立体声
        [recordSetting setValue:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
        // 线性采样位数 数值越大,分辨率越高
        [recordSetting setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
        /// 录音质量
        [recordSetting setValue:[NSNumber numberWithInt:AVAudioQualityHigh] forKey:AVEncoderAudioQualityKey];
        
        // 创建沙盒路径
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        // 拼接音频文件
        NSString *filePath = [path stringByAppendingPathComponent:@"123.caf"];
        
        NSURL *url = [NSURL fileURLWithPath:filePath];
        
        NSLog(@"%@",url);
        NSError *error = nil;
        _record = [[AVAudioRecorder alloc]initWithURL:url settings:recordSetting error:&error];
//        _record.delegate = self;
    }
    return _record;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *playButton = [[UIButton alloc]initWithFrame:CGRectMake(kScreenWidth/2 - 50, 100, 100, 40)];
    [playButton setTitle:@"play" forState:UIControlStateNormal];
    [playButton addTarget:self action:@selector(playRecord) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:playButton];
    
    UIButton *recordButton = [[UIButton alloc]initWithFrame:CGRectMake(kScreenWidth/2 - 50, 200, 100, 40)];
    [recordButton setTitle:@"record" forState:UIControlStateNormal];
    [recordButton addTarget:self action:@selector(recordVoice) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:recordButton];
    
    UIButton *stopButton = [[UIButton alloc]initWithFrame:CGRectMake(kScreenWidth/2 - 50, 300,100, 40)];
    [stopButton addTarget:self action:@selector(stopRecord) forControlEvents:UIControlEventTouchUpInside];
    [stopButton setTitle:@"stop" forState:UIControlStateNormal];
    [self.view addSubview:stopButton];
    self.view.backgroundColor  = UIColor.orangeColor;
    // Do any additional setup after loading the view.
}
-(void)playRecord
{
    // 创建沙盒路径
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    // 拼接音频文件
    NSString *filePath = [path stringByAppendingPathComponent:@"123.caf"];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    
     _player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    //属性设置
    [_player play]; //播放
}
-(void)recordVoice
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryRecord error:nil];
    [self.record record];
}
-(void)stopRecord
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryAmbient error:nil];
    [self.record stop];
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
