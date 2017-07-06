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

@property (nonatomic, strong) AVPlayer *player;

@end

@implementation DataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:self.dataObject.videoUrl];

    self.player = [AVPlayer playerWithPlayerItem:item];
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

@end
