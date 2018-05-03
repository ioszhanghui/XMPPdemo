//
//  ZHToolView.h
//  XMPPdemo
//
//  Created by 小飞鸟 on 2017/6/20.
//  Copyright © 2017年 正和普惠. All rights reserved.
//

#import <UIKit/UIKit.h>

//录音时的音量
typedef void (^AudioVolumeBlock) (CGFloat volume);
//录音存储地址
typedef void (^AudioURLBlock) (NSURL *audioURL);

//改变根据文字改变TextView的高度
typedef void (^ContentSizeBlock)(CGSize contentSize);

//录音取消的回调
typedef void (^CancelRecordBlock)(int flag);

@interface ZHToolView : UIView


//传输volome的block回调
@property (copy, nonatomic) AudioVolumeBlock volumeBlock;

//传输volome的block回调
@property (copy, nonatomic) CancelRecordBlock cancelBlock;

/*录制的音频路径*/
@property(nonatomic,copy)AudioURLBlock urlBlock;



@end
