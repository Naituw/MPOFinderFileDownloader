//
//  MPOFinderFileDownloader.m
//  MPOFinderFileDownloader
//
//  Created by 吴天 on 2018/1/10.
//  Copyright © 2018年 wutian. All rights reserved.
//

#import "MPOFinderFileDownloader.h"

@interface MPOFinderFileDownloader ()

@property (nonatomic, strong) id<MPOFileDownloading> underlyingDownloader;

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
    [self.underlyingDownloader downloadURL:url toPath:path progress:^(double progress) {
        if (progressBlock) {
            progressBlock(progress);
        }
    } completion:^(NSError *error) {
        if (completion) {
            completion(error);
        }
    }];
}

- (BOOL)downloading
{
    return self.underlyingDownloader.downloading;
}

- (void)cancelCurrentDownload
{
    [self.underlyingDownloader cancelCurrentDownload];
}

@end
