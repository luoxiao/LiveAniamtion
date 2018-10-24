//
//  CCKeyFrameAnimationView.h
//  oupai
//
//  Created by 罗潇 on 16/6/24.
//  Copyright © 2016年 罗潇. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ELKeyFrameAnimationView : UIView
@property (nullable, nonatomic, copy) NSArray<UIImage *> *animationImages;
@property (nonatomic) NSTimeInterval animationDuration;
@property (nonatomic) NSInteger      animationRepeatCount;

@property(nonatomic, readonly, getter=isAnimating) BOOL animating;

- (void)startAnimating;
- (void)stopAnimating;
@end
