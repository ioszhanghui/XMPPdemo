//
//  ZHChatViewController.m
//  XMPPdemo
//
//  Created by 小飞鸟 on 2017/6/20.
//  Copyright © 2017年 正和普惠. All rights reserved.
//

#import "ZHChatViewController.h"
#import "ZHMessageCell.h"
#import "ZHToolView.h"

static NSString * identify =@"Message";

@interface ZHChatViewController ()<UITableViewDelegate,UITableViewDataSource>

//工具栏
@property (nonatomic,strong) ZHToolView *toolView;

@property (assign, nonatomic) CGRect keyEndFrame;

@end

@implementation ZHChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    [self configUI];
    
    [self addMySubView];

    
    //获取通知中心
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyBoardShowChanged:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyBoardHiddenChanged:) name:UIKeyboardWillHideNotification object:nil];

}

-(void) addMySubView
{
    //工具栏
    _toolView = [[ZHToolView alloc] initWithFrame:CGRectMake(0, kWindowHeight-50, kWindowWidth, 50)];
    [self.view addSubview:_toolView];
    
}

//键盘出来的时候调整tooView的位置
#pragma mark 键盘隐藏
-(void)keyBoardShowChanged:(NSNotification*)aNotification{
    
    CGRect frame = CGRectMake(0, kWindowHeight-50, kWindowWidth, 50);
    
    int offset;//iPhone键盘高度216，iPad的为352
    
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    
    [UIView setAnimationDuration:0.3f];
    
    
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    int height = keyboardRect.size.height;
    
    if ([[[self textInputMode] primaryLanguage]  isEqualToString:@"en-US"]) {
        NSLog(@"en-US");
        
        offset = frame.origin.y- (height);//iPhone键盘高度216，iPad的为352
    }
    else
    {
        offset = frame.origin.y- (height);//iPhone键盘高度216，iPad的为352
        NSLog(@"zh-hans");
    }
    
    //将视图的Y坐标向上移动offset个单位，以使下面腾出地方用于软键盘的显示
    
    if(offset > 0)
    
    self.toolView.frame = CGRectMake(0.0f, offset, self.view.frame.size.width, 50);
    
    self.keyEndFrame=self.toolView.frame;
    
    self.tableView.frame=CGRectMake(0, 64, kWindowWidth, kWindowHeight-64-50-height);
    [UIView commitAnimations];
    
}


//键盘出来的时候调整tooView的位置
#pragma mark 键盘隐藏
-(void)keyBoardHiddenChanged:(NSNotification*)aNotification{
    
    [UIView animateWithDuration:0.3 animations:^{
        
        self.toolView.y=kWindowHeight-50;
        self.tableView.height=kWindowHeight-64-50;
    }];
    
}


#pragma mark 布局UI
-(void)configUI{
    
    self.tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, kWindowWidth, kWindowHeight-50) style:UITableViewStyleGrouped];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    self.tableView.showsVerticalScrollIndicator= NO;
    self.tableView.showsHorizontalScrollIndicator=NO;
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];

}

#pragma mark tableView代理方法
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    return self.messageArr.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    NSArray * mesgArr=self.messageArr[section];
    
    return mesgArr.count;

}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    ZHMessageCell * cell =[ZHMessageCell dequeueReusableCellWithIdentifier:identify TableView:tableView];
    
    return cell;
}



@end
