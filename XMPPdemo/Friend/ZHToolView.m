//
//  ZHToolView.m
//  XMPPdemo
//
//  Created by 小飞鸟 on 2017/6/20.
//  Copyright © 2017年 正和普惠. All rights reserved.
//

#import "ZHToolView.h"
#import "FunctionView.h"
#import "MoreView.h"
#import <AVFoundation/AVFoundation.h>


@interface ZHToolView ()<UITextViewDelegate,UIAlertViewDelegate,AVAudioRecorderDelegate>

//语音和文字切换按钮
@property (nonatomic, strong) UIButton *voiceChangeButton;

//发送语音的按钮
@property (nonatomic, strong) UIButton *sendVoiceButton;

//文本输入视图
@property (nonatomic, strong) UITextView *sendTextView;

//表情键盘按钮
@property (nonatomic, strong) UIButton *changeKeyBoardButton;

//更多按钮
@property (nonatomic, strong) UIButton *moreButton;

//键盘坐标系的转换
@property (nonatomic, assign) CGRect endKeyBoardFrame;

//表情键盘
@property (nonatomic, strong) FunctionView *functionView;

//more
@property (nonatomic, strong) MoreView *moreView;


//添加录音功能的属性
@property (strong, nonatomic) AVAudioRecorder *audioRecorder;

/*录制音频文件路径*/
@property (strong, nonatomic) NSURL *audioPlayURL;

/*录音计时器*/
@property(nonatomic,strong)NSTimer *timer;

@end

@implementation ZHToolView


-(instancetype)initWithFrame:(CGRect)frame{

    if (self=[super initWithFrame:frame]) {
        
        UIColor *color = [UIColor colorWithPatternImage:[UIImage imageNamed:@"toolbar_bottom_bar.png"]];
        [self setBackgroundColor:color];
        
        [self addSubViews];

    }
    
    return self;

}

-(void)addSubViews{

    self.voiceChangeButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 15, 30, 20)];
    [self.voiceChangeButton setImage:[UIImage imageNamed:@"chat_bottom_voice_press.png"] forState:UIControlStateNormal];
    [self.voiceChangeButton addTarget:self action:@selector(tapVoiceChangeButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.voiceChangeButton];
    
    self.sendVoiceButton = [[UIButton alloc] initWithFrame:CGRectMake(self.voiceChangeButton.right+8, 10, 250, 30)];
    [self.sendVoiceButton setBackgroundImage:[UIImage imageNamed:@"chat_bottom_textfield.png"] forState:UIControlStateNormal];
    [self.sendVoiceButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.sendVoiceButton setTitle:@"按住说话" forState:UIControlStateNormal];
    
    [self.sendVoiceButton addTarget:self action:@selector(tapSendVoiceButton:) forControlEvents:UIControlEventTouchUpInside];
    
    //给sendVoiceButton添加长按手势
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(sendVoiceButtonLongPress:)];
    //设置长按时间
    longPress.minimumPressDuration = 0.2;
    [self.sendVoiceButton addGestureRecognizer:longPress];
    
    [self addSubview:self.sendVoiceButton];
    
    
    self.sendTextView = [[UITextView alloc] initWithFrame:CGRectMake(self.voiceChangeButton.right+8, 10, 250, 30)];
    self.sendTextView.delegate = self;
    self.sendTextView.hidden = YES;
    [self addSubview:self.sendTextView];
    
    self.changeKeyBoardButton = [[UIButton alloc] initWithFrame:CGRectMake(self.sendVoiceButton.right+10, 10, 30, 30)];
    [self.changeKeyBoardButton setImage:[UIImage imageNamed:@"chat_bottom_smile_nor.png"] forState:UIControlStateNormal];
    [self.changeKeyBoardButton addTarget:self action:@selector(tapChangeKeyBoardButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.changeKeyBoardButton];
    
    self.moreButton = [[UIButton alloc] initWithFrame:CGRectMake(kWindowWidth-12-26, 12, 26, 26)];
    [self.moreButton setImage:[UIImage imageNamed:@"chat_bottom_up_nor.png"] forState:UIControlStateNormal];
    [self.moreButton addTarget:self action:@selector(tapMoreButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.moreButton];

}

//切换声音按键和文字输入框
-(void)tapVoiceChangeButton:(UIButton *) sender{

    if (self.sendVoiceButton.hidden==YES) {
        
        self.sendVoiceButton.hidden=NO;
        self.sendTextView.hidden=YES;
        
        [self.voiceChangeButton setImage:[UIImage imageNamed:@"chat_bottom_keyboard_nor.png"] forState:UIControlStateNormal];
        
        if ([self.sendTextView becomeFirstResponder]) {
            [self.sendTextView resignFirstResponder];
        }
        
    }else{
        
        self.sendVoiceButton.hidden=YES;
        self.sendTextView.hidden=NO;
        
        [self.voiceChangeButton setImage:[UIImage imageNamed:@"chat_bottom_voice_press.png"] forState:UIControlStateNormal];
        
        if (![self.sendTextView resignFirstResponder]) {
            [self.sendTextView becomeFirstResponder];
        }

    }
    

}

//发送声音按钮回调的方法
-(void)tapSendVoiceButton:(UIButton *) sender
{
    NSLog(@"sendVoiceButton");
    //点击发送按钮没有触发长按手势要做的事儿
    UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"提示" message:@"按住录音" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles: nil];
    [alter show];
}

