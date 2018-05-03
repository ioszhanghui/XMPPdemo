 //
//  ViewController.m
//  XMPPdemo
//
//  Created by zhph on 2017/6/9.
//  Copyright © 2017年 正和普惠. All rights reserved.
//

#import "ViewController.h"
#import "XMPPManager.h"
#import "FriendTableViewController.h"
#import "ZHTabBarController.h"

@interface ViewController ()<XMPPStreamDelegate>


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    UIButton * logIN =[UIButton buttonWithType:UIButtonTypeCustom];
    [logIN setTitle:@"登录" forState:UIControlStateNormal];
    logIN.frame=CGRectMake(30, 100, 50, 30);
    [logIN setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [logIN addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:logIN];
    
    
    UIButton * reigister =[UIButton buttonWithType:UIButtonTypeCustom];
    [reigister setTitle:@"注册" forState:UIControlStateNormal];
     [reigister setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    reigister.frame=CGRectMake(30, 180, 50, 30);
    [reigister addTarget:self action:@selector(registerAction) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:reigister];
    
    [[XMPPManager shareManager].xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    [XMPPManager shareManager].Ct=self;
  
}

/*验证成功*/
-(void)xmppStreamDidAuthenticate:(XMPPStream *)sender{

    NSLog(@"%s------登录成功",__func__);
    //
    XMPPPresence * presence =[XMPPPresence presenceWithType:@"available"];
    [[XMPPManager shareManager].xmppStream sendElement:presence];
    
    ZHTabBarController * Tab =[[ZHTabBarController alloc]init];
    [UIApplication sharedApplication].keyWindow.rootViewController=Tab;
    
}

-(void)login{
    NSString * userName=@"user";
    NSString * pwd =@"91582266";
    [[XMPPManager shareManager]loginWithUserName:userName Password:pwd];;
    
    [KUserDefaults setObject:userName forKey:UserID];
    
     [KUserDefaults setObject:pwd forKey:PassWord];
    

}

-(void)registerAction{

    NSString * userName=@"8080";
    NSString * pwd =@"91582266";
    [[XMPPManager shareManager]registerWithUserName:userName Password:pwd];;

}

@end
