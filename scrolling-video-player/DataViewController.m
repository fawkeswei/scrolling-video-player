//
//  DataViewController.m
//  scrolling-video-player
//
//  Created by Fawkes Wei on 06/07/2017.
//  Copyright © 2017 Fawkes Wei. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "DataViewController.h"
#import "PlayerView.h"

@interface DataViewController ()

@property (weak, nonatomic) IBOutlet PlayerView *playerView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *playbackToggleButton;
@property (weak, nonatomic) IBOutlet UISlider *playbackSeekSlider;

@property (nonatomic, strong) AVPlayer *player;

@property (nonatomic, strong) id periodicTimeObserver;

@end

@implementation DataViewController

static void * PlayerItemContext = &PlayerItemContext;
static void * PlayerContext = &PlayerContext;

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.player pause];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:self.dataObject.videoUrl];
    [playerItem addObserver:self forKeyPath:NSStringFromSelector(@selector(status)) options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:&PlayerItemContext];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
    
    self.player = [AVPlayer playerWithPlayerItem:playerItem];
    [self.player addObserver:self forKeyPath:NSStringFromSelector(@selector(timeControlStatus)) options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:&PlayerContext];
    
    __weak typeof(self) weakSelf = self;
    self.periodicTimeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 30) queue:NULL usingBlock:^(CMTime time) {
        [weakSelf.playbackSeekSlider setValue:CMTimeGetSeconds(time) animated:YES];
    }];
    
    
    [self.playerView setPlayer:self.player];
    
    
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(concurrentQueue, ^{
        NSData *image = [[NSData alloc] initWithContentsOfURL:self.dataObject.imageUrl];

        dispatch_async(dispatch_get_main_queue(), ^{
            self.imageView.image = [UIImage imageWithData:image];
        });
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)playerItemDidFinishPlaying:(NSNotification *)notification {
    if ([self.parentViewController isKindOfClass:[UIPageViewController class]]) {
        UIPageViewController *pageViewController = (UIPageViewController *)self.parentViewController;
        
        DataViewController *nextViewController = (DataViewController *)[pageViewController.dataSource pageViewController:pageViewController viewControllerAfterViewController:self];
        if (nextViewController) {
            [pageViewController setViewControllers:@[nextViewController] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
        }
    }
}

#pragma mark - IBActions

- (IBAction)togglePlayback:(id)sender {
    if (self.player.status == AVPlayerStatusReadyToPlay) {
        if (self.player.timeControlStatus == AVPlayerTimeControlStatusPaused) {
            [self.player play];
        }
        else {
            [self.player pause];
        }
    }
}

- (IBAction)seek:(UISlider *)slider {
    [self.player.currentItem cancelPendingSeeks];
    
    CMTime time = CMTimeMake(slider.value, 1);
    [self.player.currentItem seekToTime:time];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == &PlayerItemContext && [keyPath isEqualToString:NSStringFromSelector(@selector(status))]) {
        AVPlayerItemStatus status = [change[NSKeyValueChangeNewKey] integerValue];
        switch (status) {
            case AVPlayerItemStatusReadyToPlay: {
                self.playbackToggleButton.enabled = YES;
                self.playbackSeekSlider.enabled = YES;
                
                [self.playbackToggleButton setTitle:@"Play" forState:UIControlStateNormal];
                self.playbackSeekSlider.maximumValue = CMTimeGetSeconds(self.player.currentItem.duration);
                break;
            }
            case AVPlayerItemStatusFailed: {
                // Failed. Examine AVPlayerItem.error
                NSLog(@"Failed. Examine AVPlayerItem.error");
                self.playbackToggleButton.enabled = NO;
                self.playbackSeekSlider.enabled = NO;
                break;
            }
            case AVPlayerItemStatusUnknown: {
                // Not ready
                self.playbackToggleButton.enabled = NO;
                self.playbackSeekSlider.enabled = NO;
                break;
            }
        }
    }
    else if (context == &PlayerContext && [keyPath isEqualToString:NSStringFromSelector(@selector(timeControlStatus))]) {
        AVPlayerTimeControlStatus status = [change[NSKeyValueChangeNewKey] integerValue];
        switch (status) {
            case AVPlayerTimeControlStatusPaused: {
                [self.playbackToggleButton setTitle:@"Play" forState:UIControlStateNormal];
                break;
            }
            case AVPlayerTimeControlStatusWaitingToPlayAtSpecifiedRate: {
            case AVPlayerTimeControlStatusPlaying:
                self.imageView.hidden = YES;
                [self.playbackToggleButton setTitle:@"Pause" forState:UIControlStateNormal];
                break;
            }
            default:
                break;
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
}

- (void)dealloc {
    [self.player.currentItem removeObserver:self forKeyPath:NSStringFromSelector(@selector(status))];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
    [self.player removeObserver:self forKeyPath:NSStringFromSelector(@selector(timeControlStatus))];
    [self.player removeTimeObserver:self.periodicTimeObserver];
}

@end
