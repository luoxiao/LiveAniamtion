//
//  ELAnimationManager.h
//  AnimationDemo
//
//  Created by 罗潇 on 16/6/24.
//  Copyright © 2016年 罗潇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ELAnimationDefine.h"

typedef void(^AnimationStatus)(BOOL finished);


@interface ELAnimationManager : NSObject

+ (instancetype)shareMnager;

- (void)showAnimation:(ELAnimationType)animationType path:(NSString *)path parentView:(UIView *)parentView;

- (void)doAnimationText:(NSString *)text animationStatus:(AnimationStatus)animationStatus;

- (void)exitProcess;


@end
