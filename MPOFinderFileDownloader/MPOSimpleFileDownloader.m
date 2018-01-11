//
//  MPOSimpleDownloader.m
//  MPOFinderFileDownloader
//
//  Created by 吴天 on 2018/1/10.
//  Copyright © 2018年 wutian. All rights reserved.
//

#import "MPOSimpleFileDownloader.h"

@interface MPOSimpleFileDownloader () <NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSURLConnection * currentConnection;
@property (nonatomic, strong) NSOutputStream * fileOutputStream;
@property (nonatomic, strong) NSString * outputPath;
@property (nonatomic, copy) MPOFileDownloadProgressBlock progressBlock;
@property (nonatomic, copy) MPOFileDownloadCompletionBlock completionBlock;
@property (nonatomic, assign) long long fileTotalBytes;
@property (nonatomic, assign) long long fileBytesWritten;

@end

@implementation MPOSimpleFileDownloader

- (instancetype)init
{
    if (self = [super init]) {
        [self _reset];
    }
    return self;
}

- (void)downloadURL:(NSURL *)url toPath:(NSString *)path progress:(MPOFileDownloadProgressBlock)progress completion:(MPOFileDownloadCompletionBlock)completion
{
    if (!completion) {
        completion = ^(NSError * error) {
            
        };
    }
    
    if (self.downloading) {
        return completion([self _errorWithCode:MPOSimpleFileDownloaderErrorCodeAlreadyDownloading]);
    }
    
    if (!url.absoluteString.length || !path.length) {
        return completion([self _errorWithCode:MPOSimpleFileDownloaderErrorCodeInvalidParamaters]);
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return completion([self _errorWithCode:MPOSimpleFileDownloaderErrorCodeFileExists]);
    }
    
    _outputPath = path;
    _progressBlock = progress;
    _completionBlock = completion;
    
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
    request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    
    _currentConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [_currentConnection start];
}

- (BOOL)downloading
{
    return _currentConnection != nil;
}

- (void)cancelCurrentDownload
{
    if (_currentConnection) {
        [_currentConnection cancel];
        _currentConnection = nil;
        
        [self _reset];
    }
}

- (long long)currentDownloadSpeedBytesPerSecond
{
    return 0;
}

- (void)_completeWithError:(NSError *)error
{
    [self _closeOutputStreamIfNeeded];
    
    if (_currentConnection) {
        _currentConnection = nil;
    }
    
    if (_completionBlock) {
        _completionBlock(error);
    }
    
    [self _reset];
}

- (void)_updateProgress
{
    if (_fileTotalBytes && _progressBlock) {
        _progressBlock(_fileBytesWritten, _fileTotalBytes);
    }
}

- (void)_closeOutputStreamIfNeeded
{
    if (!_fileOutputStream) {
        return;
    }
    [_fileOutputStream close];
    _fileOutputStream = nil;
}

- (void)_reset
{
    [self _closeOutputStreamIfNeeded];
    
    _outputPath = nil;
    _completionBlock = NULL;
    _progressBlock = NULL;
    _fileTotalBytes = 0;
    _fileBytesWritten = 0;
}

- (NSError *)_errorWithCode:(MPOSimpleFileDownloaderErrorCode)errorCode
{
    return [NSError errorWithDomain:MPOSimpleFileDownloaderErrorDomain code:errorCode userInfo:nil];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    _fileTotalBytes = response.expectedContentLength;
    
    if (!_fileOutputStream) {
        _fileOutputStream = [NSOutputStream outputStreamToFileAtPath:_outputPath append:NO];
        [_fileOutputStream open];
    }
    
    [self _updateProgress];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSUInteger length = data.length;
    
    _fileBytesWritten += [_fileOutputStream write:data.bytes maxLength:length];

    [self _updateProgress];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self _completeWithError:error];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self _updateProgress];
    
    NSError * error = nil;
    
    if (_fileBytesWritten < _fileTotalBytes) {
        error = [self _errorWithCode:MPOSimpleFileDownloaderErrorCodeUnexpectedEOF];
    }
    
    [self _completeWithError:error];
}

@end

NSString * const MPOSimpleFileDownloaderErrorDomain = @"MPOSimpleFileDownloaderErrorDomain";
