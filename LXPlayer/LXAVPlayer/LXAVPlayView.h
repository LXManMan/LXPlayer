//
//  LXAVPlayView.h
//  LXPlayer
//
//  Created by chenergou on 2017/12/4.
//  Copyright © 2017年 漫漫. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LXPlayModel;

@interface LXAVPlayView : UIView


//是否可以设置为横屏
@property(nonatomic,assign)BOOL isLandScape;

//是否自动播放
@property(nonatomic,assign)BOOL isAutoReplay;

@property(nonatomic,strong)LXPlayModel          *currentModel;//当前模型

/*返回按钮的回调*/
@property(nonatomic,copy)BackBlock backBlock;

/**销毁播放器*/
-(void)destroyPlayer;

@end
