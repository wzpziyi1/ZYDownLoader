//
//  ZYFileTool.m
//  ZYDownloader
//
//  Created by 王志盼 on 2017/6/27.
//  Copyright © 2017年 王志盼. All rights reserved.
//

#import "ZYFileTool.h"

@implementation ZYFileTool
+ (BOOL)fileExist:(NSString *)path
{
    if (path == nil || path.length == 0)
    {
        return NO;
    }
    
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

+ (long long)fileSize:(NSString *)path
{
    if (![self fileExist:path])
    {
        return 0;
    }
    NSDictionary *infoDict = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    return [infoDict[NSFileSize] longLongValue];
}

+ (void)moveFileFromPath:(NSString *)fromPath ToPath:(NSString *)toPath
{
    if (![self fileExist:fromPath]) return;
    
    [[NSFileManager defaultManager] moveItemAtPath:fromPath toPath:toPath error:nil];
}

+ (void)removeFile:(NSString *)path
{
    if (![self fileExist:path]) return;
    
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

@end
