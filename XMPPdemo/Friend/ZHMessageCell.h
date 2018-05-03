//
//  ZHMessageCell.h
//  XMPPdemo
//
//  Created by 小飞鸟 on 2017/6/20.
//  Copyright © 2017年 正和普惠. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZHMessageModel;

@interface ZHMessageCell : UITableViewCell

/*聊天内容的数据*/
@property(nonatomic,strong)ZHMessageModel * messageModel;

/*创建Cell*/
+(ZHMessageCell*)dequeueReusableCellWithIdentifier:(NSString*)identifier TableView:(UITableView*)tableView;

@end
