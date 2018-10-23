//
//  ELAnimationView.h
//  AnimationDemo
//
//  Created by 罗潇 on 16/6/29.
//  Copyright © 2016年 罗潇. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface ELAnimationView : SKView

@property (nonatomic, weak)id deleate;

- (SKScene *)getCurrentScene;

- (void)startAnimation;

- (void)stopAnimation;

@end
