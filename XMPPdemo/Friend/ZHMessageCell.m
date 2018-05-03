//
//  ZHMessageCell.m
//  XMPPdemo
//
//  Created by 小飞鸟 on 2017/6/20.
//  Copyright © 2017年 正和普惠. All rights reserved.
//

#import "ZHMessageCell.h"

@implementation ZHMessageCell
/*创建Cell*/
+(ZHMessageCell*)dequeueReusableCellWithIdentifier:(NSString*)identifier TableView:(UITableView*)tableView{

    ZHMessageCell * cell =[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell==nil) {
        
        cell=[[ZHMessageCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    
    return cell;
}

@end
