//
//  MPOFileDownloading.h
//  MPOFinderFileDownloader
//
//  Created by 吴天 on 2018/1/10.
//

#import <Foundation/Foundation.h>

typedef void (^MPOFileDownloadProgressBlock)(long long bytesWritten, long long totalBytesExpected);
typedef void (^MPOFileDownloadCompletionBlock)(NSError * error);

// MPOFileDownloader should NOT support more than one download task per instance

@protocol MPOFileDownloading <NSObject>

- (void)downloadURL:(NSURL *)url toPath:(NSString *)path progress:(MPOFileDownloadProgressBlock)progress completion:(MPOFileDownloadCompletionBlock)completion;

@property (nonatomic, assign, readonly) BOOL downloading;

- (void)cancelCurrentDownload;

@property (nonatomic, assign, readonly) long long currentDownloadSpeedBytesPerSecond;

@end
