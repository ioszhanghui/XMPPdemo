//
//  ZHNavigatioController.m
//  XMPPdemo
//
//  Created by 小飞鸟 on 2017/6/17.
//  Copyright © 2017年 正和普惠. All rights reserved.
//

#import "ZHNavigatioController.h"

@interface ZHNavigatioController ()

@end

@implementation ZHNavigatioController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationBar setBarTintColor:[UIColor colorWithRed:27/255.0 green:166/255.0 blue:222/255.0 alpha:1.0]];
    
    [self.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,[UIFont systemFontOfSize:16],NSFontAttributeName,nil]];
}


@end
