//
//  ELAnimationManager.m
//  AnimationDemo
//
//  Created by 罗潇 on 16/6/24.
//  Copyright © 2016年 罗潇. All rights reserved.
//

#import "ELAnimationManager.h"
#import <SpriteKit/SpriteKit.h>
#import "ELAnimationView.h"
#import "ELAnimationScene.h"
#import <AVFoundation/AVFoundation.h>

#import "ELKeyFrameAnimationView.h"
@interface ELAnimationManager ()<ELAnimationSceneDelegate,ELAnimationSceneDataSource> {

    ELAnimationType     _animationType;
    ELAnimationView*    _animationView;
    
    NSMutableArray*     _spriteNodeSets;
    
    NSInteger           _autoPlayIndex;

}

@property (nonatomic, strong)AVAudioPlayer *audioPlayer;

@property (nonatomic, copy)AnimationStatus animationStatus;
@property (nonatomic, copy)NSString* filePath;
@property (nonatomic, weak)UIView* parentView;

@property (nonnull, copy)NSString* nameText;
@property (nonatomic, strong)NSDictionary*  info;

@property (nonatomic, weak)ELKeyFrameAnimationView * autoPlayAnimationView;


- (SKView *)getAnimationView;
- (SKScene *)getCurrentAnimationSecene;

@end


@implementation ELAnimationManager

+ (instancetype)shareMnager {
    
    ELAnimationManager *manager = [[ELAnimationManager alloc] init];
    return manager;
}


- (id)init {
    self = [super init];
    if (self) {
        
        _autoPlayIndex = 0;
        _spriteNodeSets = [[NSMutableArray alloc] init];
    }
    return self;
}


- (void)showAnimation:(ELAnimationType)animationType path:(NSString *)path parentView:(UIView *)parentView
{
    _animationType = animationType;
    self.parentView = parentView;
    self.filePath = path;

    [self loadAnimationConfig];
}


- (void)doAnimationText:(NSString *)text animationStatus:(AnimationStatus)animationStatus
 {
     self.animationStatus = animationStatus;
     self.nameText = text;
    
     switch (_animationType) {
         case ElAnimationSignleImage:
             
             break;
         case ELAnimationAutoPlay: {
             [self serializeAutoPlayConfig];
             if ([UIDevice currentDevice].systemVersion.floatValue >= 9.0) {
                 [self loadCustomAnimation];
                 [_animationView startAnimation];
             }
         }
             break;
         case ELAnimationCustom: {
         
             [self loadCustomAnimation];
             [self serializeActionWithFileConfig];
             [_animationView startAnimation];
         }
             break;
             
         default:
             break;
     }
     
     [self checkAnimationStatus];
     [self playBackgroundAudio];
}


- (void)exitProcess {
    
    [self.audioPlayer stop];
    self.audioPlayer = nil;
    [_spriteNodeSets removeAllObjects];
    [_animationView stopAnimation];
    [_animationView removeFromSuperview];
    _animationView = nil;
    
    [self stopAutoPlayAnimation];
}


- (void)loadCustomAnimation {
    if (_animationView) {
        [_animationView removeFromSuperview];
        _animationView = nil;
    }
    _animationView = [[ELAnimationView alloc] initWithFrame:_parentView.bounds];
    _animationView.deleate = self;
    [_parentView addSubview:_animationView];
}


- (SKView *)getAnimationView
{
    return _animationView;
}


- (SKScene *)getCurrentAnimationSecene {
    if (_animationView) {
        return [_animationView getCurrentScene];
    }
    return nil;
}


- (CGSize)getAnimationViewSzie {
    if (_animationType == ELAnimationCustom) {
      return [[self getCurrentAnimationSecene] size];
    }
    return _parentView.frame.size;
}


- (NSString *)getAnimationDirectorPath {
    if (self.filePath) {
        return self.filePath;
    }
    return nil;
}

- (NSString *)getAnimationConfigPath {
    return [[self getAnimationDirectorPath] stringByAppendingPathComponent:ANIMATION_CONFIG];
}

#pragma mark - 

//完成、音乐
- (void)checkAnimationStatus
{
    float totalDuration = [_info[ANIMATION_TOTAL_DURATION] floatValue] > 0 ? [_info[ANIMATION_TOTAL_DURATION] floatValue] : 3.0f;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(totalDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self animationFinished];
    });
    
}

- (void)animationFinished
{
    [self exitProcess];
    if (self.animationStatus) {
        _animationStatus(YES);
    }
}


