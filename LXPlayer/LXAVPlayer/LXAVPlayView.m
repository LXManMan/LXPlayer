
//
//  LXAVPlayView.m
//  LXPlayer
//
//  Created by chenergou on 2017/12/4.
//  Copyright © 2017年 漫漫. All rights reserved.
//

#import "LXAVPlayView.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "LXAVPlayControllView.h"
@interface LXAVPlayView()<UIGestureRecognizerDelegate>
// 播放器的几种状态
typedef NS_ENUM(NSInteger, LXPlayerState) {
    LXPlayerStateFailed,     // 播放失败
    LXPlayerStateBuffering,  // 缓冲中
    LXPlayerStatePlaying,    // 播放中
    LXPlayerStateStopped,    // 停止播放
    LXPlayerStatePause,       // 暂停播放
    LXPlayerStateEnd         // 播放完成
};

// 枚举值，包含水平移动方向和垂直移动方向
typedef NS_ENUM(NSInteger, PanDirection){
    PanDirectionHorizontalMoved, // 横向移动
    PanDirectionVerticalMoved    // 纵向移动
};
/*播放器*/
@property(nonatomic,strong)AVPlayer *player;
/**playerLayer*/
@property (nonatomic, strong) AVPlayerLayer     *playerLayer;

/**播放器item*/
@property (nonatomic, strong) AVPlayerItem      *playerItem;



@property(nonatomic,strong)LXAVPlayControllView *contollView;//控制层+

@property(nonatomic,assign)LXPlayerState         playState;//播放状态

@property(nonatomic,strong)UITapGestureRecognizer         *singleTap;//单击

@property(nonatomic,strong)UITapGestureRecognizer         *doubleTap;//双点击


@property (nonatomic, assign) NSInteger                seekTime;/** 从xx秒开始播放视频 */

@property(nonatomic,assign)   CGFloat sumTime;
@property (nonatomic, strong) id           timeObserve;//定时观察者

@property(nonatomic,assign)BOOL            isDragged;//slider上有手势在作用

@property(nonatomic,assign)BOOL            isVolume;//音量调节

@property(nonatomic,assign)BOOL            isFullScreen;//是否是全屏

@property(nonatomic,assign)BOOL            isEnd;//播放结束

@property(nonatomic,assign)BOOL            isFullScreenByUser;//用户全屏

@property(nonatomic,strong)UIPanGestureRecognizer *panRecognizer; //平移手势
@property (nonatomic, strong) UISlider      *volumeViewSlider;/** 滑杆 */

@property(nonatomic,strong)UIView *statusBar;//statusBar;

@property (nonatomic, assign) PanDirection  panDirection;/** 定义一个实例变量，保存枚举值 */

@property(nonatomic,assign)UIInterfaceOrientation currentOrientation;//当前的方向；

@property(nonatomic,assign)UIInterfaceOrientation beforeEnterBackgoundOrientation;//进入后台之前的方向

