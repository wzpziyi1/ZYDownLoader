//
//  ViewController.m
//  ZYDownloader
//
//  Created by 王志盼 on 2017/6/27.
//  Copyright © 2017年 王志盼. All rights reserved.
//

#import "ViewController.h"
#import "ZYDownloadManager.h"

@interface ViewController ()
@end

@implementation ViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    
    
}

- (IBAction)download:(id)sender {
    
    NSURL *url = [NSURL URLWithString:@"http://sw.bos.baidu.com/sw-search-sp/software/a974c8ed7c9/dd_mac_1.9.1.dmg"];
    
    NSURL *url2 = [NSURL URLWithString:@"https://dl.devmate.com/com.macpaw.CleanMyMac2/CleanMyMac2.dmg"];
    
    
    [[ZYDownloadManager sharedInstance] downloadWithUrl:url downloadInfo:^(long long totalSize) {
        NSLog(@"1下载信息--%lld", totalSize);
    } downloadProgress:^(float progress) {
        NSLog(@"1下载进度--%f", progress);
    } success:^(NSString *filePath) {
        NSLog(@"1下载成功--路径:%@", filePath);
    } failed:^{
        NSLog(@"1下载失败了");
    }];
    
    [[ZYDownloadManager sharedInstance] downloadWithUrl:url2 downloadInfo:^(long long totalSize) {
        NSLog(@"2下载信息--%lld", totalSize);
    } downloadProgress:^(float progress) {
        NSLog(@"2下载进度--%f", progress);
    } success:^(NSString *filePath) {
        NSLog(@"2下载成功--路径:%@", filePath);
    } failed:^{
        NSLog(@"2下载失败了");
    }];
    
    
    
//    NSURL *url = [NSURL URLWithString:@"https://codeload.github.com/BradLarson/GPUImage/zip/master"];
//    [self.downLoader downloadWithUrl:url];
}
- (IBAction)pause:(id)sender {
//    [self.downLoader pauseCurrentTask];
}
- (IBAction)cancel:(id)sender {
//    [self.downLoader cancelCurrentTask];
}
- (IBAction)cancelClean:(id)sender {
//    [self.downLoader cancelCurrentTask];
}



@end