- (void)playBackgroundAudio {
    
    if ([_info[ANIMATION_MUSIC] length] > 0) {
        NSString *path = [[self getAnimationDirectorPath] stringByAppendingPathComponent:_info[ANIMATION_MUSIC]];
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:nil];
        [self.audioPlayer play];
    }
}

#pragma mark - 
#pragma mark - sprite 配置解析 


- (void)loadAnimationConfig {

    NSString *configPath = [self getAnimationConfigPath];
//    NSString *configPath = [[NSBundle mainBundle] pathForResource:@"animationConfig" ofType:@"plist"];
    self.info = [NSDictionary dictionaryWithContentsOfFile:configPath];

}


- (void)serializeActionWithFileConfig {
    
    [_spriteNodeSets removeAllObjects];
    
    NSDictionary *framesInfo = _info[ANIMATION_FRAMES];
    
    NSArray *allKeys = [self sortAllKeySpirteByPriority:framesInfo];
    
    for (NSString *key in allKeys) {
        
        NSDictionary *spriteInfo = framesInfo[key];
        
        NSString *imagePath = [[self getAnimationDirectorPath] stringByAppendingPathComponent:key];
        SKSpriteNode *spriteNode = [self spriteNodeWithContentsOfFile:imagePath];
        spriteNode.name = key;
        
        [self updateSpriteNodeOrginStatus:spriteNode orginInfo:spriteInfo];
        
        NSArray *sceneArray = spriteInfo[KEY_SCENE];
        NSMutableArray *sequenceActionSets = [NSMutableArray array];
        
        for (NSDictionary *sceneItem in sceneArray) {
            SKAction *groupAction = [self getGropActionFromWithSceneConfig:sceneItem];
            if (groupAction) {
                [sequenceActionSets addObject:groupAction];
            }
        }
        
        BOOL repeatForever = [spriteInfo[KEY_REPEATFOREVER] boolValue];
        if ([sequenceActionSets count] > 0) {
            SKAction *sequenceAction = [SKAction sequence:sequenceActionSets];
            if (repeatForever) {
                sequenceAction = [SKAction repeatActionForever:sequenceAction];
            }
            
            [spriteNode runAction:sequenceAction completion:^{
                //.
            }];
        }
        
        [_spriteNodeSets addObject:spriteNode];
    }
}


- (SKSpriteNode *)spriteNodeWithContentsOfFile:(NSString *)path {
    
    SKTexture *texture = [SKTexture textureWithImage:[UIImage imageWithContentsOfFile:path]];
    SKSpriteNode *spriteNode = [SKSpriteNode spriteNodeWithTexture:texture];
    return spriteNode;
}


- (void)updateSpriteNodeOrginStatus:(SKSpriteNode *)spriteNode orginInfo:(NSDictionary *)spriteInfo {
    
    if (!CGSizeEqualToSize([self getSize:spriteInfo], CGSizeZero)) {
        spriteNode.size = [self getSize:spriteInfo];
    }
    
    if ([spriteInfo[KEY_ANCHORPOINT] length] > 0) {
        spriteNode.anchorPoint = CGPointFromString(spriteInfo[KEY_ANCHORPOINT]);
    }
    
    if (spriteInfo[KEY_POSITION]) {
        spriteNode.position = [self getPosition:spriteInfo[KEY_POSITION]];
    }
    
    if ([spriteInfo[KEY_ANGLE] length] > 0) {
        spriteNode.zRotation = [self convertRadianFromAngle:[spriteInfo[KEY_ANGLE] floatValue]];
    }
    
    if ([spriteInfo[KEY_ALPH] length] > 0) {
        spriteNode.alpha = [spriteInfo[KEY_ALPH] floatValue];
    }
    
}


- (void)updateSceneOrginStatus:(SKScene *)scene orginInfo:(NSDictionary *)info {
    
    if (!CGSizeEqualToSize([self getSize:info], CGSizeZero)) {
        scene.size = [self getSize:info];
    }
    
    if ([info[KEY_ANCHORPOINT] length] > 0) {
        scene.anchorPoint = CGPointFromString(info[KEY_ANCHORPOINT]);
    }
    
    if (info[KEY_POSITION]) {
        scene.position = [self getPosition:info[KEY_POSITION]];
    }
    
    if ([info[KEY_ANGLE] length] > 0) {
        scene.zRotation = [self convertRadianFromAngle:[info[KEY_ANGLE] floatValue]];
    }
    
    if ([info[KEY_ALPH] length] > 0) {
        scene.alpha = [info[KEY_ALPH] floatValue];
    }
}


