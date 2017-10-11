//
//  PlayVideoView.h
//  ExampleProject
//
//  Created by 廉鑫博 on 2017/10/10.
//  Copyright © 2017年 廉鑫博. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PlayVideoViewDelegate <NSObject>
-(void)playVideoViewCancel;
@end
@interface PlayVideoView : UIView
@property (strong, nonatomic)NSURL *url;
@property (weak, nonatomic)id<PlayVideoViewDelegate> delegate;
@end
