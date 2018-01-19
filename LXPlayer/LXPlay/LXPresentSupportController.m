//
//  LXPresentSupportController.m
//  LXPlayer
//
//  Created by chenergou on 2018/1/18.
//  Copyright © 2018年 漫漫. All rights reserved.
//

#import "LXPresentSupportController.h"

@interface LXPresentSupportController ()
@property(nonatomic,strong)LXAVPlayView *playerview;

@property(nonatomic,strong)UIView *playFatherView;
@end

@implementation LXPresentSupportController

-(void)dealloc{
    NSLog(@"%@销毁了",self.class);
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"push支持多个方向";
    self.view.backgroundColor =[UIColor whiteColor];
    
    CGRect rect = CGRectMake(0, 0, Device_Width, 300);
    
    self.playFatherView =[[UIView alloc]initWithFrame:rect];
    
    [self.view addSubview:self.playFatherView];
    
    
    //http://vip.okokbo.com/20180117/BNp2mT7Q/index.m3u8
    //
    LXPlayModel *model =[[LXPlayModel alloc]init];
    model.playUrl = @"http://wvideo.spriteapp.cn/video/2016/0328/56f8ec01d9bfe_wpd.mp4";
    model.videoTitle = @"蝙蝠侠大战大灰狼";
    model.fatherView = self.playFatherView;
    self.playerview =[[LXAVPlayView alloc]init];
    
    self.playerview.isLandScape = YES;
    
    self.playerview.isAutoReplay = NO;
    
    self.playerview.currentModel = model;
   
    
    
    LXWS(weakSelf);
    self.playerview.backBlock = ^{
        
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    };
    
    LxButton *nextBtn =[LxButton LXButtonWithTitle:@"下一集" titleFont:Font(15) Image:nil backgroundImage:nil backgroundColor:[UIColor redColor] titleColor:[UIColor whiteColor] frame:CGRectMake(0, Device_Height -40, 120, 40)];
    [self.view addSubview:nextBtn];
    
    [nextBtn addClickBlock:^(UIButton *button) {
        
        LXPlayModel *model =[[LXPlayModel alloc]init];
        model.playUrl = @"http://wvideo.spriteapp.cn/video/2016/0709/5781023a979d7_wpd.mp4";
        model.videoTitle = @"陈二狗的妖孽人生";
        model.fatherView = weakSelf.playFatherView;
        weakSelf.playerview.currentModel = model;
    }];
    
    
    LxButton *nextBtn2 =[LxButton LXButtonWithTitle:@"上一集" titleFont:Font(15) Image:nil backgroundImage:nil backgroundColor:[UIColor redColor] titleColor:[UIColor whiteColor] frame:CGRectMake(Device_Width -120, Device_Height -40, 120, 40)];
    [self.view addSubview:nextBtn2];
    //http://vip.okokbo.com/20180117/BNp2mT7Q/index.m3u8
    //http://down.4xx.me/test.mp4
    [nextBtn2 addClickBlock:^(UIButton *button) {
        
        LXPlayModel *model =[[LXPlayModel alloc]init];
        model.playUrl = @"http://vip.okokbo.com/20180117/BNp2mT7Q/index.m3u8";
        model.videoTitle = @"寻梦环游记";
        model.fatherView = weakSelf.playFatherView;
        weakSelf.playerview.currentModel = model;
    }];
    
}

#pragma mark -- 需要设置全局支持旋转方向，然后重写下面三个方法可以让当前页面支持多个方向
// 是否支持自动转屏
- (BOOL)shouldAutorotate {
    return YES;
}
// 支持哪些屏幕方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}
// 默认的屏幕方向（当前ViewController必须是通过模态出来的UIViewController（模态带导航的无效）方式展现出来的，才会调用这个方法）
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self.playerview destroyPlayer];
}


@end