- (void)updateNodeOrginStatus:(SKNode *)node orginInfo:(NSDictionary *)info {
    
    if (info[KEY_POSITION]) {
        node.position = [self getPosition:info[KEY_POSITION]];
    }
    
    if ([info[KEY_ANGLE] length] > 0) {
        node.zRotation = [self convertRadianFromAngle:[info[KEY_ANGLE] floatValue]];
    }
    
    if ([info[KEY_ALPH] length] > 0) {
        node.alpha = [info[KEY_ALPH] floatValue];
    }
}


- (SKAction *) getGropActionFromWithSceneConfig:(NSDictionary *)scene {
    
    NSMutableArray *actionSets = [NSMutableArray array];
    
    if (!CGSizeEqualToSize([self getSize:scene], CGSizeZero)) {
        CGSize size = [self getSize:scene];
        CGFloat sizeDuration = [scene[KEY_SIZE_DURATION] floatValue];
        SKAction *sizeAction = [SKAction resizeToWidth:size.width height:size.height duration:sizeDuration];
        [actionSets addObject:sizeAction];
    }
    
    //优先位置设置，再取偏移量
    if (![self dictonaryAllValusIsEmpty:scene[KEY_POSITION]]) {
        CGPoint position = [self getPosition:scene[KEY_POSITION]];
        CGFloat moveDuration = [scene[KEY_MOVE_DURATION] floatValue];
        SKAction *moveAction = [SKAction moveTo:position duration:moveDuration];
        [actionSets addObject:moveAction];
    }
    else if ([scene[KEY_OFFSET_X] length] > 0 || [scene[KEY_OFFSET_Y] length] > 0) {
        CGFloat offset_x = scene[KEY_OFFSET_X] ? [scene[KEY_OFFSET_X] floatValue] : 0;
        CGFloat offset_y = scene[KEY_OFFSET_Y] ? [scene[KEY_OFFSET_Y] floatValue] : 0;
        CGFloat moveDuration = [scene[KEY_MOVE_DURATION] floatValue];
        SKAction *moveAction = [SKAction moveByX:offset_x y:offset_y duration:moveDuration];
        [actionSets addObject:moveAction];
    }
    
    if ([scene[KEY_ALPH] length] > 0) {
        CGFloat alph = [scene[KEY_ALPH] floatValue];
        CGFloat alphDuration = [scene[KEY_ALPH_DURATION] floatValue];
        SKAction *fadeActuon = [SKAction fadeAlphaTo:alph duration:alphDuration];
        [actionSets addObject:fadeActuon];
    }
    
    if ([scene[KEY_ANGLE] length] > 0) {
        CGFloat angle = [scene[KEY_ANGLE] floatValue];
        CGFloat angleDuration = [scene[KEY_ANGLE_DURATION] floatValue];
        SKAction *angleActuon = [SKAction rotateToAngle:[self convertRadianFromAngle:angle] duration:angleDuration];
        [actionSets addObject:angleActuon];
    }
    
    //贝塞尔曲线较复杂，之后再考虑
    if ([scene[KEY_BEZIERPATH] length] > 0) {
        
        //        UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:CGRectFromString(scene[SPRITE_BEZIERPATH]) cornerRadius:50];
        //        CGFloat bezierPathDuration = [scene[SPRITE_BEZIERPATH_DURATION] floatValue];
        //
        //        SKAction * action = [SKAction followPath:[bezierPath CGPath] duration:bezierPathDuration];
        //        [actionSets addObject:action];
    }
    
    //    CGPoint anchorPoint = scene[SPRITE_ANCHORPOINT] ? CGPointFromString(scene[SPRITE_ANCHORPOINT]) : CGPointZero;
    
    if ([actionSets count] > 0) {
        SKAction *groupAction = [SKAction group:actionSets];
        return groupAction;
    }
    return nil;
}

//优先绝对位置，再相对位置
- (CGPoint)getPosition:(NSDictionary *)positionInfo {
    
    CGPoint position = CGPointZero;
    if ( positionInfo == nil || [self dictonaryAllValusIsEmpty:positionInfo]) {
        return CGPointZero;
    }
    
    if ([positionInfo[KEY_POINT] length] > 0) {
        position = CGPointFromString(positionInfo[KEY_POINT]);
    }
    else {
        CGSize size = [self getAnimationViewSzie];
        if ([positionInfo[KEY_RELATIVE_HORIZONTAL] length] > 0) {
            position.x = [positionInfo[KEY_RELATIVE_HORIZONTAL] floatValue] * size.width;
        }
        
        if ([positionInfo[KEY_RELATIVE_VERTIACAL] length] > 0) {
            position.y = [positionInfo[KEY_RELATIVE_VERTIACAL] floatValue] * size.height;
        }
        
        if ([positionInfo[KEY_RELATIVE_OFFSET] length] > 0) {
            CGPoint pointOffset = CGPointFromString(positionInfo[KEY_RELATIVE_OFFSET]);
            position = ccp(position.x + pointOffset.x, position.y + pointOffset.y);
        }
    }
    
    return position;
}

