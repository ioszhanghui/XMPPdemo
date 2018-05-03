//
//  FriendModel.h
//  XMPPdemo
//
//  Created by 小飞鸟 on 2017/6/16.
//  Copyright © 2017年 正和普惠. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "XMPPManager.h"


@interface User : NSObject

@property (nonatomic, strong) XMPPJID *jid;
@property (nonatomic, strong) NSString * jidStr;
@property (nonatomic, strong) NSString * streamBareJidStr;

@property (nonatomic, strong) NSString * nickname;
@property (nonatomic, strong) NSString * displayName;
@property (nonatomic, strong) NSString * subscription;
@property (nonatomic, strong) NSString * ask;
@property (nonatomic, strong) NSNumber * unreadMessages;
@property (nonatomic, strong) UIImage *photo;

@property (nonatomic, strong) NSString * sectionName;

/*在线状态*/
@property(nonatomic,strong)XMPPPresence * presence;

@end

@interface FriendModel : NSObject

/*分组的打开与关闭*/
@property(nonatomic,assign)BOOL isOpen;

/*每一个分组的好友数据*/
@property(nonatomic,strong)NSArray * userArr;
/*每一个分组的组名*/
@property(nonatomic,copy)NSString * sectionName;

@end
