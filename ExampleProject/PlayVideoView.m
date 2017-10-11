//
//  PlayVideoView.m
//  ExampleProject
//
//  Created by 廉鑫博 on 2017/10/10.
//  Copyright © 2017年 廉鑫博. All rights reserved.
//

#import "PlayVideoView.h"
@import AVFoundation;
@import Photos;


@interface PlayVideoView()
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playItem;// 一个媒体资源管理对象，管理者视频的一些基本信息和状态，一个AVPlayerItem对应着一个视频资源
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, assign) BOOL isPlaying;

@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIButton *replayButton;
@property (nonatomic, strong) UIButton *saveButton;
@property (strong, nonatomic) UIButton *cancelButton;

@end;
@implementation PlayVideoView
-(UIButton *)playButton
{
    if (!_playButton) {
        _playButton = [[UIButton alloc]initWithFrame:CGRectMake(kScreenWidth/4 - 40, self.frame.size.height - 100, 80, 80)];
        [_playButton setTitle:@"播放" forState:UIControlStateNormal];
        _playButton.backgroundColor = [UIColor lightGrayColor];
        [_playButton addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_playButton];
    }
    return _playButton;
}
-(void)playVideo:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if (!sender.selected) {
        [_player play];
    }else
    {
        [_player pause];
    }
}
-(UIButton *)replayButton
{
    if (!_replayButton) {
        _replayButton = [[UIButton alloc]initWithFrame:CGRectMake(kScreenWidth/4 - 40, self.frame.size.height - 100, 80, 80)];
        [_replayButton setTitle:@"重播" forState:UIControlStateNormal];
        _replayButton.backgroundColor = [UIColor lightGrayColor];
        [_replayButton addTarget:self action:@selector(replayVideo:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_replayButton];
    }
    return _replayButton;
}
-(void)replayVideo:(UIButton *)sender
{
    
}
-(UIButton *)saveButton
{
    if (!_saveButton) {
        _saveButton = [[UIButton alloc]initWithFrame:CGRectMake(kScreenWidth * 3/4 - 40, self.frame.size.height - 100, 80, 80)];
        [_saveButton setTitle:@"保存" forState:UIControlStateNormal];
        _saveButton.backgroundColor = [UIColor lightGrayColor];
        [_saveButton addTarget:self action:@selector(saveVideo:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_saveButton];
    }
    return _saveButton;
}
-(void)saveVideo:(UIButton *)sender
{
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetChangeRequest *req = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:_url];
        NSLog(@"localIdentifier ====%@",req.placeholderForCreatedAsset.localIdentifier);
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            NSLog(@"保存成功");
        }else
        {
            NSLog(@"保存失败%@",error) ;
        }
    }];
}


-(UIButton *)cancelButton
{
    if (!_cancelButton) {
        _cancelButton = [[UIButton alloc]initWithFrame:CGRectMake(kScreenWidth * 3/4 - 40, 100, 80, 80)];
        _cancelButton.backgroundColor = [UIColor lightGrayColor];
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [self addSubview:_cancelButton];
        [_cancelButton addTarget:self action:@selector(cancelVideo:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}
-(void)cancelVideo:(UIButton *)sender
{
    self.hidden = true;
    if ([self.delegate respondsToSelector:@selector(playVideoViewCancel)]) {
        [self.delegate playVideoViewCancel];
    }
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self playButton];
        [self replayButton];
        [self saveButton];
        [self cancelButton];
    }
    return self;
}
-(void)setUrl:(NSURL *)url
{
    _url = url;
    self.playItem = [AVPlayerItem playerItemWithURL:self.url];
    self.player = [AVPlayer playerWithPlayerItem:self.playItem];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.frame = self.frame;
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;//视频填充模式
    CALayer *layer = self.layer;
    layer.masksToBounds = true;
    [layer addSublayer:_playerLayer];
    [self bringSubviewToFront:_playButton];
    [self bringSubviewToFront:_cancelButton];
    [self bringSubviewToFront:_saveButton];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
