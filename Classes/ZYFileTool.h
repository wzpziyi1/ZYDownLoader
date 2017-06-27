//
//  ZYFileTool.h
//  ZYDownloader
//
//  Created by 王志盼 on 2017/6/27.
//  Copyright © 2017年 王志盼. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZYFileTool : NSObject

/**
 判断路径下文件是否存在
 */
+ (BOOL)fileExist:(NSString *)path;


/**
 文件大小
 */
+ (long long)fileSize:(NSString *)path;


/**
 移动文件

 @param fromPath 原路径
 @param toPath 需要移动到的路径
 */
+ (void)moveFileFromPath:(NSString *)fromPath ToPath:(NSString *)toPath;


/**
 删除文件
 */
+ (void)removeFile:(NSString *)path;
@end
