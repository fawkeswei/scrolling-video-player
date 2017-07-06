//
//  ModelController.m
//  scrolling-video-player
//
//  Created by Fawkes Wei on 06/07/2017.
//  Copyright © 2017 Fawkes Wei. All rights reserved.
//

#import "ModelController.h"
#import "DataViewController.h"

#import "VideoMetadata.h"

@interface ModelController ()

@property (strong, nonatomic) NSArray<VideoMetadata *> *pageData;

@end

@implementation ModelController

- (instancetype)init {
    self = [super init];
    if (self) {
        [self loadData];
    }
    return self;
}

- (void)loadData {
    NSDictionary *videoData = @{
                             @"videos": @[
                                         @{
                                           @"videoURL": @"https://d2nsbgzitfs2gt.cloudfront.net/vods3/_definst_/amlst:amazons3/pitch-video-prod/4c20efc6948e0824720d3d3ae257f29a496a1e2b/playlist.m3u8",
                                           @"imageURL": @"https://d1haeak33ufwuv.cloudfront.net/4c20efc6948e0824720d3d3ae257f29a496a1e2b.jpg"
                                           },
                                         @{
                                           @"videoURL": @"https://d2nsbgzitfs2gt.cloudfront.net/vods3_landscape/_definst_/amlst:amazons3/pitch-video-prod/4480800772357e0d44654f8fe6166f08cbea509c/playlist.m3u8",
                                           @"imageURL": @"https://d1haeak33ufwuv.cloudfront.net/4480800772357e0d44654f8fe6166f08cbea509c.jpg"
                                           },
                                         @{
                                           @"videoURL": @"https://d2nsbgzitfs2gt.cloudfront.net/vods3/_definst_/amlst:amazons3/pitch-video-prod/656cd28f71dfd5221f5d7346b19a3119306c06b6/playlist.m3u8",
                                           @"imageURL": @"https://d1haeak33ufwuv.cloudfront.net/656cd28f71dfd5221f5d7346b19a3119306c06b6.jpg"
                                           },
                                         @{
                                           @"videoURL": @"https://d2nsbgzitfs2gt.cloudfront.net/vods3/_definst_/amlst:amazons3/pitch-video-prod/98a13b54d9d1f81448446fdc97285e431312d0c5/playlist.m3u8",
                                           @"imageURL": @"https://d1haeak33ufwuv.cloudfront.net/98a13b54d9d1f81448446fdc97285e431312d0c5.jpg"
                                           },
                                         @{
                                           @"videoURL": @"https://d2nsbgzitfs2gt.cloudfront.net/vods3_landscape/_definst_/amlst:amazons3/pitch-video-prod/22750c962690de6e3e1e5f23c07ad2bdf93606f5/playlist.m3u8",
                                           @"imageURL": @"https://d1haeak33ufwuv.cloudfront.net/22750c962690de6e3e1e5f23c07ad2bdf93606f5.jpg"
                                           }
                                         ]
                             };
    
    NSMutableArray *data = [NSMutableArray array];
    for (NSDictionary *videoMetadata in videoData[@"videos"]) {
        VideoMetadata *metadata = [[VideoMetadata alloc] init];
        metadata.videoUrl = [NSURL URLWithString:videoMetadata[@"videoURL"]];
        metadata.imageUrl = [NSURL URLWithString:videoMetadata[@"imageURL"]];
        [data addObject:metadata];
    }
    self.pageData = data;
}

- (DataViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard {
    // Return the data view controller for the given index.
    if (([self.pageData count] == 0) || (index >= [self.pageData count])) {
        return nil;
    }

    // Create a new view controller and pass suitable data.
    DataViewController *dataViewController = [storyboard instantiateViewControllerWithIdentifier:@"DataViewController"];
    dataViewController.dataObject = self.pageData[index];
    return dataViewController;
}


- (NSUInteger)indexOfViewController:(DataViewController *)viewController {
    // Return the index of the given data view controller.
    // For simplicity, this implementation uses a static array of model objects and the view controller stores the model object; you can therefore use the model object to identify the index.
    return [self.pageData indexOfObject:viewController.dataObject];
}


#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSUInteger index = [self indexOfViewController:(DataViewController *)viewController];
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index storyboard:viewController.storyboard];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSUInteger index = [self indexOfViewController:(DataViewController *)viewController];
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.pageData count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index storyboard:viewController.storyboard];
}

@end
