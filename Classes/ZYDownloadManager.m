//
//  ZYDownloadManager.m
//  ZYDownloader
//
//  Created by 王志盼 on 2017/6/28.
//  Copyright © 2017年 王志盼. All rights reserved.
//

#import "ZYDownloadManager.h"
#import "NSString+MD5.h"


@interface ZYDownloadManager()
@property (nonatomic, strong) NSMutableDictionary *downloadDict;
@end

static ZYDownloadManager *_instance = nil;
@implementation ZYDownloadManager 
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_instance)
        {
            _instance = [[self alloc] init];
        }
    });
    return _instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    if (!_instance)
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _instance = [super allocWithZone:zone];
        });
        
    }
    return _instance;
}

- (id)copyWithZone:(NSZone *)zone
{
    return _instance;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return _instance;
}


- (void)downloadWithUrl:(NSURL *)url downloadInfo:(DownloadInfoBlock)downloadInfo downloadProgress:(DownloadProgressBlock)downloadProgress success:(DownLoadSuccessBlock)success failed:(DownLoadFailedBlock)failed
{
    NSString *urlMD5 = [url.absoluteString md5];
    
    ZYDownloader *downloader = self.downloadDict[urlMD5];
    if (!downloader)
    {
        downloader = [[ZYDownloader alloc] init];
        self.downloadDict[urlMD5] = downloader;
    }
    __weak typeof(self) weakSelf = self;
    [downloader downloadWithUrl:url downloadInfo:downloadInfo downloadProgress:downloadProgress success:^(NSString *filePath) {
        [weakSelf.downloadDict removeObjectForKey:urlMD5];
        if (success) success(filePath);
    } failed:failed];
}

- (void)pauseAll
{
    [self.downloadDict.allKeys performSelector:@selector(pauseCurrentTask)];
}

- (void)resumeAll
{
    [self.downloadDict.allKeys performSelector:@selector(resumeTask)];
}

- (void)pauseWithUrl:(NSURL *)url
{
    NSString *urlMD5 = [url.absoluteString md5];
    ZYDownloader *downloader = self.downloadDict[urlMD5];
    [downloader pauseCurrentTask];
}

- (void)resumeWithUrl:(NSURL *)url
{
    NSString *urlMD5 = [url.absoluteString md5];
    ZYDownloader *downloader = self.downloadDict[urlMD5];
    [downloader resumeTask];
}

- (void)cancelWithUrl:(NSURL *)url
{
    NSString *urlMD5 = [url.absoluteString md5];
    ZYDownloader *downloader = self.downloadDict[urlMD5];
    [downloader cancelCurrentTask];
}

#pragma mark - getter && setter
- (NSMutableDictionary *)downloadDict
{
    if (!_downloadDict)
    {
        _downloadDict = [NSMutableDictionary dictionary];
    }
    return _downloadDict;
}

@end