- (CGSize)getSize:(NSDictionary *)info
{
    //优先绝对size，再考虑相对屏幕size
    if ([info[KEY_SIZE] length] > 0) {
        return  CGSizeFromString(info[KEY_SIZE]);
    }
    else if ([info[KEY_RELATIVE_SIZE_SCALE] length] > 0) {
        CGFloat sizeScale = [info[KEY_RELATIVE_SIZE_SCALE] floatValue];
        return  CGSizeMake(ScreenWidth * sizeScale, ScreenHeight * sizeScale);
    }
    return CGSizeZero;
}


- (BOOL)dictonaryAllValusIsEmpty:(NSDictionary *)dic {
    
   __block BOOL isEmpty = YES;
    [[dic allValues] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([(NSString *)obj length] > 0) {
            isEmpty = NO;
            *stop = YES;
        }
    }] ;
    
    return isEmpty;
}


- (CGFloat)convertRadianFromAngle:(CGFloat)angle {
    
    return angle * 1.0f / 180 * M_PI;
}


/*!
 * priority越高，优先显示屏幕最前方
 */
- (NSArray *)sortAllKeySpirteByPriority:(NSDictionary *)framesInfo {
    
    NSArray *allKeys = [framesInfo keysSortedByValueUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSDictionary *frameItem = (NSDictionary *)obj1;
        NSDictionary *frameItem_next = (NSDictionary *)obj2;
        
        if ([frameItem[KEY_PRIORITY] floatValue] < [frameItem_next[KEY_PRIORITY] floatValue]) {
            return NSOrderedAscending;
        }
        else if ([frameItem[KEY_PRIORITY] floatValue] > [frameItem_next[KEY_PRIORITY] floatValue]) {
            return NSOrderedDescending;
        }
        return NSOrderedSame;
        
    }];
    
    return allKeys;
}



#pragma mark - ELAnimationSceneDelegate 


#pragma mark - ELAnimationSceneDataSource

- (NSArray *)getConfigSpriteNodes
{
    return _spriteNodeSets;
}

- (SKAction *)getSceneAnimationAction:(SKScene *)scene {
    
    NSDictionary *mainScene = _info[ANIMATION_MAIN_SCENE];
    [self updateSceneOrginStatus:scene orginInfo:mainScene];
    
    NSArray* sceneArray = mainScene[KEY_SCENE];
    NSMutableArray *sequenceActionSets = [NSMutableArray array];
    for (NSDictionary *sceneItem in sceneArray) {
        SKAction *groupAction = [self getGropActionFromWithSceneConfig:sceneItem];
  
        if (groupAction) {
            [sequenceActionSets addObject:groupAction];
        }
    }
    if (sequenceActionSets.count > 0) {
        SKAction *sequenceAction = [SKAction sequence:sequenceActionSets];
        return sequenceAction;
    }
    return nil;
}


- (NSString *)getNameText
{
    return self.nameText;
}

- (SKAction *)getNameLabelAnimationAction:(SKNode *)node {
    
    NSDictionary *nodeInfo = _info[ANIMATION_NODE];
    NSDictionary *nameLabelInfo = nodeInfo[ANIMATION_NODE_NAMELABEL];
    [self updateNodeOrginStatus:node orginInfo:nameLabelInfo];
    
    NSArray* sceneArray = nameLabelInfo[KEY_SCENE];
    NSMutableArray *sequenceActionSets = [NSMutableArray array];
    for (NSDictionary *sceneItem in sceneArray) {
        SKAction *groupAction = [self getGropActionFromWithSceneConfig:sceneItem];
        
        if (groupAction) {
            [sequenceActionSets addObject:groupAction];
        }
    }

    BOOL repeatForever = [nameLabelInfo[KEY_REPEATFOREVER] boolValue];
    if (sequenceActionSets.count > 0) {
        SKAction *sequenceAction = [SKAction sequence:sequenceActionSets];
        if (repeatForever) {
            sequenceAction = [SKAction repeatActionForever:sequenceAction];
        }
        return sequenceAction;
    }
    return nil;
    
}


