//
//  EditImageView.h
//  ExampleProject
//
//  Created by 廉鑫博 on 2017/10/9.
//  Copyright © 2017年 廉鑫博. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol EditImageViewDelegate <NSObject>
-(void)editImageViewCancelTakeImage;
@end

@interface EditImageView : UIView

@property (strong, nonatomic)UIImage *image;

@property (weak, nonatomic)id<EditImageViewDelegate> delegate;
@end