//长按录制音频
-(void)sendVoiceButtonLongPress:(id)sender{
    static int i = 1;
    if ([sender isKindOfClass:[UILongPressGestureRecognizer class]]) {
        
        UILongPressGestureRecognizer * longPress = sender;
        
        //录音开始
        if (longPress.state == UIGestureRecognizerStateBegan)
        {
            
            i = 1;
            
            [self.sendVoiceButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            //录音初始化
            [self audioInit];
            
            //创建录音文件，准备录音
            if ([self.audioRecorder prepareToRecord])
            {
                //开始
                [self.audioRecorder record];
                
                //设置定时检测音量变化
                _timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(detectionVoice) userInfo:nil repeats:YES];
            }
        }
        
        //取消录音
        if (longPress.state == UIGestureRecognizerStateChanged){
            
            CGPoint piont = [longPress locationInView:self];
            NSLog(@"%f",piont.y);
            
            if (piont.y < -20)
            {
                if (i == 1) {
                    
                    [self.sendVoiceButton setBackgroundImage:[UIImage imageNamed:@"chat_bottom_textfield.png"] forState:UIControlStateNormal];
                    [self.sendVoiceButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    //删除录制文件
                    [self.audioRecorder deleteRecording];
                    [self.audioRecorder stop];
                    [_timer invalidate];
                    
                    UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"提示" message:@"录音取消" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles: nil];
                    [alter show];
                    //去除图片用的
                    self.cancelBlock(1);
                    i = 0;
                    
                }
                
                
            }
        }
        
        if (longPress.state == UIGestureRecognizerStateEnded) {
            if (i == 1)
            {
                NSLog(@"录音结束");
                [self.sendVoiceButton setBackgroundImage:[UIImage imageNamed:@"chat_bottom_textfield.png"] forState:UIControlStateNormal];
                [self.sendVoiceButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                
                double cTime = self.audioRecorder.currentTime;
                if (cTime > 1)
                {
                    //如果录制时间<1 不发送
                    NSLog(@"发出去");
                    self.urlBlock(_audioPlayURL);
                }
                else
                {
                    //删除记录的文件
                    [self.audioRecorder deleteRecording];
                    [self.audioRecorder stop];
                    
                    UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"提示" message:@"录音时间太短！" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles: nil];
                    [alter show];
                    self.cancelBlock(1);
                    
                }
                
                [_timer invalidate];
            }
        }


        
    }

}

