//
//  DragView.m
//  DragFilePromises
//
//  Created by 吴天 on 2018/1/9.
//  Copyright © 2018年 wutian. All rights reserved.
//

#import "DragView.h"
#import <MPOFinderFileDownloader.h>
#import <MPOSimpleFileDownloader.h>

typedef NS_ENUM(NSInteger, DragViewState) {
    DragViewStateReady,
    DragViewStateDragging,
    DragViewStateDownloading,
    DragViewStateDownloadSuccess,
};

@interface DragView () <NSFilePromiseProviderDelegate, NSDraggingSource>

@property (nonatomic, assign) DragViewState state;
@property (nonatomic, strong) MPOFinderFileDownloader * downloader;

@end

@implementation DragView

- (instancetype)initWithFrame:(NSRect)frameRect
{
    if (self = [super initWithFrame:frameRect]) {
    }
    return self;
}

- (void)setState:(DragViewState)state
{
    if (_state != state) {
        _state = state;
        
        [self setNeedsDisplay:YES];
    }
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSColor * backgroundColor = nil;
    NSColor * textColor = [NSColor whiteColor];
    NSString * text = nil;
    
    switch (_state) {
        case DragViewStateReady:
            text = @"Drag Me to Desktop to Download";
            backgroundColor = [NSColor colorWithRed:14.0/255 green:192.0/255 blue:0 alpha:1.0];
            textColor = [NSColor whiteColor];
            break;
        case DragViewStateDragging:
            text = @"Dragging";
            backgroundColor = [NSColor colorWithWhite:0.8 alpha:1.0];
            break;
        case DragViewStateDownloading:
            text = @"Downloading...";
            backgroundColor = [NSColor colorWithWhite:0.8 alpha:1.0];
            break;
        case DragViewStateDownloadSuccess:
            text = @"Downloaded";
            backgroundColor = [NSColor colorWithRed:14.0/255 green:192.0/255 blue:0 alpha:1.0];
            break;
        default:
            break;
    }
    
    CGContextRef ctx = (CGContextRef)[NSGraphicsContext currentContext].graphicsPort;
    CGContextSetFillColorWithColor(ctx, backgroundColor.CGColor);
    CGContextFillRect(ctx, dirtyRect);
    
    NSDictionary * textAttributes = @{NSFontAttributeName: [NSFont boldSystemFontOfSize:16],
                                      NSForegroundColorAttributeName: textColor
                                      };
    
    NSSize size = [text sizeWithAttributes:textAttributes];
    
    NSRect textRect = NSMakeRect((dirtyRect.size.width - size.width) / 2, (dirtyRect.size.height - size.height) / 2, size.width, size.height);
    
    [text drawInRect:textRect withAttributes:textAttributes];
}

- (void)mouseDragged:(NSEvent *)event
{
    [super mouseDragged:event];
    
    NSFilePromiseProvider * provider = [[NSFilePromiseProvider alloc] initWithFileType:(NSString *)kUTTypeQuickTimeMovie delegate:self];
    NSDraggingItem * dragItem = [[NSDraggingItem alloc] initWithPasteboardWriter:provider];
    NSImage * image = [[NSImage alloc] initWithData:[self dataWithPDFInsideRect:[self bounds]]];
    
    [dragItem setDraggingFrame:self.bounds contents:image];
    
    [self beginDraggingSessionWithItems:@[dragItem] event:event source:self];
}

- (NSDragOperation)draggingSession:(NSDraggingSession *)session sourceOperationMaskForDraggingContext:(NSDraggingContext)context
{
    return NSDragOperationCopy;
}

- (void)draggingSession:(NSDraggingSession *)session willBeginAtPoint:(NSPoint)screenPoint
{
    self.state = DragViewStateDragging;
}

- (void)draggingSession:(NSDraggingSession *)session movedToPoint:(NSPoint)screenPoint
{
    self.state = DragViewStateDragging;
}

- (void)draggingSession:(NSDraggingSession *)session endedAtPoint:(NSPoint)screenPoint operation:(NSDragOperation)operation
{
    if (operation != NSDragOperationCopy) {
        self.state = DragViewStateReady;
    } else {
        self.state = DragViewStateDownloading;
    }
}

- (NSString *)filePromiseProvider:(NSFilePromiseProvider*)filePromiseProvider fileNameForType:(NSString *)fileType
{
    return @"test.mov";
}

- (void)filePromiseProvider:(NSFilePromiseProvider*)filePromiseProvider writePromiseToURL:(NSURL *)url completionHandler:(void (^)(NSError * __nullable errorOrNil))completionHandler
{
    _downloader = [[MPOFinderFileDownloader alloc] initWithUnderlyingDownloader:[[MPOSimpleFileDownloader alloc] init]];
    
    [_downloader downloadURL:[NSURL URLWithString:@"https://gslb.miaopai.com/stream/8uKjjX2yUd5cWmd0uulLloGIqW5XPkzR~vo15Q__.mp4?ssig=9078fe0ac41ccaef45e32e737909c1d7&time_stamp=1515587145862&cookie_id=&vend=1&os=3&partner=1&platform=2&cookie_id=&refer=miaopai&scid=8uKjjX2yUd5cWmd0uulLloGIqW5XPkzR%7Evo15Q__"] toPath:url.path progress:^(double progress) {
        
    } completion:^(NSError *error) {
        NSLog(@"complete! %@", error);
    }];
}

@end
