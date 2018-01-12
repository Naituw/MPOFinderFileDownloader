//
//  MPOFinderFileDownloader.m
//  MPOFinderFileDownloader
//
//  Created by 吴天 on 2018/1/10.
//  Copyright © 2018年 wutian. All rights reserved.
//

#import "MPOFinderFileDownloader.h"
#import "MPOFinderFileDownloadStatusUpdater.h"

@interface MPOFinderFileDownloader () <MPOFinderFileDownloadStatusUpdaterDelegate>

@property (nonatomic, strong) id<MPOFileDownloading> underlyingDownloader;
@property (nonatomic, strong) MPOFinderFileDownloadStatusUpdater * fileStatusUpdater;

@end

@implementation MPOFinderFileDownloader

- (instancetype)initWithUnderlyingDownloader:(id<MPOFileDownloading>)downloader
{
    if (self = [self init]) {
        self.underlyingDownloader = downloader;
    }
    return self;
}

- (void)downloadURL:(NSURL *)url toPath:(NSString *)path progress:(MPOFileDownloadProgressBlock)progressBlock completion:(MPOFileDownloadCompletionBlock)completion
{
    BOOL __block finished = NO;
    typeof(self) __weak weakSelf = self;
    [self.underlyingDownloader downloadURL:url toPath:path progress:^(long long bytesWritten, long long totalBytesExpected) {
        typeof(weakSelf) __strong strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        
        [strongSelf.fileStatusUpdater downloadProgressUpdateWithTotalBytesExpected:totalBytesExpected bytesWritten:bytesWritten speed:strongSelf.underlyingDownloader.currentDownloadSpeedBytesPerSecond];

        if (progressBlock) {
            progressBlock(bytesWritten, totalBytesExpected);
        }
    } completion:^(NSError *error) {
        finished = YES;
        typeof(weakSelf) __strong strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        
        if (strongSelf.fileStatusUpdater) {
            [strongSelf.fileStatusUpdater downloadFinished];
            [strongSelf setFileStatusUpdater:nil];
        }
        
        if (completion) {
            completion(error);
        }
    }];
    
    if (!finished) {
        self.fileStatusUpdater = [[MPOFinderFileDownloadStatusUpdater alloc] initWithDownloadingToFilePath:path sourceURL:url delegate:self];
    }
}

- (BOOL)downloading
{
    return self.underlyingDownloader.downloading;
}

- (void)cancelCurrentDownload
{
    [self.underlyingDownloader cancelCurrentDownload];
}

- (long long)currentDownloadSpeedBytesPerSecond
{
    return self.underlyingDownloader.currentDownloadSpeedBytesPerSecond;
}

- (void)fileDownloadStatusUpdaterDidPerformCancel:(MPOFinderFileDownloadStatusUpdater *)updater
{
    [self cancelCurrentDownload];
}

@end
