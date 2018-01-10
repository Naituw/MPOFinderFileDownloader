//
//  MPOSimpleDownloader.h
//  MPOFinderFileDownloader
//
//  Created by 吴天 on 2018/1/10.
//  Copyright © 2018年 wutian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPOFileDownloading.h"

@interface MPOSimpleFileDownloader : NSObject <MPOFileDownloading>

@end

typedef NS_ENUM(NSInteger, MPOSimpleFileDownloaderErrorCode) {
    MPOSimpleFileDownloaderErrorCodeUnknown = 0,
    MPOSimpleFileDownloaderErrorCodeAlreadyDownloading,
    MPOSimpleFileDownloaderErrorCodeFileExists,
    MPOSimpleFileDownloaderErrorCodeInvalidParamaters,
    MPOSimpleFileDownloaderErrorCodeUnexpectedEOF,
};

extern NSString * const MPOSimpleFileDownloaderErrorDomain;
