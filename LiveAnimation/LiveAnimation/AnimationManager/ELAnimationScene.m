//
//  ELAnimationScene.m
//  AnimationDemo
//
//  Created by 罗潇 on 16/6/29.
//  Copyright © 2016年 罗潇. All rights reserved.
//

#import "ELAnimationScene.h"
#import <SpriteKit/SpriteKit.h>

@implementation ELAnimationScene

- (id)initWithSize:(CGSize)size {
    self = [super initWithSize:size];
    if (self) {
        
        self.backgroundColor = [SKColor clearColor];

    }
    return self;
}


- (void)start {

    if ([self.dataSource getAnimationType] == ELAnimationCustom) {
        
        NSArray *spriteNodes = [self.dataSource getConfigSpriteNodes];
        for (SKSpriteNode *sprite in spriteNodes) {
            [self addChild:sprite];
        }
        
        SKAction *sceneAction = [self.dataSource getSceneAnimationAction:self];
        [self runAction:sceneAction completion:^{
            
        }];
    }
    
    [self loadNameLabel];
}

- (void)loadNameLabel {
    
    NSString *text = [self.dataSource getNameText];
    
    if (text && [text length] > 0) {
        NSArray *textArr = [text componentsSeparatedByString:@" "];
        
        SKLabelNode *prefixLable = [[SKLabelNode alloc] init];
        prefixLable.fontName = @"Helvetica";
        prefixLable.fontSize = 16;
        prefixLable.fontColor = HEX_COLOR(0xFFED3F);
        prefixLable.text = [NSString stringWithFormat:@"●%@",textArr.firstObject];
        [self addChild:prefixLable];
        SKAction *action = [self.dataSource getNameLabelAnimationAction:prefixLable];
        
        SKLabelNode *subfixLabel = [[SKLabelNode alloc] init];
        subfixLabel.fontName = @"Helvetica";
        subfixLabel.fontSize = 16;
        subfixLabel.alpha = prefixLable.alpha;
        subfixLabel.fontColor = [UIColor whiteColor];
        subfixLabel.text = [textArr lastObject];
        subfixLabel.position = CGPointMake(prefixLable.frame.origin.x + prefixLable.frame.size.width + subfixLabel.frame.size.width / 2 + 6, prefixLable.position.y);
        [self addChild:subfixLabel];
        
        [prefixLable runAction:action];
        [subfixLabel runAction:action];
    }
}





@end
