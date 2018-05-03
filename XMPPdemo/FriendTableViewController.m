//
//  FriendTableViewController.m
//  XMPPdemo
//
//  Created by zhph on 2017/6/14.
//  Copyright © 2017年 正和普惠. All rights reserved.
//

#import "FriendTableViewController.h"
#import "XMPPManager.h"
#import "ZHChatViewController.h"
#import "FriendModel.h"

@interface FriendTableViewController ()<XMPPRosterDelegate,UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)UITableView * tableView;

@property(nonatomic,strong)NSMutableArray * chatPersonArr;

//添加的用户名
@property(nonatomic,copy)NSString * userName;
//添加的用户名分组
@property(nonatomic,copy)NSString * userGroup;

@end

NSFetchedResultsController *fetchedGroupResultsController;

@implementation FriendTableViewController{

/*分组的箭头*/
    UIImageView * arrowImageView;
    
    /*自己的头像*/
    UIButton *btn;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.chatPersonArr=[NSMutableArray array];
    
    self.tableView=[[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    [self.view addSubview:self.tableView];
    
    
//    self.title=[XMPPManager shareManager].xmppStream.myJID.user;
    self.title=@"好友";

    [[XMPPManager shareManager].xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
   self.navigationItem.rightBarButtonItem=[self createRigthBarItem];
    self.navigationItem.leftBarButtonItem=[self createLeftBarItem];


    [self getFriends];

    [self getGroupFriend];
    
}


#pragma mark 创建保存按钮
-(UIBarButtonItem*)createRigthBarItem{
    
    UIButton * addbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addbtn.frame=CGRectMake(0, 0, 45, 45);
    [addbtn setTitle:@"添加" forState:UIControlStateNormal];
    [addbtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    addbtn.titleLabel.font=[UIFont systemFontOfSize:16];
    [addbtn setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.7] forState:UIControlStateHighlighted];
    [addbtn addTarget:self action:@selector(rightSave) forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc]initWithCustomView:addbtn];
    
}


#pragma mark 创建保存按钮
-(UIBarButtonItem*)createLeftBarItem{
    
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame=CGRectMake(0, 0, 30, 30);
    btn.layer.cornerRadius=15;
    btn.layer.borderWidth=0.8;
    btn.layer.borderColor=[UIColor colorWithRed:86/255.0 green:86/255.0 blue:86/255.0 alpha:1.0].CGColor;
    [btn setImage:[UIImage imageNamed:@"003"] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.7] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(leftSave) forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc]initWithCustomView:btn];
}

-(void)leftSave{

    [[XMPPManager shareManager]uploadUserIconWithImage:[UIImage imageNamed:@"005"] NickName:@"user" CallBlock:^(UIImage *image) {
        
        [btn setImage:image forState:UIControlStateNormal];
    }];

}

-(void)rightSave{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"添加好友" message:@"你的操作时非法的，您要继续吗" preferredStyle:UIAlertControllerStyleAlert];
    // 添加文本框
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.textColor = [UIColor redColor];
        textField.placeholder=@"用户名";
         [textField addTarget:self action:@selector(usernameDidChange:) forControlEvents:UIControlEventEditingChanged];
        
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.textColor = [UIColor redColor];
        textField.placeholder=@"用户分组";
        [textField addTarget:self action:@selector(groupDidChange:) forControlEvents:UIControlEventEditingChanged];
        
    }];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        //确添加
//        
        XMPPJID * JID =[XMPPJID jidWithUser:self.userName domain:KDomin resource:Kresource];
        
        //添加好友 没有分组
//        [[XMPPManager shareManager].xmppRoster addUser:JID withNickname:@"张辉"];
        
        //添加好友到分组
        [[XMPPManager shareManager].xmppRoster addUser:JID withNickname:@"张辉" groups:@[@"好友"]];
        
