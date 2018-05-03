//
//  XMPPManager.m
//  XMPPdemo
//
//  Created by zhph on 2017/6/9.
//  Copyright © 2017年 正和普惠. All rights reserved.
//

#import "XMPPManager.h"
#import "CocoaLumberjack.h"

typedef enum : NSUInteger {
    XMPP_LogIn,//登录
    XMPP_Register, //注册
} XMPP_Type;

@interface XMPPManager ()<UIAlertViewDelegate>
/*记录一下密码*/
@property(nonatomic,copy)NSString * passWord;
//记录一下类型
@property(nonatomic,assign)XMPP_Type type;

/*添加的好友的JID*/
@property(strong,nonatomic)XMPPJID * JID;

@end

XMPPManager * mananger =nil;

@implementation XMPPManager
+(XMPPManager*)shareManager{

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mananger=[[XMPPManager alloc]init];
        /*打印日志*/
//        [mananger setUpLogging];
    });
    
    return mananger;
    
}

-(instancetype)init{

    if (self=[super init]) {
        //创建通信通道对象
        self.xmppStream=[[XMPPStream alloc]init];
        //设置服务器IP地址
        self.xmppStream.hostName=KHostName;
        //端口号设置
        self.xmppStream.hostPort=KHostPort;
        //添加代理
        [self.xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        //好友花名册数据管理对象
        self.rosterCoreDataStorage=[XMPPRosterCoreDataStorage sharedInstance];

        //创建好友花名册管理对象
        self.xmppRoster=[[XMPPRoster alloc]initWithRosterStorage:self.rosterCoreDataStorage dispatchQueue:dispatch_get_main_queue()];
        //激活
        [self.xmppRoster activate:self.xmppStream];
        //添加代理
        [self.xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        //设置好友同步策略,XMPP一旦连接成功，同步好友到本地
        [self.xmppRoster setAutoFetchRoster:YES]; //自动同步，从服务器取出好友
        
        //创建好友的数据管理器
        self.rosterContext=self.rosterCoreDataStorage.mainThreadManagedObjectContext;

        //创建信息归档数据存储对象
        XMPPMessageArchivingCoreDataStorage * xmppMessageAchingvingStorage=[XMPPMessageArchivingCoreDataStorage sharedInstance];
        //创建信息归档对象
        self.xmppMessageArchiving =[[XMPPMessageArchiving alloc]initWithMessageArchivingStorage:xmppMessageAchingvingStorage dispatchQueue:dispatch_get_main_queue()];
        //激活通信通道
        [self.xmppMessageArchiving activate:self.xmppStream];
        
        //创建数据管理器
        self.messageContext=xmppMessageAchingvingStorage.mainThreadManagedObjectContext;
        
        
        //设置电子名片模块
        self.xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
        self.xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:_xmppvCardStorage];
        //设置电子名片头像模块，此处不导入也可以，一样可以获取到自己头像，只是后面获取好友信息时获取不到头像，得根据JID利用此模块获取好友头像
        self.xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:_xmppvCardTempModule];
        
        [_xmppvCardTempModule addDelegate:self delegateQueue:dispatch_get_main_queue()];
        [_xmppvCardAvatarModule addDelegate:self delegateQueue:dispatch_get_main_queue()];
        
    }
    
    return self;
    
}

/*上传图片*/
- (void) uploadUserIconWithImage:(UIImage*)image NickName:(NSString*)nickName  CallBlock:(void(^)(UIImage* image))ChangeUserLogoBlock {
    
    self.ChangeUserLogoBlock=ChangeUserLogoBlock;
    
    dispatch_queue_t  global_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(global_queue, ^{
        
        NSXMLElement *vCardXML = [NSXMLElement elementWithName:@"vCard"];
        [vCardXML addAttributeWithName:@"xmlns" stringValue:@"vcard-temp"];
        NSXMLElement *photoXML = [NSXMLElement elementWithName:@"PHOTO"];
        NSXMLElement *typeXML = [NSXMLElement elementWithName:@"TYPE" stringValue:@"image/jpeg"];

        NSData *dataFromImage = UIImageJPEGRepresentation(image, 1.0f);//图片放缩
        NSXMLElement *binvalXML = [NSXMLElement elementWithName:@"BINVAL" stringValue:[dataFromImage base64Encoding]];
        [photoXML addChild:typeXML];
        [photoXML addChild:binvalXML];
        [vCardXML addChild:photoXML];
        
        XMPPvCardTemp * myvCardTemp = [_xmppvCardTempModule myvCardTemp];
        if (myvCardTemp) {
            myvCardTemp.photo = dataFromImage;
            [_xmppvCardTempModule activate: self.xmppStream];
            [_xmppvCardTempModule updateMyvCardTemp:myvCardTemp];
        } else {
            XMPPvCardTemp *newvCardTemp = [XMPPvCardTemp vCardTempFromElement:vCardXML];
            newvCardTemp.nickname = nickName;
            [_xmppvCardTempModule activate: self.xmppStream];
            [_xmppvCardTempModule updateMyvCardTemp:newvCardTemp];
        }
    });
}

