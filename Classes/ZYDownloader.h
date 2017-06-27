//
//  ZYDownloader.h
//  ZYDownloader
//
//  Created by 王志盼 on 2017/6/27.
//  Copyright © 2017年 王志盼. All rights reserved.
//  思路：如果文件下载完毕，就将文件移动到cache目录下，如果还在下载中，在保存在tmp目录下

#import <Foundation/Foundation.h>

@interface ZYDownloader : NSObject

/**
 下载文件，如果任务已经存在，则继续下载
 */
- (void)downloadWithUrl:(NSURL *)url;
@end