//        [[XMPPManager shareManager] addFriendWithUserName:self.userName CompleteBlock:^(BOOL isSuccess, NSString *errorMsg) {
//            
//        }];
        
       
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        NSLog(@"点击了取消按钮");
        
    }]];
    
     [self presentViewController:alert animated:YES completion:nil];

}

- (void)usernameDidChange:(UITextField *)username{
    
    self.userName=username.text;
    
    NSLog(@"%@", username.text);
}

-(void)groupDidChange:(UITextField *)textField{
    self.userGroup=textField.text;
    
    NSLog(@"%@", textField.text);
    
}

/*开始检索好友*/
-(void)xmppRosterDidBeginPopulating:(XMPPRoster *)sender withVersion:(NSString *)version{

    NSLog(@"%s开始检索好友",__func__);

}

/*开始检索好友*/
-(void)xmppRosterDidEndPopulating:(XMPPRoster *)sender withVersion:(NSString *)version{
    
    NSLog(@"%s结束检索好友",__func__);
    
}

/*检索到好友*/
-(void)xmppRoster:(XMPPRoster *)sender didReceiveRosterItem:(DDXMLElement *)item{

    [self.chatPersonArr removeAllObjects];
    
    [self getGroupFriend];
//    NSLog(@"检索到好友***%@",item);
//    //获取jid字符串
//    NSString * jid =[[item attributeForName:@"jid"] stringValue];
//    //创建JID对象
//    XMPPJID * JID=[XMPPJID jidWithString:jid];
//    
//    FriendModel * model =[[FriendModel alloc]init];
//    
////    model.jid=JID;
////    model.displayName=[[item attributeForName:@"name"] stringValue];
////    model.sectionName=[[item attributeForName:@"group"] stringValue];
//
//    if (self.chatPersonArr) {
//        
//        [self.chatPersonArr addObject:model];
//    }

}


-(void)getGroupFriend{

    NSManagedObjectContext *moc = [XMPPManager shareManager].rosterContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPGroupCoreDataStorageObject"
                                              inManagedObjectContext:moc];
    
    NSString *sectionKey = @"name";
    NSSortDescriptor *sortDesc = [[NSSortDescriptor alloc] initWithKey:sectionKey ascending:YES];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name != %@", @"name"];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setSortDescriptors:@[sortDesc]];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *matches = [moc executeFetchRequest:fetchRequest error:&error];
    
    
    for(XMPPGroupCoreDataStorageObject * item in matches){
    
        NSLog(@"%@",item.name);
        NSLog(@"%@",item.users);
        
        //存放分组的所有的用户
        NSMutableArray * usersArr=[NSMutableArray array];
        FriendModel * model =[[FriendModel alloc]init];
        model.isOpen=NO;
        model.sectionName=item.name;
        
        //输出所有好友的名字
        for (XMPPUserCoreDataStorageObject * item1 in item.users) {
            
            User * user =[[User alloc]init];
            user.displayName=item1.displayName;
            user.nickname=item1.nickname;
            user.sectionName=item1.sectionName;
            user.jid=item1.jid;
            user.photo=item1.photo;
            user.presence=item1.primaryResource.presence;
            [usersArr addObject:user];
        }

        model.userArr=usersArr;
        
        [self.chatPersonArr addObject:model];
        
        }
    
    [self.tableView reloadData];
        
}