@end
@implementation LXAVPlayView
-(void)destroyPlayer{
    
    [self pause];
    [self removeObserver];
    [self removeNsnotification];
    
    //回到竖屏
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationPortrait] forKey:@"orientation"];
    //重置状态条
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
    //恢复默认状态栏显示与否
    self.statusBar.hidden = self.isFullScreen;
    
    [self cancelHideSelector];
    
    [self.playerLayer removeFromSuperlayer];
    [self removeFromSuperview];
    
    self.playerLayer = nil;
    self.player = nil;
    self.contollView = nil;
}
-(void)dealloc{
    NSLog(@"%@销毁了",self.class);
    
}
#pragma mark---移除通知----
-(void)removeNsnotification{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillResignActiveNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIDeviceOrientationDidChangeNotification
                                                  object:nil];
}
#pragma mark---移除观察者--
-(void)removeObserver{
    [self.playerItem removeObserver:self forKeyPath:@"status"];
    [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [self.playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];

    [self.playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
    if (self.timeObserve) {
        self.timeObserve = nil;
    }
}

#pragma mark---初始化---
-(instancetype)init{
    self  = [super init];
    
    if (self) {
     
        //控件
        [self setUp];
        
        // 获取系统音量
        [self configureVolume];
        //添加手势
        [self createGestures];
        
        
        //开启
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        
        //注册屏幕旋转通知
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(orientChange:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:[UIDevice currentDevice]];
        //APP运行状态通知，将要被挂起
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(appDidEnterBackground:)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
        // app进入前台
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(appDidEnterPlayground:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
    }
    return self;
}

-(void)setCurrentModel:(LXPlayModel *)currentModel{
    _currentModel = currentModel;
    
    self.contollView.playTitle = _currentModel.videoTitle;
    
    [self addPlayerToFatherView:_currentModel.fatherView];
    
    //播放前准备
    [self readyToPlay];
}


#pragma mark---播放前的准备--
-(void)readyToPlay{
    
    self.backgroundColor = [UIColor blackColor];

    self.playerItem =[AVPlayerItem playerItemWithAsset:[AVAsset assetWithURL:[NSURL URLWithString:self.currentModel.playUrl]]];
    
    [self.contollView showLoadingAnimation:YES];
    
    
}
-(void)setPlayerItem:(AVPlayerItem *)playerItem{
    
    if (_playerItem) {
        //移除观察者
        [self removeObserver];
        
        //重置播放器
        [self resetPlayer];
        
        self.panRecognizer.enabled = NO;
    }
    _playerItem = playerItem;
    
    self.player =[AVPlayer playerWithPlayerItem:_playerItem];
    
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    
    self.playerLayer.videoGravity =  AVLayerVideoGravityResizeAspect;
    
    
    //设置静音模式播放声音
    //      AVAudioSession * session  = [AVAudioSession sharedInstance];
    //    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    //    [session setActive:YES error:nil];
    
    
    [self addNotificationAndObserver];
    
    
}
#pragma mark--重置播放器---
-(void)resetPlayer{
    
    self.playState = LXPlayerStateStopped;
    
    self.isEnd = NO;
    
    
    [self.playerLayer removeFromSuperlayer];
    
    self.player = nil;
    
    [self.contollView resetPlayState];
    
    [self recoveryHideSelector];
}
#pragma mark---添加观察者，通知---
- (void)addNotificationAndObserver{
    
    if (self.playerItem) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
        [_playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        [_playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
        // 缓冲区空了，需要等待数据
        [_playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
        // 缓冲区有足够数据可以播放了
        [_playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
        
        __weak typeof(self) weakSelf = self;
        
        //添加系统吗观察者，观察播放进度
        self.timeObserve = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, 1) queue:nil usingBlock:^(CMTime time){
            AVPlayerItem *currentItem = weakSelf.playerItem;
            NSArray *loadedRanges = currentItem.seekableTimeRanges;
            if (loadedRanges.count > 0 && currentItem.duration.timescale != 0) {
                NSInteger currentTime = (NSInteger)CMTimeGetSeconds([currentItem currentTime]);
                CGFloat totalTime     = (CGFloat)currentItem.duration.value / currentItem.duration.timescale;
                CGFloat value         = CMTimeGetSeconds([currentItem currentTime]) / totalTime;
                
                if (!weakSelf.isDragged) {
                
                    weakSelf.contollView.startTime =[LXAVPlayView durationStringWithTime:(NSInteger)currentTime];
                    weakSelf.contollView.endTime =[LXAVPlayView durationStringWithTime:(NSInteger)totalTime];
                    //设置播放进度
                    weakSelf.contollView.slideValue = value;

                
                }
            }
        }];
        
    }
    
}

#pragma mark---KVO ---
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    if (object == _playerItem) {
        
        if ([keyPath isEqualToString:@"status"]) {
            
            if (_playerItem.status == AVPlayerItemStatusReadyToPlay){
                
                [self setNeedsLayout];
                [self layoutIfNeeded];
                [self.layer insertSublayer:self.playerLayer atIndex:0];
                
                self.playState = LXPlayerStatePlaying;
                
                // 加载完成后，再添加平移手势
                // 添加平移手势，用来控制音量、亮度、快进快退
                self.panRecognizer.enabled = YES;
                
            }
        }
        if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
            
            // 计算缓冲进度
            NSTimeInterval timeInterval = [self availableDuration];
            CMTime duration             = self.playerItem.duration;
            CGFloat totalDuration       = CMTimeGetSeconds(duration);
            if (isnan(timeInterval)) {
                timeInterval = 0;
            }
            if (totalDuration) {
                self.contollView.cacheValue  =  timeInterval / totalDuration;
            }
            
            
        }
        if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
            
            // 当缓冲是空的时候
            if (self.playerItem.playbackBufferEmpty) {
                [self bufferingSomeSecond];
            }

        }
        if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
            
            // 当缓冲好的时候
            
            if (self.playerItem.playbackLikelyToKeepUp && self.playState == LXPlayerStateBuffering){
                self.playState = LXPlayerStatePlaying;
            }
            
        }
    }
}
#pragma mark--手势种种--
-(void)createGestures{
    
    [self addGestureRecognizer:self.singleTap];
    
    [self addGestureRecognizer:self.doubleTap];
    
    // 解决点击当前view时候响应其他控件事件
    [self.singleTap setDelaysTouchesBegan:YES];
    [self.doubleTap setDelaysTouchesBegan:YES];
    // 双击失败响应单击事件
    [self.singleTap requireGestureRecognizerToFail:self.doubleTap];
    
    
    [self performSelector:@selector(hideControllView) withObject:nil afterDelay:3];
}


