//
//  ZYDownloader.m
//  ZYDownloader
//
//  Created by 王志盼 on 2017/6/27.
//  Copyright © 2017年 王志盼. All rights reserved.
//

#import "ZYDownloader.h"
#import "ZYFileTool.h"

#define kCachePath NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject
#define kTmpPath NSTemporaryDirectory()

@interface ZYDownloader() <NSURLSessionDataDelegate>
{
    //文件总大小
    long long _totalSize;
    //tmp目录下的文件下载大小
    long long _tmpSize;
}
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, weak) NSURLSessionDataTask *dataTask;

//下载状态路径
@property (nonatomic, copy) NSString *downloadedPath;
@property (nonatomic, copy) NSString *downloadingPath;

//输出流
@property (nonatomic, strong) NSOutputStream *output;

@property (nonatomic, assign, readwrite) ZYDownloaderState state;
@property (nonatomic, assign, readwrite) float progress;
@end

@implementation ZYDownloader

- (void)downloadWithUrl:(NSURL *)url downloadInfo:(DownloadInfoBlock)downloadInfo downloadProgress:(DownloadProgressBlock)downloadProgress success:(DownLoadSuccessBlock)success failed:(DownLoadFailedBlock)failed
{
    self.downloadInfo = downloadInfo;
    self.downloadProgress = downloadProgress;
    self.downloadSuccess = success;
    self.downloadFailed = failed;
    [self downloadWithUrl:url];
}

- (void)downloadWithUrl:(NSURL *)url
{
    //判断是否已经在下载中了
    if ([url isEqual:self.dataTask.originalRequest.URL])
    {
        //如果在暂停状态，就开始下载即可
        [self resumeTask];
        return;
    }
    
    self.progress = 0;
    //读取路径(路径+文件名)
    self.downloadedPath = [kCachePath stringByAppendingPathComponent:url.lastPathComponent];
    self.downloadingPath = [kTmpPath stringByAppendingPathComponent:url.lastPathComponent];
    
    //文件下载完成后
    if ([ZYFileTool fileExist:self.downloadedPath])
    {
        NSLog(@"文件已经下载完成");
        self.state = ZYDownloaderStateSuccess;
        return;
    }
    
    //判断文件是否正在下载
    if (![ZYFileTool fileExist:self.downloadingPath])
    {
        //没有下载过，那么从0开始下载
        [self downloadWithUrl:url offset:0];
    }
    
    //下载过
    _tmpSize = [ZYFileTool fileSize:self.downloadingPath];
    [self downloadWithUrl:url offset:_tmpSize];
}

- (void)downloadWithUrl:(NSURL *)url offset:(long long)offset
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:0];
    //设置下载的range
    [request setValue:[NSString stringWithFormat:@"bytes=%lld-", offset] forHTTPHeaderField:@"Range"];
    
    //开始下载
    self.dataTask = [self.session dataTaskWithRequest:request];
    [self resumeTask];
}

#pragma mark - 事件\状态控制

/**
 继续下载
 */
- (void)resumeTask
{
    if (self.state == ZYDownloaderStatePause && self.dataTask)
    {
        [self.dataTask resume];
        self.state = ZYDownloaderStateDownloading;
    }
    
}


/**
 暂停下载，但是这么写会导致，暂停了几次，想要真正开始下载就得点击开始下载几次
 引入状态控制解决这个问题
 */
- (void)pauseCurrentTask
{
    if (self.state == ZYDownloaderStateDownloading)
    {
        [self.dataTask suspend];
        self.state = ZYDownloaderStatePause;
    }
    
}


/**
 取消下载
 */
- (void)cancelCurrentTask
{
    self.state = ZYDownloaderStatePause;
    [self.session invalidateAndCancel];
    self.session = nil;
    self.dataTask = nil;
}


/**
 取消下载并移除文件
 */
- (void)cancelAndClean
{
    [self cancelCurrentTask];
    [ZYFileTool removeFile:self.downloadingPath];
}

#pragma mark - NSURLSessionDataDelegate

/**
 response中有响应头的信息，可以拿到文件的总大小
 通过completionHandler代码块的回调，可以控制是否继续下载文件
 */
