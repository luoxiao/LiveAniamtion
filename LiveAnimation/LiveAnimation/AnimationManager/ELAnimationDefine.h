//
//  ELAnimationDefine.h
//  AnimationDemo
//
//  Created by 罗潇 on 16/6/24.
//  Copyright © 2016年 罗潇. All rights reserved.
//

#ifndef ELAnimationDefine_h
#define ELAnimationDefine_h

#define ScreenHeight [UIScreen mainScreen].bounds.size.height
#define ScreenWidth [UIScreen mainScreen].bounds.size.width

#define ccp(__X__,__Y__) CGPointMake(__X__,__Y__)
#define HEX_COLOR(hex) [UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16)) / 255.0 green:((float)((hex & 0xFF00) >> 8)) / 255.0 blue:((float)(hex & 0xFF)) / 255.0 alpha:1]



#define KEY_AUTOPLAY                            @"autoPlay"
#define KEY_CUSTOM                              @"custom"



#define ANIMATION_CONFIG                        @"animationConfig.plist"


//配置主节点
#define ANIMATION_FRAMES                        @"frames"
#define ANIMATION_TOTAL_DURATION                @"totalDuration"
#define ANIMATION_MUSIC                         @"music"
#define ANIMATION_MAIN_SCENE                    @"mainScene"
#define ANIMATION_NODE                          @"node"
#define ANIMATION_AUTOPLAY                      @"autoPlay"                 // 轮播图配置

//node下自定义节点
#define ANIMATION_NODE_NAMELABEL                @"nameLabel"

//allKeys
#define KEY_PRIORITY                            @"priority"
#define KEY_ORGINSIZE                           @"orginSize"
#define KEY_ANCHORPOINT                         @"anchorPoint"
#define KEY_REPEATFOREVER                       @"repeatForever"
#define KEY_SCENE                               @"scene"

#define KEY_SIZE                                @"size"
#define KEY_RELATIVE_SIZE_SCALE                 @"relativeSizeScale"            //相对屏幕大小，范围[0,1] 例：0.5为半屏
#define KEY_SIZE_DURATION                       @"sizeDuration"

//位置
#define KEY_POSITION                            @"position"
#define KEY_POINT                               @"point"                        //绝对位置
#define KEY_RELATIVE_HORIZONTAL                 @"relativeHorizontal"           //相对水平位置，范围[0,1]
#define KEY_RELATIVE_VERTIACAL                  @"relativeVertical"             //相对垂直位置，范围[0,1]
#define KEY_RELATIVE_OFFSET                     @"relativeOffset"               //相对位置偏移，{x，y}

#define KEY_OFFSET_X                            @"offsetX"
#define KEY_OFFSET_Y                            @"offsetY"
#define KEY_MOVE_DURATION                       @"moveDuration"

#define KEY_ALPH                                @"alph"
#define KEY_ALPH_DURATION                       @"alphDuration"

#define KEY_ANGLE                               @"angle"
#define KEY_ANGLE_DURATION                      @"angleDuration"

#define KEY_BEZIERPATH                          @"bezierPath"
#define KEY_BEZIERPATH_DURATION                 @"bezierPathDuration"


//多图轮播动画特有
#define KEY_IMAGE_NUM                           @"imageNum"                     //图片张数
#define KEY_DURATION                            @"duration"                     //一组图播放时间
#define KEY_DURATION_FRAME                      @"frameDuration"                //动画场景时间



/*!
 * @brief:动画文件配置说明
 *
 * @brief:ELAnimationAutoPlay 时 配置node、music、autoPlay、totalDuration
 *
 * @brief:ELAnimationCustom 时 配置node、music、frames、totalDuration、mainScene
 */

typedef NS_ENUM(NSInteger ,ELAnimationType) {

    ElAnimationSignleImage = 0,             //单图
    ELAnimationAutoPlay,                    //多图轮播
    ELAnimationCustom,                      //自定义动画

};





#endif /* ELAnimationDefine_h */
