//
//  LXAVPlayControllView.h
//  LXPlayer
//
//  Created by chenergou on 2017/12/4.
//  Copyright © 2017年 漫漫. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^PlayBtnClick) (BOOL isPlay);

typedef void (^FullScreenBlock) (BOOL isFullScreen);

typedef void (^ReplayBlock) (BOOL isReplay);


@interface LXAVPlayControllView : UIView

/*当前播放时间*/
@property(nonatomic,strong)NSString *startTime;

/*总时间*/
@property(nonatomic,strong)NSString *endTime;

/*视屏名字*/
@property(nonatomic,strong)NSString *playTitle;
/*是否显示*/
@property(nonatomic,assign)BOOL isShow;

@property(nonatomic,assign)BOOL        isFullScreen;//是否是全屏
/*播放进度*/
@property(nonatomic,assign)CGFloat slideValue;


/*缓存进度*/
@property(nonatomic,assign)CGFloat cacheValue;

@property(nonatomic,strong)UIImage *placeImage;

/*播放按钮的回调*/
@property(nonatomic,copy)PlayBtnClick playCallBack;

/*全屏按钮的回调*/
@property(nonatomic,copy)FullScreenBlock fullScreenBlock;

/*返回按钮的回调*/
@property(nonatomic,copy)BackBlock backBlock;


/*重播按钮的回调*/
@property(nonatomic,copy)ReplayBlock replayBlock;


/**slide手势的回调*/
//================================================//

//手势开始
@property(nonatomic,copy)Panbegin panBegin;

//手势结束
@property(nonatomic,copy)PanEnd panEnd;

//手势播放进度
@property(nonatomic,copy)GetSlideValue getSlideValue;

//轻拍手势
@property(nonatomic,copy)TapSlider tapSlider;

//================================================//

/*动画显示控制层*/
-(void)showIsAnimated:(BOOL)animated;
/*动画隐藏控制层*/
-(void)hidIsAnimated:(BOOL)animated;

/*是否正在播放*/
-(void)IsPlaying:(BOOL)isPlaying;

//播放结束
-(void)showPlayEnd;

//展示加载动画
-(void)showLoadingAnimation:(BOOL)isShow;


//重置播放状态
-(void)resetPlayState;

@end