-(void)setPlayState:(LXPlayerState)playState{
    
    _playState = playState;
    
    if (_playState == LXPlayerStatePlaying) {
        [self play];
        [self.contollView showLoadingAnimation:NO];
        
    }else if(_playState == LXPlayerStateBuffering){
        [self.contollView showLoadingAnimation:YES];
        
    }else{
        [self.contollView showLoadingAnimation:NO];
        [self pause];
    }
    
}
#pragma mark ----添加通知----
-(void)moviePlayDidEnd:(NSNotification *)noti{
    
    self.isEnd = YES;
    
    //如果需要重播这里需要添加判断
    
    [self pause];
    
    if (self.isAutoReplay) {
        
        [self resetPlay];
        
        
    }else{
        [self.contollView showPlayEnd]; //播放结束
    }
    
}

#pragma mark - APP活动通知
- (void)appDidEnterBackground:(NSNotification *)note{
    
    //将要挂起，停止播放
    [self pause];
   
}
- (void)appDidEnterPlayground:(NSNotification *)note{
    //继续播放
   
   

    
    [self play];
    
    
}
#pragma mark---私有方法---

#pragma mark - 重新开始播放
- (void)resetPlay{
    _isEnd = NO;
    
    
    [self seekToTime:0 completionHandler:nil];
}
/**
 *  player添加到fatherView上
 */
- (void)addPlayerToFatherView:(UIView *)view {
    // 这里应该添加判断，因为view有可能为空，当view为空时[view addSubview:self]会crash
    if (view) {
        [self removeFromSuperview];
        [view addSubview:self];
        [self mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_offset(UIEdgeInsetsZero);
        }];
    }
}
/**
 *  获取系统音量
 */
- (void)configureVolume {
    MPVolumeView *volumeView = [[MPVolumeView alloc] init];
    _volumeViewSlider = nil;
    for (UIView *view in [volumeView subviews]){
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            _volumeViewSlider = (UISlider *)view;
            break;
        }
    }
    
    // 使用这个category的应用不会随着手机静音键打开而静音，可在手机静音下播放声音
    NSError *setCategoryError = nil;
    BOOL success = [[AVAudioSession sharedInstance]
                    setCategory: AVAudioSessionCategoryPlayback
                    error: &setCategoryError];
    
    if (!success) { /* handle the error in setCategoryError */ }
    
}

