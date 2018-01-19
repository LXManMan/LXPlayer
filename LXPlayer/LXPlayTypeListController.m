//
//  LXPlayTypeListController.m
//  LXPlayer
//
//  Created by chenergou on 2018/1/18.
//  Copyright © 2018年 漫漫. All rights reserved.
//

#import "LXPlayTypeListController.h"
#import "LXPlayVerticalController.h"
#import "LXPushNotSupportRotateController.h"
#import "LXPresentSupportController.h"
#import "LXPresentNotSupportController.h"

@interface LXPlayTypeListController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)UITableView *tableview;
@property(nonatomic,strong)NSArray *dataA;
@end

@implementation LXPlayTypeListController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = @"自定义视屏播放器";
    
        [self setUp];
}


-(void)setUp{
    [self.view addSubview:self.tableview];
    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataA.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (!cell) {
        cell =[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = self.dataA[indexPath.row];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row ==0) {
        LXPlayVerticalController *changeVc =[[LXPlayVerticalController alloc]init];
        [self.navigationController pushViewController:changeVc animated:YES];
    }
    
    if (indexPath.row ==1) {
        LXPushNotSupportRotateController *changeVc =[[LXPushNotSupportRotateController alloc]init];
        [self.navigationController pushViewController:changeVc animated:YES];
    }
    
    if (indexPath.row ==2) {
        LXPresentSupportController *changeVc =[[LXPresentSupportController alloc]init];
        [self.navigationController presentViewController:changeVc animated:YES completion:nil];
    }
    if (indexPath.row ==3) {
        LXPresentNotSupportController *changeVc =[[LXPresentNotSupportController alloc]init];
        [self.navigationController presentViewController:changeVc animated:YES completion:nil];

    }
}
-(UITableView *)tableview{
    
    if (!_tableview) {
        _tableview =[[UITableView alloc]initWithFrame:CGRectMake(0, NAVH, Device_Width, Device_Height - NAVH) style:UITableViewStylePlain];
        _tableview.delegate = self;
        _tableview.dataSource = self;
        _tableview.showsVerticalScrollIndicator = NO;
        _tableview.showsHorizontalScrollIndicator = NO;
        _tableview.tableFooterView = [UIView new];
        
        [_tableview registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
        
    }
    return _tableview;
}
-(NSArray *)dataA{
    if (!_dataA) {
        _dataA =@[@"push支持多个方向",@"push不支持多个方向",@"present支持多个方向",@"presentbu不支持多个方向"];
    }
    return _dataA;
}

@end
