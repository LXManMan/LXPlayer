# LXPlayer

截屏：
![image](https://github.com/liuxinixn/LXPlayer/blob/master/IMG_6790.PNG)
![image](https://github.com/liuxinixn/LXPlayer/blob/master/IMG_6791 2.PNG)
![image](https://github.com/liuxinixn/LXPlayer/blob/master/IMG_6792.PNG)

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