#pragma mark--隐藏控制层--
-(void)hideControllView{
    
    [self.contollView hidIsAnimated:YES];
    
}
#pragma mark--恢复定时器--
-(void)recoveryHideSelector{
    [self performSelector:@selector(hideControllView) withObject:nil afterDelay:5];
}
#pragma mark---取消定时器
-(void)cancelHideSelector{
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControllView) object:nil];
}
#pragma mark--控件---
-(void)setUp{
    
    [self addSubview:self.contollView];
    
    
    [self.contollView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.edges.mas_equalTo(UIEdgeInsetsZero);
        
    }];
    
    //播放回调
    LXWS(weakSelf);
    self.contollView.playCallBack = ^(BOOL isPlay) {
        
        if (isPlay) {
            [weakSelf play];
        }else{
            [weakSelf pause];
        }
    };
    
    //slide平移手势的回调
    
    self.contollView.panBegin = ^{
        
        weakSelf.isDragged = YES;
        if (!weakSelf.contollView) {
            weakSelf.contollView.isShow = YES;
        }
        [weakSelf cancelHideSelector];
        
    };
    
    self.contollView.getSlideValue = ^(CGFloat value) {
        
        // 当前frame宽度 * 总时长 / 总frame长度 = 当前时间
        CGFloat duration = CMTimeGetSeconds([weakSelf.player.currentItem duration]);
        int time = duration * value;
        // 更新时间
        weakSelf.contollView.startTime = [LXAVPlayView durationStringWithTime:(NSInteger) time];
    };
    
    
    self.contollView.panEnd = ^(CGFloat value) {
        CGFloat duration = CMTimeGetSeconds([weakSelf.player.currentItem duration]);
        int time = duration * value;
        
        weakSelf.isDragged = YES;
        [weakSelf seekToTime:time completionHandler:nil];
    };
    
    
    self.contollView.tapSlider = ^(CGFloat value) {
        // 当前frame宽度 * 总时长 / 总frame长度 = 当前时间
        weakSelf.isDragged = YES;
        CGFloat duration = CMTimeGetSeconds([weakSelf.player.currentItem duration]);
        int time = duration * value;
        // 更新时间
        weakSelf.contollView.startTime = [LXAVPlayView durationStringWithTime:(NSInteger) time];
        [weakSelf seekToTime:time completionHandler:nil];
    };
    
    self.contollView.fullScreenBlock = ^(BOOL isFullScreen) {
        weakSelf.isFullScreen = isFullScreen;
        
         weakSelf.isFullScreenByUser = YES;
        [weakSelf _fullScreenAction];
        
        weakSelf.isFullScreenByUser = NO;
    };
    
    self.contollView.backBlock = ^{
        
        if (weakSelf.isFullScreen) {
            weakSelf.isFullScreenByUser = YES;

            [weakSelf interfaceOrientation:UIInterfaceOrientationPortrait];
            
           
             weakSelf.isFullScreenByUser = NO;
            weakSelf.contollView.isFullScreen = weakSelf.isFullScreen;
        }else{
            
            
            if (weakSelf.backBlock) {
        
                weakSelf.backBlock();
            }
        }
    };
    
    
    
    self.contollView.replayBlock = ^(BOOL isReplay) {
         [weakSelf resetPlay];
    };
    
    [self addGestureRecognizer:self.panRecognizer];
}

#pragma mark---单击手势--
-(void)singleTap:(UITapGestureRecognizer *)tap{
    
    
    if (self.contollView.isShow) {
        [self.contollView hidIsAnimated:YES];
        
    }else{
        [self.contollView showIsAnimated:YES];
        
    }
    
}
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    
    
    if (touch.view) {
        
        [self cancelHideSelector];
        
        [self recoveryHideSelector];
        
    }
    
    
    return YES;
}
#pragma mark---双击手势--
-(void)doubleTap:(UITapGestureRecognizer *)tap{
    
    //先判断缓存 然后在暂停
    
    
    if (self.playState == LXPlayerStatePause) {
        self.playState = LXPlayerStatePlaying;
    }else{
        self.playState = LXPlayerStatePause;
    }
    
    
}
/** 全屏 */
- (void)_fullScreenAction {
    
   
    if (self.isFullScreen) {
        [self interfaceOrientation:UIInterfaceOrientationPortrait];
        
        
    } else {
        UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
        
        
        if (orientation == UIDeviceOrientationLandscapeRight) {
            [self interfaceOrientation:UIInterfaceOrientationLandscapeLeft];
        } else {
            [self interfaceOrientation:UIInterfaceOrientationLandscapeRight];
        }
        
    }
}
#pragma mark 屏幕转屏相关


- (void)orientChange:(NSNotification *)notification{
    
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
  
    if (orientation == UIDeviceOrientationLandscapeLeft) {
        
        if (self.isLandScape) {
            
            //因为受控制器的影响是反的
            [self setOrientationLandscapeConstraint:UIInterfaceOrientationLandscapeRight];
        }else{
            [self setOrientationLandscapeConstraint:UIInterfaceOrientationLandscapeLeft];
        }


    }else if (orientation == UIDeviceOrientationLandscapeRight){
        
        if (self.isLandScape) {
            [self setOrientationLandscapeConstraint:UIInterfaceOrientationLandscapeLeft];
        }else{
            [self setOrientationLandscapeConstraint:UIInterfaceOrientationLandscapeRight];
        }
        

    }else if (orientation ==UIDeviceOrientationPortrait){
            [self setOrientationPortraitConstraint];
        }
}
/**
 *  屏幕转屏
 *
 *  @param orientation 屏幕方向
 */
