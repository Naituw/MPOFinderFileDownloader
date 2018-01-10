//
//  ViewController.m
//  DragAndDropToDownload
//
//  Created by 吴天 on 2018/1/10.
//  Copyright © 2018年 wutian. All rights reserved.
//

#import "ViewController.h"
#import "DragView.h"

@interface ViewController ()

@property (nonatomic, strong) DragView * dragView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dragView = [[DragView alloc] initWithFrame:NSZeroRect];
    [self.view addSubview:self.dragView];
}

- (void)viewWillLayout
{
    [super viewWillLayout];
    
    self.dragView.frame = NSInsetRect(self.view.bounds, 50, 50);
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    
    // Update the view, if already loaded.
}


@end

