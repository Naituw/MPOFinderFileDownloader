//
//  MPOFinderFileDownloader.h
//  MPOFinderFileDownloader
//
//  Created by 吴天 on 2018/1/10.
//  Copyright © 2018年 wutian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPOFileDownloading.h"

@interface MPOFinderFileDownloader : NSObject <MPOFileDownloading>

- (instancetype)initWithUnderlyingDownloader:(id<MPOFileDownloading>)downloader;

@property (nonatomic, strong, readonly) id<MPOFileDownloading> underlyingDownloader;

@end