- (void)interfaceOrientation:(UIInterfaceOrientation)orientation {
    if (orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationLandscapeLeft) {
        // 设置横屏
        
        [self setOrientationLandscapeConstraint:orientation];

       
    } else if (orientation == UIInterfaceOrientationPortrait) {
        // 设置竖屏
        [self setOrientationPortraitConstraint];
    }
    
    
}
/**
 *  设置竖屏的约束
 */
- (void)setOrientationPortraitConstraint {
    self.isFullScreen = NO;
    [self portraitWithDirection:UIInterfaceOrientationPortrait];
    
}
/**
 *  设置横屏的约束
 */
- (void)setOrientationLandscapeConstraint:(UIInterfaceOrientation)orientation {
    self.isFullScreen = YES;
    [self fullScreenWithDirection:orientation];
    
}

-(void)fullScreenWithDirection:(UIInterfaceOrientation)oriention{
    
    
    if (oriention == self.currentOrientation) {
        return;
    }
    
    //设置是否隐藏
    self.statusBar.hidden = _isFullScreen;
    
    [self removeFromSuperview];
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self];
    
    if (self.isLandScape) {
        
        if (self.isFullScreenByUser) {
             [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationLandscapeRight] forKey:@"orientation"];
        }
        //如果屏幕可以旋转 那么直接设置宽，高 ，不用做动画。
        if (keyWindow.frame.size.width < keyWindow.frame.size.height) {
            
            [self mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(@(Device_Height));
                make.height.equalTo(@(Device_Width));
                make.center.equalTo([UIApplication sharedApplication].keyWindow);
            }];
        }else{
            
            [self mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(@(Device_Width));
                make.height.equalTo(@(Device_Height));
                make.center.equalTo([UIApplication sharedApplication].keyWindow);
            }];
        }
    }else{
        
        if (self.isFullScreenByUser) {
            [UIView animateWithDuration:0.25 animations:^{
                self.transform = CGAffineTransformMakeRotation(M_PI / 2);
            }];
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:NO];
        }else{
            //播放器所在控制器不支持旋转，采用旋转view的方式实现
            if (oriention == UIInterfaceOrientationLandscapeLeft){
                [UIView animateWithDuration:0.25 animations:^{
                    self.transform = CGAffineTransformMakeRotation(M_PI / 2);
                }];
                [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:NO];
            }else if (oriention == UIInterfaceOrientationLandscapeRight) {
                [UIView animateWithDuration:0.25 animations:^{
                    self.transform = CGAffineTransformMakeRotation( - M_PI / 2);
                }];
                [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft animated:NO];
            }
        }
        
        
        [self mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(Device_Width));
            make.height.equalTo(@(Device_Height));
            make.center.equalTo([UIApplication sharedApplication].keyWindow);
        }];
        
    }
    
    
    self.currentOrientation = oriention;
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
}
-(void)portraitWithDirection:(UIInterfaceOrientation)oriention{
    
    
    if (oriention == self.currentOrientation) {
        return;
    }
    if (self.isLandScape) {
        //用户操作的方法
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];
    }else{
        //还原
        [UIView animateWithDuration:0.25 animations:^{
            self.transform = CGAffineTransformMakeRotation(0);
        }];
    }
    //设置是否隐藏
    self.statusBar.hidden = _isFullScreen;
    
    [self removeFromSuperview];
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
    [self addPlayerToFatherView:self.currentModel.fatherView];
    
     self.currentOrientation = oriention;
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

/**
 *  从xx秒开始播放视频跳转
 *
 *  @param dragedSeconds 视频跳转的秒数
 */