/*上传头像之后进行的回调*/
-(void)xmppvCardTempModule:(XMPPvCardTempModule *)vCardTempModule didReceivevCardTemp:(XMPPvCardTemp *)vCardTemp forJID:(XMPPJID *)jid{
    
}

 /****************** -------- 接收到头像更改 -------- ******************/
- (void)xmppvCardAvatarModule:(XMPPvCardAvatarModule *)vCardTempModule didReceivePhoto:(UIImage *)photo forJID:(XMPPJID *)jid {
//    if (self.changeAvatarPhoto) {
//        self.changeAvatarPhoto();
//    }
}

/****************** -------- 上传头像成功 -------- ******************/
- (void)xmppvCardTempModuleDidUpdateMyvCard:(XMPPvCardTempModule *)vCardTempModule {
    if (self.ChangeUserLogoBlock) {
        
        self.ChangeUserLogoBlock([[UIImage alloc]initWithData:vCardTempModule.myvCardTemp.photo]);
    }
}




/*打印日志*/
-(void)setUpLogging{
    
    /*
     
     1.如果你将日志级别设置为 LOG_LEVEL_ERROR，那么你只会看到DDlogError语句。
     2.如果你将日志级别设置为LOG_LEVEL_WARN，那么你只会看到DDLogError和DDLogWarn语句。
     3.如果您将日志级别设置为 LOG_LEVEL_INFO,那么你会看到error、Warn和Info语句。
     4.如果您将日志级别设置为LOG_LEVEL_VERBOSE,那么你会看到所有DDLog语句。
     5.如果您将日志级别设置为 LOG_LEVEL_OFF,你将不会看到任何DDLog语句
     
     */

    setenv("XcodeColors", "YES", 0);
    [DDLog addLogger:[DDTTYLogger sharedInstance] withLevel:XMPP_LOG_FLAG_SEND_RECV];
    //日志框架使用颜色
    [[DDTTYLogger sharedInstance]setColorsEnabled:YES];
    //设置自定义颜色
     [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor greenColor] backgroundColor:nil forFlag:DDLogFlagInfo];
}

/*登录方法*/
-(void)loginWithUserName:(NSString*)userName Password:(NSString*)passWord{

    //连接服务器
    
    self.userName=userName;
    self.passWord= passWord;
    self.type=XMPP_LogIn;
    [self connectToserverWithUserName:userName];
}

/*注册用户*/
-(void)registerWithUserName:(NSString*)userName Password:(NSString*)passWord{

    self.passWord=passWord;
    self.type=XMPP_Register;
    [self connectToserverWithUserName:userName];
}

/*添加好友*/
-(void)addFriendWithUserName:(NSString*)userName CompleteBlock:(void (^)(BOOL isSuccess,NSString* errorMsg))addFriendBlock{
    
    self.addFriendBlock=addFriendBlock;
    
    if (NULLString(userName)) {
        self.addFriendBlock(NO,@"添加的用户名不能为空");
        return;
    }
    
    //创建JID
    XMPPJID * JID =[XMPPJID jidWithUser:userName domain:KDomin resource:Kresource];
#pragma warning 
    /*判断是不是已经是自己好友*/
//    if ([self.rosterCoreDataStorage userForJID:JID
//                            xmppStream:_xmppStream
//                  managedObjectContext:self.context]) {
//        self.addFriendBlock(NO,@"添加的用户名已经是好友了");
//        
//        return;
//    }
        
     [[XMPPManager shareManager].xmppRoster subscribePresenceToUser:JID];
    
//    [[XMPPManager shareManager].xmppRoster addUser:JID withNickname:@"张辉"];
}


/*链接服务器*/
-(void)connectToserverWithUserName:(NSString*)userName{
    
    //创建XMPPJID对像
    XMPPJID * jid =[XMPPJID jidWithUser:userName domain:KDomin resource:Kresource];
    //创建通信通道对象的JID
    self.xmppStream.myJID=jid;
    //发送请求
    if ([self.xmppStream isConnected]||[self.xmppStream isConnecting]) {
        //先发送下线状态
        XMPPPresence * presence =[XMPPPresence presenceWithType:@"unavailable"];
        [self.xmppStream sendElement:presence];
        //断开链接
        [self.xmppStream disconnect];
    }
    
    //向服务器发送请求
    NSError * error=nil;
    [self.xmppStream connectWithTimeout:-1 error:&error];
    if (error!=nil) {
        NSLog(@"链接失败%@",error.localizedDescription);
        
    }

}

