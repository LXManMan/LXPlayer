# LXPlayer

截屏：
![image](https://github.com/liuxinixn/LXPlayer/blob/master/%E8%87%AA%E5%AE%9A%E4%B9%89%E8%A7%86%E9%A2%91%E6%92%AD%E6%94%BE%E5%99%A8.gif)


使用方法：示例
```
  LXPlayModel *model =[[LXPlayModel alloc]init];
    model.playUrl = @"http://wvideo.spriteapp.cn/video/2016/0328/56f8ec01d9bfe_wpd.mp4";
    model.videoTitle = @"蝙蝠侠大战大灰狼";
    model.fatherView = self.playFatherView;
    self.playerview =[[LXAVPlayView alloc]init];
                      
    self.playerview.isLandScape = YES;
    
    self.playerview.isAutoReplay = NO;
                      
    self.playerview.currentModel = model;
    self.navigationItem.leftBarButtonItem =[[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
    
    
       LXWS(weakSelf);
    self.playerview.backBlock = ^{
        
        [weakSelf.navigationController popViewControllerAnimated:YES];
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
-(void)backAction{
    
  
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self.playerview destroyPlayer];
}
-(BOOL)shouldAutorotate{
    return YES;
}
// 支持哪些屏幕方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault; // your own style
}
  ```

经测试，iOS11.2.2 在全屏切换的时候过渡动画混乱，iOS10.3没有问题，是系统的API有问题，只要屏幕发生了旋转，就会出现过渡动画的混乱问题。
介绍：[iOS 基于AVPlayer封装的播放器，全屏切换，切换播放源](https://www.jianshu.com/p/84abeb68fb62)

博客会同步到我的个人博客：[http://iphone20.top/](http://iphone20.top/)

推荐一个技术博客：[https://4xx.me/](https://4xx.me/)
