//
//  MPOThroughputHistory.h
//  MPOFinderFileDownloader
//
//  Created by 吴天 on 2018/1/12.
//

#import <Foundation/Foundation.h>

@interface MPOThroughputHistory : NSObject

- (instancetype)initWithMaximumMeasurementsToKeep:(NSUInteger)numberOfMeasurements;

- (void)startMeasurement;
- (void)push:(long long)byteLength;

@property (nonatomic, assign, readonly) long long currentBytesPerSeconds;

@end