- (void)seekToTime:(NSInteger)dragedSeconds completionHandler:(void (^)(BOOL finished))completionHandler
{
    if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
        // seekTime:completionHandler:不能精确定位
        // 如果需要精确定位，可以使用seekToTime:toleranceBefore:toleranceAfter:completionHandler:
        // 转换成CMTime才能给player来控制播放进度
        
        [self pause];
        self.playState = LXPlayerStateBuffering;
        CMTime dragedCMTime = CMTimeMake(dragedSeconds, 1); //kCMTimeZero
        __weak typeof(self) weakSelf = self;
        [self.player seekToTime:dragedCMTime toleranceBefore:CMTimeMake(1,1) toleranceAfter:CMTimeMake(1,1) completionHandler:^(BOOL finished) {
            
            // 视频跳转回调
            if (completionHandler) { completionHandler(finished); }
            
            weakSelf.seekTime = 0;
            
            weakSelf.isDragged = NO;
            
            //            //开始播放
            //            if (!weakSelf.isPauseByUser) {
            //                [weakSelf videoPlay];
            //            }
            [weakSelf play];
            

            [weakSelf recoveryHideSelector];
            if (!weakSelf.playerItem.isPlaybackLikelyToKeepUp ){ weakSelf.playState = LXPlayerStateBuffering;
                
            }else{
                weakSelf.playState = LXPlayerStatePlaying;
            }
            
            weakSelf.sumTime = 0;
            
        }];
    }
}
#pragma mark - 当前时间换算
+ (NSString *)durationStringWithTime:(NSInteger)time
{
    // 获取分
    NSString *m = [NSString stringWithFormat:@"%02ld",(long)(time/60)];
    // 获取秒
    NSString *s = [NSString stringWithFormat:@"%02ld",(long)(time%60)];
    
    return [NSString stringWithFormat:@"%@:%@",m,s];
}
#pragma mark---屏幕的平移手势
-(void)panDirection:(UIPanGestureRecognizer *)pan{
    //根据在view上Pan的位置，确定是调音量还是亮度
    CGPoint locationPoint = [pan locationInView:self];
    
    // 我们要响应水平移动和垂直移动
    // 根据上次和本次移动的位置，算出一个速率的point
    CGPoint veloctyPoint = [pan velocityInView:self];
    
    // 判断是垂直移动还是水平移动
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:{ // 开始移动
            // 使用绝对值来判断移动的方向
            CGFloat x = fabs(veloctyPoint.x);
            CGFloat y = fabs(veloctyPoint.y);
            if (x > y) { // 水平移动
                // 取消隐藏
                self.panDirection = PanDirectionHorizontalMoved;
                // 给sumTime初值
                CMTime time    = self.player.currentTime;
                self.sumTime      = time.value/time.timescale;
            }
            else if (x < y){ // 垂直移动
                self.panDirection = PanDirectionVerticalMoved;
                // 开始滑动的时候,状态改为正在控制音量
                if (locationPoint.x > self.bounds.size.width / 2) {
                    self.isVolume = YES;
                }else { // 状态改为显示亮度调节
                    self.isVolume = NO;
                }
            }
            break;
        }
        case UIGestureRecognizerStateChanged:{ // 正在移动
            switch (self.panDirection) {
                case PanDirectionHorizontalMoved:{
                    [self horizontalMoved:veloctyPoint.x]; // 水平移动的方法只要x方向的值
                    break;
                }
                case PanDirectionVerticalMoved:{
                    [self verticalMoved:veloctyPoint.y]; // 垂直移动方法只要y方向的值
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case UIGestureRecognizerStateEnded:{ // 移动停止
            // 移动结束也需要判断垂直或者平移
            // 比如水平移动结束时，要快进到指定位置，如果这里没有判断，当我们调节音量完之后，会出现屏幕跳动的bug
            switch (self.panDirection) {
                case PanDirectionHorizontalMoved:{
//                    self.isPauseByUser = NO;
                    
                    [self seekToTime:self.sumTime completionHandler:nil];
                    // 把sumTime滞空，不然会越加越多
                    self.sumTime = 0;
                    break;
                }
                case PanDirectionVerticalMoved:{
                    // 垂直移动结束后，把状态改为不再控制音量
                    self.isVolume = NO;
                    break;
                }
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}

/**
 *  pan垂直移动的方法
 *
 *  @param value void
 */
- (void)verticalMoved:(CGFloat)value {
    self.isVolume ? (self.volumeViewSlider.value -= value / 10000) : ([UIScreen mainScreen].brightness -= value / 10000);
}
/**
 *  pan水平移动的方法
 *
 *  @param value void
 */
- (void)horizontalMoved:(CGFloat)value {
    // 每次滑动需要叠加时间
    self.sumTime += value / 150;
    
    // 需要限定sumTime的范围
    CMTime totalTime           = self.playerItem.duration;
    CGFloat totalMovieDuration = (CGFloat)totalTime.value/totalTime.timescale;
    if (self.sumTime > totalMovieDuration) { self.sumTime = totalMovieDuration;}
    if (self.sumTime < 0) { self.sumTime = 0; }
    
    self.isDragged = YES;
    
    CGFloat  draggedValue  = (CGFloat)self.sumTime/(CGFloat)totalMovieDuration;
    
     self.contollView.startTime = [LXAVPlayView durationStringWithTime:(NSInteger) self.sumTime];
    self.contollView.slideValue = draggedValue;

}
/**
 *  缓冲较差时候回调这里
 */
- (void)bufferingSomeSecond {
    self.playState = LXPlayerStateBuffering;
    // playbackBufferEmpty会反复进入，因此在bufferingOneSecond延时播放执行完之前再调用bufferingSomeSecond都忽略
    __block BOOL isBuffering = NO;
    if (isBuffering) return;
    isBuffering = YES;
    
    // 需要先暂停一小会之后再播放，否则网络状况不好的时候时间在走，声音播放不出来
    [self.player pause];
    LXWS(weakSelf);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // 如果此时用户已经暂停了，则不再需要开启播放了
//        if (self.isPauseByUser) {
//            isBuffering = NO;
//            return;
//        }
//
        weakSelf.playState  = LXPlayerStatePlaying;
        // 如果执行了play还是没有播放则说明还没有缓存好，则再次缓存一段时间
        isBuffering = NO;
        if (!weakSelf.playerItem.isPlaybackLikelyToKeepUp) { [weakSelf bufferingSomeSecond]; }
        
    });
}
#pragma mark - 计算缓冲进度

/**
 *  计算缓冲进度
 *
 *  @return 缓冲进度
 */
- (NSTimeInterval)availableDuration {
    NSArray *loadedTimeRanges = [[_player currentItem] loadedTimeRanges];
    CMTimeRange timeRange     = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds        = CMTimeGetSeconds(timeRange.start);
    float durationSeconds     = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result     = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}
-(void)layoutSubviews{
    [super layoutSubviews];
     self.playerLayer.frame = self.bounds;
//    NSLog(@"%@",NSStringFromCGRect(self.bounds));
}

#pragma mark---点击事件---
#pragma mark---播放
-(void)play{
    
    [self.contollView IsPlaying:YES];
    [self.player play];
    
}
#pragma mark---暂停---
-(void)pause{
    [self.contollView IsPlaying:NO];

    [self.player pause];
}



#pragma mark----setter method --
-(void)setIsLandScape:(BOOL)isLandScape{
    _isLandScape = isLandScape;
}

-(void)setIsAutoReplay:(BOOL)isAutoReplay{
    _isAutoReplay = isAutoReplay;
    
}
-(void)setIsFullScreen:(BOOL)isFullScreen{
    _isFullScreen = isFullScreen;
    self.contollView.isFullScreen = isFullScreen;
}
#pragma mark----getter method ---
-(UITapGestureRecognizer *)singleTap{
    if (!_singleTap) {
        _singleTap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTap:)];
        _singleTap.delegate =  self;
        _singleTap.numberOfTapsRequired = 1;
        _singleTap.numberOfTouchesRequired = 1;
    }
    return _singleTap;
}
-(UITapGestureRecognizer *)doubleTap{
    if (!_doubleTap) {
        _doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTap:)];
        _doubleTap.numberOfTapsRequired = 2;
        _doubleTap.numberOfTouchesRequired = 1;
        _doubleTap.delegate =  self;
       
    }
    return _doubleTap;
}

-(LXAVPlayControllView *)contollView{
    if (!_contollView) {
        _contollView = [[LXAVPlayControllView alloc]init];
    }
    return _contollView;
}
/**statusBar*/
- (UIView *)statusBar{
    if (_statusBar == nil){
        _statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    }
    return _statusBar;
}
-(UIPanGestureRecognizer *)panRecognizer{
    if (!_panRecognizer) {
        
        
        _panRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panDirection:)];
        _panRecognizer.delegate = self;
        [_panRecognizer setMaximumNumberOfTouches:1];
        [_panRecognizer setDelaysTouchesBegan:YES];
        [_panRecognizer setDelaysTouchesEnded:YES];
        [_panRecognizer setCancelsTouchesInView:YES];
        _panRecognizer.enabled = NO;
    }
    return _panRecognizer;
}



@end
