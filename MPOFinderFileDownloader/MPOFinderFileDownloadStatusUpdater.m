//
//  MPOFinderFileStatusUpdater.m
//  MPOFinderFileDownloader
//
//  Created by 吴天 on 2018/1/10.
//  Copyright © 2018年 wutian. All rights reserved.
//

// Most of logic in this file derived from chromium project
// https://github.com/scheib/chromium/blob/master/chrome/browser/download/download_status_updater_mac.mm

#import "MPOFinderFileDownloadStatusUpdater.h"

// Given an NSProgress string name (kNSProgress[...]Name above), looks up the
// real symbol of that name from Foundation and returns it.
static NSString* ProgressString(NSString* string) {
    static NSMutableDictionary* cache;
    static CFBundleRef foundation;
    if (!cache) {
        cache = [[NSMutableDictionary alloc] init];
        foundation = CFBundleGetBundleWithIdentifier(CFSTR("com.apple.Foundation"));
    }
    
    NSString* result = [cache objectForKey:string];
    if (!result) {
        NSString * __strong * ref = (NSString * __strong *)CFBundleGetDataPointerForName(foundation, (CFStringRef)string);
        if (ref) {
            result = *ref;
            [cache setObject:result forKey:string];
        }
    }
    
    if (!result) {
        // Huh. At least return a local copy of the expected string.
        result = string;
        NSString* const kKeySuffix = @"Key";
        if ([result hasSuffix:kKeySuffix])
            result = [result substringToIndex:[result length] - [kKeySuffix length]];
    }
    
    return result;
}

@interface MPOFinderFileDownloadStatusUpdater ()
{
    struct {
        unsigned int downloadStarted: 1;
        unsigned int downloadFinished: 1;
    } _flags;
}

@property (nonatomic, assign) long long totalBytesExpected;
@property (nonatomic, assign) long long bytesWritten;
@property (nonatomic, assign) long long speedBytesPerSecond;

@property (nonatomic, strong) NSProgress * nsProgress;
@property (nonatomic, strong) NSString * filePath;
@property (nonatomic, strong) NSURL * sourceDownloadURL;
@property (nonatomic, weak) id<MPOFinderFileDownloadStatusUpdaterDelegate> delegate;

@end

@implementation MPOFinderFileDownloadStatusUpdater

- (void)dealloc
{
    [self _destoryNSProgress];
}

- (instancetype)initWithDownloadingToFilePath:(NSString *)path sourceURL:(NSURL *)sourceURL delegate:(id<MPOFinderFileDownloadStatusUpdaterDelegate>)delegate
{
    if (self = [super init]) {
        _filePath = path;
        _sourceDownloadURL = sourceURL;
        _delegate = delegate;
        
        if (!_filePath.length) {
            return nil;
        }
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:_filePath]) {
            _nsProgress = [self _createNSProgress];
        }
    }
    return self;
}

- (void)downloadProgressUpdateWithTotalBytesExpected:(long long)totalBytes bytesWritten:(long long)bytesWritten speed:(long long)speedBytesPerSecond
{
    _totalBytesExpected = totalBytes;
    _bytesWritten = bytesWritten;
    _speedBytesPerSecond = speedBytesPerSecond;
    
    if (!_nsProgress) {
        _nsProgress = [self _createNSProgress];
    } else {
        [self _updateNSProgress];
    }
}

- (void)downloadFinished
{
    [self _destoryNSProgress];

    if ([[NSFileManager defaultManager] fileExistsAtPath:self.filePath]) {
        // Bounce the dock icon.
        [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"com.apple.DownloadFileFinished" object:self.filePath];
        
        // Notify the Finder.
        [[NSWorkspace sharedWorkspace] noteFileSystemChanged:self.filePath];
    }
}

- (void)_destoryNSProgress
{
    if (_nsProgress) {
        [_nsProgress unpublish];
        _nsProgress = nil;
    }
}

- (NSProgress *)_createNSProgress
{
    NSURL * destinationURL = [NSURL fileURLWithPath:self.filePath];
    
    if (!destinationURL) {
        return nil;
    }
    
    NSDictionary * userInfo = @{ProgressString([NSString stringWithFormat:@"%@%@", @"NSProgressFile", @"LocationCanChangeKey"]): @true,
                                NSProgressFileOperationKindKey: NSProgressFileOperationKindDownloading,
                                NSProgressFileURLKey: destinationURL};
    
    NSProgress * progress = [[NSProgress alloc] initWithParent:nil userInfo:userInfo];
    progress.kind = NSProgressKindFile;
    
    if (_sourceDownloadURL) {
        [progress setUserInfoObject:_sourceDownloadURL forKey:ProgressString([NSString stringWithFormat:@"%@%@", @"NSProgressFile", @"DownloadingSourceURLKey"])];
    }
    
    progress.pausable = NO;
    progress.cancellable = YES;
    
    typeof(self) __weak this = self;
    
    [progress setCancellationHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [this _performCancel];
        });
    }];
    
    if (_totalBytesExpected) {
        progress.totalUnitCount = _totalBytesExpected;
        progress.completedUnitCount = _bytesWritten;
    }
    
    [progress publish];
    
    return progress;
}

- (void)_updateNSProgress
{
    _nsProgress.totalUnitCount = _totalBytesExpected;
    _nsProgress.completedUnitCount = _bytesWritten;
    
    if (_speedBytesPerSecond >= 0) {
        [_nsProgress setUserInfoObject:@(_speedBytesPerSecond) forKey:NSProgressThroughputKey];
        
        if (_speedBytesPerSecond > 0) {
            long long bytesRemaining = MAX(0, _totalBytesExpected - _bytesWritten);
            NSTimeInterval timeRemaining = (double)bytesRemaining / _speedBytesPerSecond;
            [_nsProgress setUserInfoObject:@(timeRemaining) forKey:NSProgressEstimatedTimeRemainingKey];
        } else {
            [_nsProgress setUserInfoObject:nil forKey:NSProgressEstimatedTimeRemainingKey];
        }
    } else {
        [_nsProgress setUserInfoObject:nil forKey:NSProgressThroughputKey];
        [_nsProgress setUserInfoObject:nil forKey:NSProgressEstimatedTimeRemainingKey];
    }
}

- (void)_performCancel
{
    if ([_delegate respondsToSelector:@selector(fileDownloadStatusUpdaterDidPerformCancel:)]) {
        [_delegate fileDownloadStatusUpdaterDidPerformCancel:self];
    }
}

@end
