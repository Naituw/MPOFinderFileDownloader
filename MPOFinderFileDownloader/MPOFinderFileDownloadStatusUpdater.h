//
//  MPOFinderFileStatusUpdater.h
//  MPOFinderFileDownloader
//
//  Created by 吴天 on 2018/1/10.
//  Copyright © 2018年 wutian. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MPOFinderFileDownloadStatusUpdaterDelegate;

@interface MPOFinderFileDownloadStatusUpdater : NSObject

- (instancetype)initWithDownloadingToFilePath:(NSString *)path sourceURL:(NSURL *)sourceURL delegate:(id<MPOFinderFileDownloadStatusUpdaterDelegate>)delegate;

- (void)downloadProgressUpdateWithTotalBytesExpected:(long long)totalBytes bytesWritten:(long long)bytesWritten speed:(long long)speedBytesPerSecond;
- (void)downloadFinished;

@end

@protocol MPOFinderFileDownloadStatusUpdaterDelegate <NSObject>

- (void)fileDownloadStatusUpdaterDidPerformCancel:(MPOFinderFileDownloadStatusUpdater *)updater;

@end
