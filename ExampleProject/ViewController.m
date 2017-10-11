//
//  ViewController.m
//  ExampleProject
//
//  Created by 廉鑫博 on 2017/8/20.
//  Copyright © 2017年 廉鑫博. All rights reserved.
//

#import "ViewController.h"
#import "PhotoViewController.h"
#import "QRCodeViewController.h"
#import "ShotViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import <AVKit/AVKit.h>
#import "RecordViewController.h"


@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic)UITableView *tableView;

@property (copy, nonatomic)NSArray *titleArr;

@end

static NSString *kEPCellIdentifier = @"kEPCellIdentifier";

@implementation ViewController


-(NSArray *)titleArr
{
    if (!_titleArr) {
        _titleArr = @[@"拍照",@"二维码",@"摄像",@"录音",@"播放"];
    }
    return _titleArr;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 64) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kEPCellIdentifier];
    _tableView = tableView;
    
    // Do any additional setup after loading the view, typically from a nib.
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.titleArr.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kEPCellIdentifier];
    cell.textLabel.text = self.titleArr[indexPath.row];
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    if (indexPath.row == 0) {
        PhotoViewController *photoVC = [[PhotoViewController alloc]init];
        [self.navigationController pushViewController:photoVC animated:true];
    }else if (indexPath.row == 1)
    {
        QRCodeViewController *qrCodeVC = [[QRCodeViewController alloc]init];
        [self.navigationController pushViewController:qrCodeVC animated:true];
    }else if (indexPath.row == 2)
    {
        ShotViewController *shotVC = [[ShotViewController alloc]init];
        [self.navigationController pushViewController:shotVC animated:true];
    }else if (indexPath.row == 3)
    {
        RecordViewController *recordVC = [[RecordViewController alloc]init];
        [self.navigationController pushViewController:recordVC animated:true];
    }
    else if (indexPath.row == 4){
        ///8269731A-C469-4695-9BDC-B4E892AACDC1/L0/001
        PHFetchResult *phResult = [PHAsset fetchAssetsWithLocalIdentifiers:@[@"6F4813DA-EB1D-482D-9D16-8C4D6C4C53E7/L0/001"] options:nil];
        PHVideoRequestOptions *options  = [[PHVideoRequestOptions alloc]init];
        __block AVPlayerItem * playItem = nil;
        [PHImageManager.defaultManager requestPlayerItemForVideo:phResult.firstObject options:options resultHandler:^(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                playItem = playerItem;
                AVPlayerViewController *playVC = [[AVPlayerViewController alloc]init];
                AVPlayer *player = [AVPlayer playerWithPlayerItem:playItem];
                playVC.videoGravity = AVLayerVideoGravityResizeAspectFill;
                playVC.player = player;
                [self.navigationController pushViewController:playVC animated:true];
            });
        }];

        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
