//
//  XMPPManager.h
//  XMPPdemo
//
//  Created by zhph on 2017/6/9.
//  Copyright © 2017年 正和普惠. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XMPPFramework/XMPPFramework.h>


/*
 
 XMPPStream：xmpp基础服务类
 XMPPRoster：好友列表类
 XMPPRosterCoreDataStorage：好友列表（用户账号）在core data中的操作类
 XMPPvCardCoreDataStorage：好友名片（昵称，签名，性别，年龄等信息）在core data中的操作类
 XMPPvCardTemp：好友名片实体类，从数据库里取出来的都是它
 xmppvCardAvatarModule：好友头像
 XMPPReconnect：如果失去连接,自动重连
 XMPPRoom：提供多用户聊天支持
 XMPPPubSub：发布订阅
 */



@interface XMPPManager : NSObject<XMPPStreamDelegate,XMPPRosterDelegate>

/*登录的用户名*/
@property(nonatomic,copy)NSString * userName;

/*通信通道对象*/
@property(nonatomic,strong)XMPPStream * xmppStream;

/*好友花名册*/
@property(nonatomic,strong)XMPPRoster * xmppRoster;

/*好友数据管理对象*/
@property(nonatomic,strong)XMPPRosterCoreDataStorage * rosterCoreDataStorage;

/*分组好友数据管理对象*/
@property(nonatomic,strong)XMPPGroupCoreDataStorageObject * groupCoreDataStorage;



/*创建一个好友的数据管理器*/
@property(nonatomic,strong)NSManagedObjectContext * rosterContext;

/*信息归档对象*/
@property(nonatomic,strong)XMPPMessageArchiving * xmppMessageArchiving;

/*创建一个消息的数据管理器*/
@property(nonatomic,strong)NSManagedObjectContext * messageContext;



// 声明上传头像相关对象
@property (nonatomic , strong) XMPPvCardCoreDataStorage *xmppvCardStorage;
@property (nonatomic , strong) XMPPvCardTempModule *xmppvCardTempModule;
@property (nonatomic , strong) XMPPvCardAvatarModule *xmppvCardAvatarModule;




/*弹框提示*/
@property(nonatomic,strong)UIViewController * Ct;

/*添加好的回调*/
@property(nonatomic,copy)void(^ addFriendBlock)(BOOL isSuccess ,NSString* error);

/*删除好友好的回调*/
@property(nonatomic,copy)void(^ removeFriendBlock)(BOOL isSuccess ,NSString* error);

/*创建一个单例对象*/
+(XMPPManager*)shareManager;

-(void)loginWithUserName:(NSString*)userName Password:(NSString*)passWord;

//注册用户
-(void)registerWithUserName:(NSString*)userName Password:(NSString*)passWord;

//添加好友
-(void)addFriendWithUserName:(NSString*)userName CompleteBlock:(void (^)(BOOL isSuccess,NSString* errorMsg))addFriendBlock;

//删除好友
-(void)removeUserWithJID:(XMPPJID*)jid CompleteBlock:(void (^)(BOOL isSuccess,NSString* errorMsg))removeUserBlock;

//退出登录
-(void)logout;


/*上传用户的头像*/
- (void) uploadUserIconWithImage:(UIImage*)image NickName:(NSString*)nickName  CallBlock:(void(^)(UIImage* image))ChangeUserLogoBlock;
/*头像修改完之后的回调*/
@property(nonatomic,copy)void(^ ChangeUserLogoBlock)(UIImage* image);

@end