- (ELAnimationType)getAnimationType
{
    return _animationType;
}



#pragma mark
#pragma mark - 多图轮播

- (void)serializeAutoPlayConfig {
    
    NSDictionary *autoPlayDic = _info[ANIMATION_AUTOPLAY];

    NSInteger count = [autoPlayDic[KEY_IMAGE_NUM] intValue];
    CGFloat duration = [autoPlayDic[KEY_DURATION] floatValue];
    
    

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       
        NSMutableArray *imageSets = [NSMutableArray array];
        for (int i = 0; i < count; i++) {
            NSString *imgPath = [self.filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"img%d.png",i]];
            UIImage *image = [UIImage imageWithContentsOfFile:imgPath];
            if (image) {
                [imageSets addObject:image];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //新增关键帧动画view 17-12-27 by 唐超 解决内存暴涨问题
            ELKeyFrameAnimationView * animationView = [[ELKeyFrameAnimationView alloc] init];
            animationView.animationImages = imageSets;
            animationView.animationDuration = duration;
            animationView.contentMode = UIViewContentModeScaleAspectFit;
            [animationView sizeToFit];
            animationView.center = _parentView.center;
            [_parentView addSubview:animationView];
            self.autoPlayAnimationView = animationView;
            [animationView startAnimating];
            
            [self updateAnimationViewOrginStatus:animationView orginInfo:autoPlayDic];
            [self autoPlayFrameAnimation];
        });
    });
    
}



- (void)updateAnimationViewOrginStatus:(UIView *)view orginInfo:(NSDictionary *)info {
    
    CGRect frame = CGRectZero;
    
    if (!CGSizeEqualToSize([self getSize:info], CGSizeZero)) {
        frame.size = [self getSize:info];
        view.frame = frame;
    }
    
    if (info[KEY_POSITION]) {
        view.center = [self getPosition:info[KEY_POSITION]];
    }
    
    if ([info[KEY_ALPH] length] > 0) {
        view.alpha = [info[KEY_ALPH] floatValue];
    }
}


- (void)autoPlayFrameAnimation {
    
    NSDictionary *autoPlayDic = _info[ANIMATION_AUTOPLAY];
    NSArray *scenes = autoPlayDic[KEY_SCENE];
    
    if (scenes.count > _autoPlayIndex) {
        
        NSDictionary *scene = scenes[_autoPlayIndex];
        CGRect frame = self.autoPlayAnimationView.frame;
        CGPoint center = self.autoPlayAnimationView.center;
        CGFloat alpha = self.autoPlayAnimationView.alpha;
        CGFloat duration = 0;
        
        if (!CGSizeEqualToSize([self getSize:scene], CGSizeZero)) {
            frame.size = [self getSize:scene];
        }
        
        if (![self dictonaryAllValusIsEmpty:scene[KEY_POSITION]]) {
            center = [self getPosition:scene[KEY_POSITION]];
        }
        else if ([scene[KEY_OFFSET_X] length] > 0 || [scene[KEY_OFFSET_Y] length] > 0) {
            CGFloat offset_x = scene[KEY_OFFSET_X] ? [scene[KEY_OFFSET_X] floatValue] : 0;
            CGFloat offset_y = scene[KEY_OFFSET_Y] ? [scene[KEY_OFFSET_Y] floatValue] : 0;
            center.x += offset_x;
            center.y += offset_y;
        }
        
        if ([scene[KEY_ALPH] length] > 0) {
            alpha = [scene[KEY_ALPH] floatValue];
        }
        
        if ([scene[KEY_DURATION_FRAME] length] > 0) {
            duration = [scene[KEY_DURATION_FRAME] floatValue];
        }
        
        [UIView animateWithDuration:duration animations:^{
            
            _autoPlayAnimationView.alpha = alpha;
            _autoPlayAnimationView.center = center;
            _autoPlayAnimationView.frame = CGRectMake(_autoPlayAnimationView.frame.origin.x, _autoPlayAnimationView.frame.origin.y, frame.size.width, frame.size.height);
            
        } completion:^(BOOL finished) {
        }];
        
        if (duration > 0) {
            _autoPlayIndex ++;
            [self performSelector:@selector(autoPlayFrameAnimation) withObject:nil afterDelay:duration];
        }
        
    }
}


- (void)stopAutoPlayAnimation {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(autoPlayFrameAnimation) object:nil];
//    [_autoPlayAnimationView stopAnimating];
//    _autoPlayAnimationView.animationImages = nil;
    [_autoPlayAnimationView removeFromSuperview];
    _autoPlayAnimationView = nil;

}





@end
