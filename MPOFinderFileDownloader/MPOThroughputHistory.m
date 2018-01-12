//
//  MPOThroughputHistory.m
//  MPOFinderFileDownloader
//
//  Created by 吴天 on 2018/1/12.
//

#import "MPOThroughputHistory.h"

@interface MPOThroughputHistoryRecord : NSObject

@property (nonatomic, assign, readonly) long long bytes;
@property (nonatomic, assign, readonly) NSTimeInterval timeElapsed;

+ (instancetype)recordWithBytes:(long long)bytes timeElapsed:(NSTimeInterval)timeElapsed;

@end

@implementation MPOThroughputHistoryRecord

+ (instancetype)recordWithBytes:(long long)bytes timeElapsed:(NSTimeInterval)timeElapsed
{
    MPOThroughputHistoryRecord * record = [MPOThroughputHistoryRecord new];
    record->_bytes = bytes;
    record->_timeElapsed = timeElapsed;
    return record;
}

@end

@interface MPOThroughputHistory ()

@property (nonatomic, assign) NSUInteger maximumMeasurementsToKeep;
@property (nonatomic, strong) NSMutableArray<MPOThroughputHistoryRecord *> * measurements;
@property (nonatomic, assign) CFAbsoluteTime lastestTimestamp;

@end

@implementation MPOThroughputHistory

- (instancetype)init
{
    if (self = [super init]) {
        _maximumMeasurementsToKeep = 20;
        _measurements = [NSMutableArray<MPOThroughputHistoryRecord *> array];
    }
    return self;
}

- (instancetype)initWithMaximumMeasurementsToKeep:(NSUInteger)numberOfMeasurements
{
    if (self = [self init]) {
        _maximumMeasurementsToKeep = numberOfMeasurements;
    }
    return self;
}

- (void)_reset
{
    [_measurements removeAllObjects];
    _lastestTimestamp = CFAbsoluteTimeGetCurrent();
}

- (void)startMeasurement
{
    [self _reset];
}

- (void)push:(long long)byteLength
{
    CFAbsoluteTime current = CFAbsoluteTimeGetCurrent();
    MPOThroughputHistoryRecord * record = [MPOThroughputHistoryRecord recordWithBytes:byteLength timeElapsed:(current - _lastestTimestamp)];
    [_measurements addObject:record];
    while (_measurements.count > _maximumMeasurementsToKeep) {
        [_measurements removeObjectAtIndex:0];
    }
    _lastestTimestamp = current;
}

- (long long)currentBytesPerSeconds
{
    long long totalBytes = 0;
    NSTimeInterval totalTime = 0;
    for (MPOThroughputHistoryRecord * record in _measurements) {
        totalBytes += record.bytes;
        totalTime += record.timeElapsed;
    }
    if (totalTime <= 0) {
        return totalBytes;
    }
    return totalBytes / totalTime;
}

@end
