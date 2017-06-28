//
//  ZYDownloadManager.h
//  ZYDownloader
//
//  Created by 王志盼 on 2017/6/28.
//  Copyright © 2017年 王志盼. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZYDownloader.h"

@interface ZYDownloadManager : NSObject <NSCopying>
+ (instancetype)sharedInstance;

- (void)downloadWithUrl:(NSURL *)url downloadInfo:(DownloadInfoBlock)downloadInfo downloadProgress:(DownloadProgressBlock)downloadProgress success:(DownLoadSuccessBlock)success failed:(DownLoadFailedBlock)failed;

- (void)pauseAll;

- (void)resumeAll;

- (void)pauseWithUrl:(NSURL *)url;

- (void)resumeWithUrl:(NSURL *)url;

- (void)cancelWithUrl:(NSURL *)url;
@end
