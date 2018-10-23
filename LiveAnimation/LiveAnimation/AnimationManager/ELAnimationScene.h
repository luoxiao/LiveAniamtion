//
//  ELAnimationScene.h
//  AnimationDemo
//
//  Created by 罗潇 on 16/6/29.
//  Copyright © 2016年 罗潇. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "ELAnimationDefine.h"

@protocol ELAnimationSceneDelegate <NSObject>

@end


@protocol ELAnimationSceneDataSource <NSObject>


- (NSArray *)getConfigSpriteNodes;
- (SKAction *)getSceneAnimationAction:(SKScene *)scene;

- (NSString *)getNameText;
- (SKAction *)getNameLabelAnimationAction:(SKNode *)node;

- (ELAnimationType)getAnimationType;


@end


@interface ELAnimationScene : SKScene


- (void)start;

@property (nonatomic, weak)id<ELAnimationSceneDelegate>mDelegate;
@property (nonatomic, weak)id<ELAnimationSceneDataSource>dataSource;


@end