//录音的音量探测
- (void)detectionVoice
{
    [self.audioRecorder updateMeters];//刷新音量数据
    //获取音量的平均值  [recorder averagePowerForChannel:0];
    //音量的最大值  [recorder peakPowerForChannel:0];
    
    CGFloat lowPassResults = pow(10, (0.05 * [self.audioRecorder peakPowerForChannel:0]));
    
    //把声音的音量传给调用者
    self.volumeBlock(lowPassResults);
}

//录音部分初始化
-(void)audioInit{
    
    
    NSError * err = nil;
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory :AVAudioSessionCategoryPlayAndRecord error:&err];
    
    if(err){
        NSLog(@"audioSession:%@",[[err userInfo] description]);
        return;
    }
    
    [audioSession setActive:YES error:&err];
    
    err = nil;
    if(err){
        NSLog(@"audioSession: %@", [[err userInfo] description]);
        return;
    }
    
    //通过可变字典进行配置项的加载
    NSMutableDictionary *setAudioDic = [[NSMutableDictionary alloc] init];
    
    //设置录音格式(aac格式)
    [setAudioDic setValue:@(kAudioFormatMPEG4AAC) forKey:AVFormatIDKey];
    
    //设置录音采样率(Hz) 如：AVSampleRateKey==8000/44100/96000（影响音频的质量）
    [setAudioDic setValue:@(44100) forKey:AVSampleRateKey];
    
    //设置录音通道数1 Or 2
    [setAudioDic setValue:@(1) forKey:AVNumberOfChannelsKey];
    
    //线性采样位数  8、16、24、32
    [setAudioDic setValue:@16 forKey:AVLinearPCMBitDepthKey];
    //录音的质量
    [setAudioDic setValue:@(AVAudioQualityHigh) forKey:AVEncoderAudioQualityKey];
    
    
    NSString *strUrl = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *fileName = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
    
    
    NSString * filePath = [NSString stringWithFormat:@"%@/%@.aac", strUrl, fileName];
    
    NSURL *url = [NSURL fileURLWithPath:filePath];
    _audioPlayURL = url;
    
    NSError *error;
    //初始化
    self.audioRecorder = [[AVAudioRecorder alloc]initWithURL:url settings:setAudioDic error:&error];
    //开启音量检测
    self.audioRecorder.meteringEnabled = YES;
    self.audioRecorder.delegate = self;
    
//
//    if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
//        
//        [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
//            if (granted) {
//                
//                // 用户同意获取麦克风，一定要在主线程中执行UI操作！！！
//                dispatch_queue_t queueOne = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//                dispatch_async(queueOne, ^{
//                    
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        
//                        //在主线程中执行UI，这里主要是执行录音和计时的UI操作
//                        
//                        
//                    });
//                });
//            } else {
//                
//                //如果要让用户直接跳转到设置界面，则可以进行下面的操作，如不需要，就忽略下面的代码
//                /*
//                 *iOS10 开始苹果禁止应用直接跳转到系统单个设置页面，只能跳转到应用所有设置页面
//                 *iOS10以下可以添加单个设置的系统路径，并在info里添加URL Type，将URL schemes 设置路径为prefs即可。
//                 *@"prefs:root=Sounds"
//                 */
//                
//                
//                //点击发送按钮没有触发长按手势要做的事儿
//                UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"提示" message:@"按住录音" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//                alter.tag=200;
//                [alter show];
//            }
//        }];
//    }
    
}

#pragma mark 录音结束
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{



}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{

    if (buttonIndex==1) {
        
        NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        
        if([[UIApplication sharedApplication] canOpenURL:url]) {
            
            [[UIApplication sharedApplication] openURL:url options:nil completionHandler:^(BOOL success) {
                
            }];
        }
    }
}

//变成表情键盘
-(void)tapChangeKeyBoardButton:(UIButton *) sender{



}

//功能扩展
-(void)tapMoreButton:(UIButton *) sender{



}



@end
