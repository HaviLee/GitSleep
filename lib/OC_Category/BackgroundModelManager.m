//
//  BackgroundModelManager.m
//  SelfService
//
//  Created by shanezhang on 14-8-19.
//  Copyright (c) 2014年 Beijing ShiShiKe Technologies Co., Ltd. All rights reserved.
//

#import "BackgroundModelManager.h"
#import <AVFoundation/AVFoundation.h>

@interface BackgroundModelManager()
{
    // 后台播放器
    AVAudioPlayer *_player;
    NSTimer *_timer;  // 定时器
}
@end

@implementation BackgroundModelManager
//single_implementation(BackgroundModelManager)

- (id)init
{
    self = [super init];
    if (self)
    {
      // 准备播放器
      [self prepAudio];
    }
    return self;
}

/**
 *  准备播放器
 *  
 *  @return 准备播放的结果
 */
- (BOOL)prepAudio
{
	NSError *error;
	NSString *path = [[NSBundle mainBundle] pathForResource:@"bookSound" ofType:@"mp3"];
    
	if (![[NSFileManager defaultManager] fileExistsAtPath:path]) return NO;
    
    NSURL *url = [NSURL fileURLWithPath:path];
	_player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
	if (!_player)
	{
		NSLog(@"Error: %@", [error localizedDescription]);
		return NO;
	}
	[_player prepareToPlay];
    [_player setVolume:0.0f];
    // 设置循环无限次播放
	[_player setNumberOfLoops:0];
	return YES;
}

/**
 *  播放音频的方法
 */
- (void)playAudio
{
    if ([_player isPlaying])
    {
        [_player stop];
    }
    [_player play];
}

/**
 *  开启后台模式
 */
- (void)openBackgroundModel
{
    // 开启后台播放
    NSError *error = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:&error];
    
    // 每隔一分钟去检查剩余的时间
    if (_timer == nil)
    {
        _timer = [NSTimer scheduledTimerWithTimeInterval:60.0f target:self selector:@selector(tik) userInfo:nil repeats:YES];
    }
}
UIBackgroundTaskIdentifier identifier;
- (void)tik
{
    // 这个是定时检查后台剩余时间
//    SHLog(@"%f---", [[UIApplication sharedApplication] backgroundTimeRemaining]);
//    double d  = [[UIApplication sharedApplication] backgroundTimeRemaining];
//    NSLog(@"-------------------%g",d);
//    NSLog(@"-------------------%f",d);
    if ([[UIApplication sharedApplication] backgroundTimeRemaining] < 61.0)
    {
        // 此处是播放一段空的音乐，声音为零时间很短循环播放的特点
        [self playAudio];
        if(identifier){
            [[UIApplication sharedApplication] endBackgroundTask:identifier];
        }
       identifier =  [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
     //   double d  = [[UIApplication sharedApplication] backgroundTimeRemaining];
   //     NSLog(@"xxxxxxxxxxxxxxxx%g",d);
    }
}

- (void)dealloc
{
    _player = nil;
    _timer = nil;

}
@end