//查询好友的方法
-(void)getFriends{
    

    //查询预备工作，context request，entity
    NSManagedObjectContext *context = [XMPPManager shareManager].rosterContext;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPUserCoreDataStorageObject"
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    //查询条件
    //筛选本用户的好友
    NSString *userinfo = [NSString stringWithFormat:@"%@@127.0.0.1",[XMPPManager shareManager].userName];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@",userinfo];
    [fetchRequest setPredicate:predicate];
    //排序
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"displayName"ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSError *error = nil;
    //执行查询获得结果
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
//    //输出所有好友的名字
//    for (XMPPUserCoreDataStorageObject *item in fetchedObjects) {
//        
//        FriendModel * model =[[FriendModel alloc]init];
//        model.displayName=item.displayName;
//        model.nickname=item.nickname;
//        model.sectionName=item.sectionName;
//        model.jid=item.jid;
//        model.presence=item.primaryResource.presence;
//        NSLog(@"%@",item.primaryResource);
//        
//        [self.chatPersonArr addObject:model];
//    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return self.chatPersonArr.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    FriendModel * model =[self.chatPersonArr objectAtIndex:section];
    return model.isOpen? model.userArr.count:0;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chat"];
    if (cell==nil) {
        
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"chat"];
    }
     FriendModel * model =[self.chatPersonArr objectAtIndex:indexPath.section];
    
    User * user =[model.userArr objectAtIndex:indexPath.row];
    
    cell.textLabel.text=user.jid.user;
    cell.imageView.image=user.photo? user.photo:[UIImage imageNamed:@"005"];
    cell.detailTextLabel.text=@"个性签名";
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 45;
    
   
}


-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
     FriendModel * model =[self.chatPersonArr objectAtIndex:section];
    
    return [self sectionHeaderViewWithTitle:model Section:section];

}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{

    return 45;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{

    return 0.01;
}


-(UIView*)sectionHeaderViewWithTitle:(FriendModel*)model Section:(NSInteger)section{

    UIView * headerView =[[UIView alloc]initWithFrame:CGRectMake(0, 0, kWindowWidth, 45)];
    headerView.backgroundColor=[UIColor whiteColor];
    
    arrowImageView =[[UIImageView alloc]initWithFrame:CGRectMake(10,16 , 7, 11)];
    
    if (model.isOpen) {
        
        arrowImageView.image=[UIImage imageNamed:@"downIcon"];;
    }else{
        
        arrowImageView.image=[UIImage imageNamed:@"rightIcon"];;
    }
    
    arrowImageView.size=arrowImageView.image.size;
    arrowImageView.y=(45-arrowImageView.image.size.height)/2;
    
    [headerView addSubview:arrowImageView];
    
    UILabel * sectionTitle =[[UILabel alloc]initWithFrame:CGRectMake( arrowImageView.right+8, 0, kWindowWidth-10, 45)];
    sectionTitle.text=model.sectionName;
    sectionTitle.textColor=[UIColor blackColor];
    sectionTitle.font=[UIFont systemFontOfSize:16];
    [headerView addSubview:sectionTitle];
    sectionTitle.userInteractionEnabled=YES;
    
    UITapGestureRecognizer * tap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickSectionUser:)];
    sectionTitle.tag=1000+section;
    [sectionTitle addGestureRecognizer:tap];
    
    return headerView;

}

-(void)clickSectionUser:(UITapGestureRecognizer*)tap{

    NSInteger section=tap.view.tag-1000;
    FriendModel * model =[self.chatPersonArr objectAtIndex:section];
    model.isOpen=!model.isOpen;

    [self.tableView reloadData];
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    FriendModel * model =[self.chatPersonArr objectAtIndex:indexPath.section];
    User * user =[model.userArr objectAtIndex:indexPath.row];

    ZHChatViewController * VC =[[ZHChatViewController alloc]init];
    VC.jid=user.jid;
    VC.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:VC animated:YES];
}

#pragma mark 左滑删除
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    // 删除模型
    if (self.chatPersonArr.count>indexPath.row) {
        
        FriendModel * model =[self.chatPersonArr objectAtIndex:indexPath.section];
        User * user =[model.userArr objectAtIndex:indexPath.row];
        
        [[XMPPManager shareManager]removeUserWithJID:user.jid CompleteBlock:^(BOOL isSuccess, NSString *errorMsg) {
            if (isSuccess) {
                NSLog(@"删除好友成功！！！！");
                
                [self.chatPersonArr removeObjectAtIndex:indexPath.row];
                [self.tableView reloadData];
            }
            
        }];
    }
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return  YES;
}

/**
 *  修改Delete按钮文字为“删除”
 */
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return  @"删除";
    
}

@end
