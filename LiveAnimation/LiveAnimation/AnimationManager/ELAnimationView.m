//
//  ELAnimationView.m
//  AnimationDemo
//
//  Created by 罗潇 on 16/6/29.
//  Copyright © 2016年 罗潇. All rights reserved.
//

#import "ELAnimationView.h"
#import "ELAnimationScene.h"

@interface ELAnimationView ()


@property (nonatomic, strong)ELAnimationScene *animationScene;

@end


@implementation ELAnimationView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (id)initWithFrame:(CGRect)frame {

    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [SKColor clearColor];
        [self loadScene];
    }
    return self;
}


- (void)loadScene {

    if (!self.scene) {
//        self.showsFPS = YES;
//        self.showsNodeCount = YES;
        
        self.animationScene = [ELAnimationScene sceneWithSize:self.bounds.size];
        self.animationScene.scaleMode = SKSceneScaleModeAspectFill;
        [self presentScene:_animationScene];
    }
}


- (void)setDeleate:(id)deleate {
    _deleate = deleate;
    if (_deleate) {
        _animationScene.dataSource = _deleate;
        _animationScene.mDelegate = _deleate;
    }
}


- (void)startAnimation {
    if (self.animationScene) {
        [self.animationScene start];
    }
}

- (void)stopAnimation {

    if (self.animationScene) {
        [self.animationScene removeAllActions];
        [self.animationScene removeAllChildren];
    }
}

- (SKScene *)getCurrentScene {

    return self.animationScene;
}



@end
