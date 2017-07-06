//
//  ModelController.h
//  scrolling-video-player
//
//  Created by Fawkes Wei on 06/07/2017.
//  Copyright © 2017 Fawkes Wei. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DataViewController;

@interface ModelController : NSObject <UIPageViewControllerDataSource>

- (DataViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard;
- (NSUInteger)indexOfViewController:(DataViewController *)viewController;

@end