- (void)URLSession:(NSURLSession *)session dataTask:(nonnull NSURLSessionDataTask *)dataTask didReceiveResponse:(nonnull NSURLResponse *)response completionHandler:(nonnull void (^)(NSURLSessionResponseDisposition))completionHandler
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
//    NSLog(@"%@", httpResponse.allHeaderFields);
    
    /*
     从响应头里面取出文件总大小
     需要注意的是，这里有个坑，如果在
     [request setValue:[NSString stringWithFormat:@"bytes=%lld-", offset] forHTTPHeaderField:@"Range"];
     方法中，offset是从x开始的，那么从httpResponse.allHeaderFields[@"Content-Length"]取出来的大小会减少x
     所以，这个值不准确。
     所以，先从Content-Length里面取值，
     同时，如果Content-Range有值，那么用Content-Range的值替代掉上面的值
     */
    _totalSize = [httpResponse.allHeaderFields[@"Content-Length"] longLongValue];
    
    if (self.downloadInfo)
    {
        self.downloadInfo(_totalSize);
    }
    
    NSString *contentRangeStr = httpResponse.allHeaderFields[@"Content-Range"];
    if (contentRangeStr.length != 0) {
        _totalSize = [[contentRangeStr componentsSeparatedByString:@"/"].lastObject longLongValue];
    }
    
    //如果文件大小一致，那么说明文件下载完毕，将文件从tmp目录移动到cache目录下
    if (_tmpSize == _totalSize)
    {
        self.progress = 1.0 * _tmpSize / _totalSize;
        [ZYFileTool moveFileFromPath:self.downloadingPath ToPath:self.downloadedPath];
        completionHandler(NSURLSessionResponseCancel);
        self.state = ZYDownloaderStateSuccess;
        return;
    }
    
    //文件大小不一致，那么做错误判断
    if (_tmpSize > _totalSize)
    {
        //移除文件
        [ZYFileTool removeFile:self.downloadingPath];
        
        //取消继续下载
        completionHandler(NSURLSessionResponseCancel);
        
        //重新开始下载
        [self downloadWithUrl:httpResponse.URL];
        
        return;
    }
    self.state = ZYDownloaderStateDownloading;
    self.output = [NSOutputStream outputStreamToFileAtPath:self.downloadingPath append:YES];
    [self.output open];
    completionHandler(NSURLSessionResponseAllow);
}


/**
 与之前的NSURLConnection一直，会一直回传data
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    NSLog(@"正在下载");
    [self.output write:data.bytes maxLength:data.length];
    _tmpSize += data.length;
    self.progress = 1.0 * _tmpSize / _totalSize;
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error
{
    NSLog(@"请求完成");
    if (error == nil)
    {
        /*
         没错误并不代表文件真的请求完毕
         需要判断文件大小
         最好的是判断文件的md5值
         */
        [ZYFileTool moveFileFromPath:self.downloadingPath ToPath:self.downloadedPath];
        self.state = ZYDownloaderStateSuccess;
    }
    else
    {
        NSLog(@"Error:%d, %@", (int)error.code, error.description);
        
        
        //可以利用error做断网判断，这里做的是手动取消与无网络的判断
        if (error.code == -999 || error.code == -1005)
        {
            self.state = ZYDownloaderStatePause;
        }
        else
        {
            self.state = ZYDownloaderStateFailed;
        }
        
    }
    [self.output close];
}

#pragma mark - getter && setter

- (NSURLSession *)session
{
    if (!_session)
    {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
    }
    return _session;
}

- (void)setState:(ZYDownloaderState)state
{
    if (_state == state) return;
    
    _state = state;
    
    if (self.stateChange)
    {
        self.stateChange(_state);
    }
    
    if (_state == ZYDownloaderStateSuccess && self.downloadSuccess)
    {
        self.downloadSuccess(self.downloadedPath);
    }
    
    if (_state == ZYDownloaderStateFailed && self.downloadFailed)
    {
        self.downloadFailed();
    }
}

- (void)setProgress:(float)progress
{
    _progress = progress;
    
    if (self.downloadProgress)
    {
        self.downloadProgress(_progress);
    }
}

@end
