//
//  ViewController.m
//  ZYDownloader
//
//  Created by 王志盼 on 2017/6/27.
//  Copyright © 2017年 王志盼. All rights reserved.
//

#import "ViewController.h"
#import "ZYDownloader.h"

@interface ViewController ()
@property (nonatomic, strong) ZYDownloader *downLoader;
@end

@implementation ViewController

- (ZYDownloader *)downLoader {
    if (!_downLoader) {
        _downLoader = [ZYDownloader new];
    }
    return _downLoader;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    
    
}

- (IBAction)download:(id)sender {
    NSURL *url = [NSURL URLWithString:@"https://codeload.github.com/BradLarson/GPUImage/zip/master"];
    [self.downLoader downloadWithUrl:url];
}
- (IBAction)pause:(id)sender {
    [self.downLoader pauseCurrentTask];
}
- (IBAction)cancel:(id)sender {
    [self.downLoader cancelCurrentTask];
}
- (IBAction)cancelClean:(id)sender {
    [self.downLoader cancelCurrentTask];
}



@end
