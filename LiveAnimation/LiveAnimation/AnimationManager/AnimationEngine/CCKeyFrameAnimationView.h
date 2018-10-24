//
//  CCKeyFrameAnimationView.h
//  oupai
//
//  Created by 罗潇 on 16/6/24.
//  Copyright © 2016年 罗潇. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 关键帧动画 view 解决内存暴涨问题
 */
@interface CCKeyFrameAnimationView : UIView
@property (nullable, nonatomic, copy) NSArray<UIImage *> *animationImages;
@property (nonatomic) NSTimeInterval animationDuration;
@property (nonatomic) NSInteger      animationRepeatCount;

@property(nonatomic, readonly, getter=isAnimating) BOOL animating;

- (void)startAnimating;
- (void)stopAnimating;
@end
