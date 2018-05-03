//
//  YZTabBarController.m
//  UZ-iOS
//
//  Created by 小飞鸟 on 16/4/9.
//  Copyright © 2016年 uzteam. All rights reserved.
//

#import "ZHTabBarController.h"
#import "MessageViewController.h"
#import "FriendTableViewController.h"
#import "SpaceViewController.h"
#import "AppDelegate.h"
#import "ZHNavigatioController.h"

@interface ZHTabBarController()<UINavigationControllerDelegate>

@end


@implementation ZHTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];

    MessageViewController * mine =[[MessageViewController alloc]init];
    ZHNavigatioController * msgNVi=[[ZHNavigatioController alloc]initWithRootViewController:mine];
    
    FriendTableViewController * friend =[[FriendTableViewController alloc]init];
    ZHNavigatioController * friendNvc=[[ZHNavigatioController alloc]initWithRootViewController:friend];

    SpaceViewController * space =[[SpaceViewController alloc]init];
    ZHNavigatioController * spaceNvc=[[ZHNavigatioController alloc]initWithRootViewController:space];

    
    
    self.viewControllers=@[msgNVi,friendNvc,spaceNvc];
    self.selectedViewController=msgNVi;

    UITabBar *tabBar = self.tabBar;
    
    NSArray * unSelectedImages=@[@"tab_recent_nor",@"tab_buddy_nor",@"tab_qworld_nor"];
    NSArray * selectedImages=@[@"tab_recent_press",@"tab_buddy_press",@"tab_qworld_press"];
    NSArray * subTitles=@[@"消息",@"好友",@"空间"];
    

    for (NSInteger i=0; i<subTitles.count; i++) {
        
        UITabBarItem * item=[tabBar.items objectAtIndex:i];
        // 对item设置相应地图片
        item.selectedImage = [[UIImage imageNamed:[selectedImages objectAtIndex:i]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];;
        item.image = [[UIImage imageNamed:[unSelectedImages objectAtIndex:i]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [item setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor grayColor]} forState:UIControlStateNormal];
        [item setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor orangeColor]}forState:UIControlStateSelected];
        [item setTitle:[subTitles objectAtIndex:i]];
    }
  
}


-(void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated{
    
    if (viewController.hidesBottomBarWhenPushed) {
        self.tabBar.hidden = YES;
    } else {
        self.tabBar.hidden = NO;
    }
}

@end
