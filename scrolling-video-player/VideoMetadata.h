//
//  VideoMetadata.h
//  scrolling-video-player
//
//  Created by Fawkes Wei on 06/07/2017.
//  Copyright © 2017 Fawkes Wei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VideoMetadata : NSObject

@property (nonatomic, strong) NSURL *videoUrl;
@property (nonatomic, strong) NSURL *imageUrl;

@end