/*链接超时的方法*/
-(void)xmppStreamConnectDidTimeout:(XMPPStream *)sender{
    NSLog(@"%s",__func__);


}

/*链接成功的方法*/
-(void)xmppStreamDidConnect:(XMPPStream *)sender{

    NSLog(@"%s",__func__);
    
    switch (self.type) {
        case XMPP_Register:
            //注册
            [self.xmppStream registerWithPassword:self.passWord error:nil];
            
            break;
            
        case XMPP_LogIn:
            //登录
            [self.xmppStream authenticateWithPassword:self.passWord error:nil];
            
            break;
            
        default:
            break;
    }
  
}

/*注册成功*/

-(void)xmppStreamDidRegister:(XMPPStream *)sender{

    NSLog(@"注册成功%s",__func__);
    
}
/*注册失败*/
-(void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error{
    NSLog(@"注册失败%s-----%@",__func__,error.description);

}

/*收到请求添加好友 或者删除好友的方法  收到其他人对你加好友请求接收的方法 */
-(void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence{

    // 好友在线状态
    NSString *type = [presence type];
    // 发送请求者
    NSString *fromUser = [[presence from] user];
    // 接收者id
    NSString *user = _xmppStream.myJID.user;
    
    // 防止自己添加自己为好友
    if ([fromUser isEqualToString:user]) {

        self.addFriendBlock(NO,@"不能添加自己为好友");
        return;
    }
    
    
    if ([type isEqualToString:@"subscribe"]) { // 添加好友
        
         self.JID=presence.from;
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示:有人添加你" message:presence.from.user  delegate:self cancelButtonTitle:@"拒绝" otherButtonTitles:@"同意", nil];
        [alert show];

    } else if ([type isEqualToString:@"unsubscribe"]) {
        // 请求删除好友
        
    }

}

#pragma mark AlertView的代理方法
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{

    if (buttonIndex==1) {
        
        //同意
        
        //允许添加好友
        [self.xmppRoster acceptPresenceSubscriptionRequestFrom:self.JID andAddToRoster:YES];
        
        return;
    }
    
    if (buttonIndex==0) {
        
        //拒绝
        
        //拒绝添加好友
        [self.xmppRoster rejectPresenceSubscriptionRequestFrom:self.JID];
        
        
        return;
    }

}

/* 删除 添加好友同意后，会进入到此代理*/

- (void)xmppRoster:(XMPPRoster *)sender didReceiveRosterPush:(XMPPIQ *)iq {
    NSLog(@"添加成功!!!didReceiveRosterPush -> :%@",iq.description);
    
    DDXMLElement *query = [iq elementsForName:@"query"][0];
    DDXMLElement *item = [query elementsForName:@"item"][0];
    
    NSString *subscription = [[item attributeForName:@"subscription"] stringValue];
    // 对方请求添加我为好友且我已同意
    if ([subscription isEqualToString:@"from"]) {// 对方关注我
        NSLog(@"我已同意对方添加我为好友的请求");
        if (self.addFriendBlock) {
            self.addFriendBlock(YES, nil);
        }
    }
    // 我成功添加对方为好友
    else if ([subscription isEqualToString:@"to"]) {// 我关注对方
        NSLog(@"我成功添加对方为好友，即对方已经同意我添加好友的请求");

        
    } else if ([subscription isEqualToString:@"remove"]) {
        // 删除好友
        NSLog(@"删除好友成功");
        if (self.removeFriendBlock) {
            self.removeFriendBlock(YES, nil);
        }
    }  
}

//删除好友
-(void)removeUserWithJID:(XMPPJID*)jid CompleteBlock:(void (^)(BOOL isSuccess,NSString* errorMsg))removeUserBlock{

    self.removeFriendBlock=removeUserBlock;
     [[XMPPManager shareManager].xmppRoster removeUser:jid];
}

/* 已经互为好友以后，会回调此*/
- (void)xmppRoster:(XMPPRoster *)sender didReceiveRosterItem:(NSXMLElement *)item {
    
    NSString *subscription = [item attributeStringValueForName:@"subscription"];
    if ([subscription isEqualToString:@"both"]) {
        NSLog(@"双方已经互为好友");
    }  
}


/*退出登录*/
-(void)logout{
    //表示离线不可用
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    //向服务器发送离线消息
    [self.xmppStream sendElement:presence];
    //断开链接
    [self.xmppStream disconnect];
    
}

@end
