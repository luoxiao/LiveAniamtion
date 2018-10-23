//
//  CCKeyFrameAnimationView.m
//  oupai
//
//  Created by tc on 12/26/17.
//  Copyright © 2017 yizhibo. All rights reserved.
//

#import "CCKeyFrameAnimationView.h"
#import "UIImage+keyFrameDecoder.h"

#define FXRunBlockSafe(block, ...) {\
if (block) {\
block(__VA_ARGS__);\
}\
}
@interface CCKeyFrameAnimationView ()

@property (nonatomic, strong) CADisplayLink *displayLink;

@property (nonatomic, assign) NSTimeInterval accumulator;

@property (nonatomic, assign) NSUInteger currentFrameIndex;

@property (nonatomic, strong) NSMutableArray * frameImages;

@property (nonatomic, assign) NSTimeInterval lastQueryTime;

@property (nonatomic, assign) NSTimeInterval playedAnimTime;

@property (nonatomic, assign) NSUInteger playedFrames;

@property (nonatomic, getter=isAnimating) BOOL animating;
@end

@implementation CCKeyFrameAnimationView

#pragma mark - 👨‍💻‍ Initialization
- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self commonSetup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self commonSetup];
    }
    return self;
}

- (void)commonSetup
{
    self.backgroundColor = [UIColor clearColor];
    self.userInteractionEnabled = NO;
    
    _animationDuration = 4;
    _animationRepeatCount = 1;
    
}

#pragma mark - 🙏 Public methods
- (void)startAnimating
{
    self.accumulator = 0;
    self.displayLink = [CADisplayLink displayLinkWithTarget:self
                                                      selector:@selector(updateKeyframe:)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    
}

- (void)stopAnimating
{

    if (_displayLink) {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }

    self.layer.contents = nil;

    self.frameImages = nil;
    self.currentFrameIndex = 0;
    self.playedAnimTime = 0;
    self.playedFrames = 0;
    
    _animating = NO;
}


#pragma mark - Keyframe Update
- (void)updateKeyframe:(CADisplayLink *)link {
    __block BOOL bIsLastRepeat = NO;
    __block NSInteger bImgIndex = -1;
    [self imageIndexAtTime:self.accumulator
                returnInfo:^(BOOL lastRepeat, NSInteger reversedImageIndex)
     {
         bIsLastRepeat = lastRepeat;
         bImgIndex = reversedImageIndex;
     }];
    _animating = YES;
    self.accumulator += link.duration * link.frameInterval;
    if (bImgIndex >= 0) {
        if (bImgIndex != self.currentFrameIndex) {
            CALayer *strongActor = self.layer;
            if (strongActor) {
                self.currentFrameIndex = bImgIndex;
                UIImage *frame = self.frameImages[bImgIndex];
                    __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
                        CGImageRef copyImageRef = [frame cc_decodedCGImageRefCopy];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            weakSelf.layer.contents = (__bridge_transfer id)copyImageRef;
                        });
                    });
                if (bIsLastRepeat) {
                    [self.frameImages removeLastObject];
                }
            }
            else {
                [self stopAnimating];
            }
        }
    }
    else {
        [self stopAnimating];
    }
}

#pragma mark - 🙄 Private methods
- (void)imageIndexAtTime:(NSTimeInterval)time
              returnInfo:(void (^)( BOOL isLastRepeat, NSInteger reversedImageIndex))returnInfo {
    if (time < self.lastQueryTime) {
        self.playedFrames = 0;
        self.playedAnimTime = 0;
    }
    
    NSTimeInterval timeDiff = time - self.playedAnimTime;
    if (timeDiff < 0) {
        timeDiff = time;
    }
    
    NSUInteger framesCount = self.animationImages.count;
    NSTimeInterval repeatsDuration = _animationDuration*_animationRepeatCount;
        if (timeDiff < repeatsDuration) {
            __block BOOL bIsLastRepeat;
            __block NSUInteger bFrameIndex;
            [self frameIndexAtTime:timeDiff
                        returnInfo:^(BOOL isLastRepeat, NSUInteger frameIndex)
             {
                 bIsLastRepeat = isLastRepeat;
                 bFrameIndex = frameIndex;
             }];
            self.lastQueryTime = time;
            NSUInteger reversedIndex = framesCount - (self.playedFrames+bFrameIndex) - 1;
            FXRunBlockSafe(returnInfo, bIsLastRepeat, reversedIndex);
            return;
        }
        FXRunBlockSafe(returnInfo, YES, -1);
}

- (void)frameIndexAtTime:(NSTimeInterval)time
             returnInfo:(void (^)(BOOL isLastRepeat, NSUInteger frameIndex))returnInfo {
    NSUInteger framesCount = _animationImages.count;
    
    NSUInteger repeat = floor(time / _animationDuration);
    NSTimeInterval p_interval = _animationDuration/framesCount;
    NSUInteger frameIndex = floor((time - repeat * _animationDuration) / p_interval);
    frameIndex = frameIndex < framesCount ? frameIndex : framesCount-1;
    FXRunBlockSafe(returnInfo, repeat >= _animationRepeatCount-1, frameIndex);
}


#pragma mark - ✍️ Setters & Getters
- (void)setAnimationImages:(NSArray<UIImage *> *)animationImages
{
    _animationImages = animationImages;
    //倒序
    _frameImages=(NSMutableArray *)[[animationImages  reverseObjectEnumerator] allObjects];
}

@end
