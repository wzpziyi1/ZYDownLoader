//
//  ZYDownloader.h
//  ZYDownloader
//
//  Created by 王志盼 on 2017/6/27.
//  Copyright © 2017年 王志盼. All rights reserved.
//  初步思路：使用NSURLSessionl来做下载操作，如果文件下载完毕，就将文件移动到cache目录下，如果还在下载中，在保存在tmp目录下并做好相应的错误判断

// 初步完成之后，遇到一个问题，如果同一任务被开始两次，发现要点击两次暂停下载才能停止下载，基于此问题，引入状态控制

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ZYDownloaderState) {
    ZYDownloaderStatePause,
    ZYDownloaderStateDownloading,
    ZYDownloaderStateSuccess,
    ZYDownloaderStateFailed
};

typedef void(^DownloadInfoBlock)(long long totalSize);
typedef void(^DownloadProgressBlock)(float progress);
typedef void(^DownLoadStateChangeBlock)(ZYDownloaderState state);
typedef void(^DownLoadSuccessBlock)(NSString *filePath);
typedef void(^DownLoadFailedBlock)();

@interface ZYDownloader : NSObject


@property (nonatomic, assign, readonly) float progress;
@property (nonatomic, assign, readonly) ZYDownloaderState state;


@property (nonatomic, copy) DownloadInfoBlock downloadInfo;
@property (nonatomic, copy) DownloadProgressBlock downloadProgress;
@property (nonatomic, copy) DownLoadStateChangeBlock stateChange;
@property (nonatomic, copy) DownLoadSuccessBlock downloadSuccess;
@property (nonatomic, copy) DownLoadFailedBlock downloadFailed;

- (void)downloadWithUrl:(NSURL *)url downloadInfo:(DownloadInfoBlock)downloadInfo downloadProgress:(DownloadProgressBlock)downloadProgress success:(DownLoadSuccessBlock)success failed:(DownLoadFailedBlock)failed;



/**
 下载文件，如果任务已经存在，则继续下载
 */
- (void)downloadWithUrl:(NSURL *)url;



/**
 继续下载or开始下载
 */
- (void)resumeTask;
/**
 暂停下载
 */
- (void)pauseCurrentTask;


/**
 取消下载
 */
- (void)cancelCurrentTask;


/**
 取消并清理文件
 */
- (void)cancelAndClean;
@end
