//
//  UIAnimationVC.m
//  LiveAnimation
//
//  Created by luoxiao on 2018/10/24.
//  Copyright © 2018年 luoxiao. All rights reserved.
//

#import "UILiveViewController.h"
#import "ELAnimationManager.h"
#import <AVFoundation/AVFoundation.h>

@interface UILiveViewController ()

@property (nonatomic, strong) AVPlayer      *avPlayer;


@end

@implementation UILiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initUI];
    [self loadVideoPlayerView];
    [self regisetNotificaiton:true];
    
    [self performSelector:@selector(loadLocalAnimation) withObject:nil afterDelay:1];
}

- (void)dealloc
{
    [self regisetNotificaiton:false];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:true animated:false];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)regisetNotificaiton:(BOOL)reg {
    
    if (reg) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                 selector:@selector(AVPlayerItemDidPlayToEndTimeNotification:)
                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                   object:nil];
    }
    else {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (void)initUI {
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)loadLocalAnimation {
    
    NSString *path = [[NSBundle mainBundle] pathForResource:self.animationName ofType:nil];
    NSString *configPath = [path stringByAppendingPathComponent:@"animation.json"];
    NSData *jsonData = [[NSData alloc]initWithContentsOfFile:configPath];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
    NSString *animationTypeStr = dict[@"AnimationType"];
    
    ELAnimationType  animationType;
    if ([animationTypeStr isEqualToString:KEY_AUTOPLAY]) {
        animationType = ELAnimationAutoPlay;
    }else if ([animationTypeStr isEqualToString:KEY_CUSTOM]){
        animationType = ELAnimationCustom;
    }else {
        animationType = ELAnimationCustom;
    }
    ELAnimationManager *manager = [ELAnimationManager shareMnager];
    [manager showAnimation:animationType path:path parentView:self.view];
    [manager doAnimationText:@"樱桃小丸子" animationStatus:^(BOOL finished) {
//        if (finished) {
//            weakself.isAnimation = NO;
//            [weakself AnimationContinuousShow];
//        }
    }];
    
}


- (void)loadVideoPlayerView {
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"video2" ofType:@"mp4"];
    AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:[NSURL fileURLWithPath:path]];
    AVPlayer *avPlayer = [[AVPlayer alloc] initWithPlayerItem:item];
    self.avPlayer = avPlayer;
    AVPlayerLayer *palyerLayer = [AVPlayerLayer playerLayerWithPlayer:avPlayer];
    palyerLayer.frame = self.view.bounds;
    palyerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:palyerLayer];
    [avPlayer play];
}


- (void)AVPlayerItemDidPlayToEndTimeNotification:(NSNotification *)notifiaction {
    
    [self.avPlayer seekToTime:CMTimeMake(0, 1)];
    [self startPlay];
}

- (void)startPlay {
    if (self.avPlayer) {
        [self.avPlayer play];
    }
}

- (void)stopPlay {
    if (self.avPlayer) {
        [self.avPlayer pause];
    }
}

@end
