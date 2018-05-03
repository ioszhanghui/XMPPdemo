//
//  ZHChatViewController.h
//  XMPPdemo
//
//  Created by 小飞鸟 on 2017/6/20.
//  Copyright © 2017年 正和普惠. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPManager.h"

@interface ZHChatViewController : UIViewController
/*用户的JID*/
@property(nonatomic,strong)XMPPJID * jid;

/*展示视图*/
@property(nonatomic,strong)UITableView *tableView;
/*用户聊天数据*/
@property(nonatomic,strong)NSMutableArray * messageArr;

@end
