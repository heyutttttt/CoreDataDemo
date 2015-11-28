//
//  ViewController.m
//  CoreDataDemo
//
//  Created by RYAN on 15/11/11.
//  Copyright © 2015年 ryan. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>
#import "Father.h"
#import "AFNetworking.h"
#define ScrollViewLoopStatusResuing @"ScrollViewLoopStatusResuing"

static NSString *const baseURLString = @"https://dove-rest-dev.hnair.net:9600/dove-rest/rest/user/security/get_pub_key";

@interface ViewController ()<UIScrollViewDelegate>{
    NSString *status;
}

@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic, strong) NSArray *slideImages;

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, weak) UIImageView *currentView;
@property (nonatomic, weak) UIImageView *reusingView;

@property (nonatomic, assign) int index;
@property (nonatomic, assign) BOOL isLastScrollDirection;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    [self privateApi];
//    [self tryMember];
//    [self httpReq];
    [self realizeScrollLoop2];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)realizeScrollLoop2{
    self.slideImages = @[@"1.jpg",@"2.jpg",@"3.png",@"4.jpg",@"5.jpg"];
    status = ScrollViewLoopStatusResuing;
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.pagingEnabled = YES;
    scrollView.frame = self.view.bounds;
    scrollView.delegate = self;
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;
    
    CGSize scrollViewSize = scrollView.frame.size;
    scrollView.contentSize = CGSizeMake(3 * scrollViewSize.width, 0);
    scrollView.contentOffset = CGPointMake(scrollViewSize.width, 0);
    
    UIImageView *currentView = [[UIImageView alloc] init];
    currentView.tag = 0;
    currentView.frame = CGRectMake(scrollViewSize.width, 0, scrollViewSize.width, scrollViewSize.height);
    currentView.image = [UIImage imageNamed:@"1.jpg"];
    [scrollView addSubview:currentView];
    
    self.currentView = currentView;
    
    UIImageView *reusingView = [[UIImageView alloc] init];
    reusingView.tag = 0;
    reusingView.frame = CGRectMake(scrollViewSize.width, 0, scrollViewSize.width, scrollViewSize.height);
    [scrollView addSubview:reusingView];
    self.reusingView = reusingView;
    
    self.index = 0;
}

- (void)realizeScrollLoop{
    self.slideImages = @[@"1.jpg",@"2.jpg",@"3.png",@"4.jpg",@"5.jpg"];
    
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.pagingEnabled = YES;
    scrollView.frame = self.view.bounds;
    scrollView.delegate = self;
    [self.view addSubview:scrollView];
    
    [scrollView setContentSize:CGSizeMake(([self.slideImages count] + 2)*scrollView.frame.size.width, 0)];
    
    CGSize scrollViewSize = scrollView.frame.size;
    
    [self.slideImages enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIImageView *iv = [[UIImageView alloc] init];
        [iv setImage:[UIImage imageNamed:obj]];
        iv.frame = CGRectMake((idx +1)*scrollViewSize.width, 0, scrollViewSize.width, scrollViewSize.height);
        [scrollView addSubview:iv];
    }];
    
    // 将最后一张图片弄到第一张的位置
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.image = [UIImage imageNamed:
                       self.slideImages[[self.slideImages count] - 1]];
    imageView.frame = CGRectMake(0, 0, scrollViewSize.width, scrollViewSize.height);
    [scrollView addSubview:imageView];
    
    // 将第一张图片放到最后位置，造成视觉上的循环
    UIImageView *lastImageView = [[UIImageView alloc] init];
    lastImageView.image = [UIImage imageNamed:
                           self.slideImages[0]];
    lastImageView.frame = CGRectMake(scrollViewSize.width * ([self.slideImages count] + 1), 0, scrollViewSize.width, scrollViewSize.height);
    [scrollView addSubview:lastImageView];
    
    [scrollView setContentOffset:CGPointMake(scrollViewSize.width, 0)];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
//    NSInteger page = scrollView.contentOffset.x / scrollView.frame.size.width;
//    // 如果当前页是第0页就跳转到数组中最后一个地方进行跳转
//    if (page == 0) {
//        [scrollView setContentOffset:CGPointMake(scrollView.frame.size.width * ([[self slideImages] count]), 0)];
//    }else if (page == [[self slideImages] count] + 1){
//        // 如果是第最后一页就跳转到数组第一个元素的地点
//        [scrollView setContentOffset:CGPointMake(scrollView.frame.size.width, 0)];
//    }
    
    if (self.isLastScrollDirection) {
        self.index ++;
    }
    
    else{
        self.index --;
    }
    
    if (self.index < 0) {
        
        self.index = (int)(self.slideImages.count) - 1;
    }
    
    else if(self.index > [self.slideImages count]-1) {
        self.index = 0;
    }
    
    self.currentView.image = [UIImage imageNamed:[self.slideImages objectAtIndex:self.index]];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSLog(@"%@",NSStringFromCGPoint(scrollView.contentOffset));
    
    if ([status isEqualToString:ScrollViewLoopStatusResuing]) {
        if (scrollView.contentOffset.x > self.currentView.frame.origin.x) {
            NSInteger val = self.index + 1;
            if ( val >= self.slideImages.count - 1) {
                val = 0;
            }
            
            NSString *imgName = [self.slideImages objectAtIndex:val];
            self.reusingView.image = [UIImage imageNamed:imgName];
            CGRect frame = self.reusingView.frame;
            frame.origin.x = CGRectGetMinX(self.currentView.frame) + self.currentView.frame.size.width;
            self.reusingView.frame = frame;
            self.isLastScrollDirection = YES;
        }
        
        else{
            NSInteger val = self.index - 1;
            if (val < 0) {
                val = self.slideImages.count - 1;
            }
            
            NSString *imgName = [self.slideImages objectAtIndex:val];
            self.reusingView.image = [UIImage imageNamed:imgName];
            CGRect frame = self.reusingView.frame;
            frame.origin.x = 0;
            self.reusingView.frame = frame;
            self.isLastScrollDirection = NO;
        }
    }
}

- (void)httpReq{
//    NSURL *url = [NSURL URLWithString:baseURLString];
//    NSURLRequest *req = [NSURLRequest requestWithURL:url];
}

- (void)tryMember{
    Father *father = [[Father alloc] init];
    NSLog(@"%@",[father description]);
    
    unsigned int count = 0;
    Ivar *members = class_copyIvarList([father class], &count);
    for (int i=0; i<count; i++) {
        Ivar var = members[i];
        const char *memberName = ivar_getName(var);
        const char *memberType = ivar_getTypeEncoding(var);
        NSLog(@"%s----%s", memberName, memberType);
    }
    
    Ivar m_name = members[0];
    object_setIvar(father, m_name, @"heyutai");
    NSLog(@"after runtime:%@", [father description]);
    
//    object_getIvar(<#id obj#>, <#Ivar ivar#>)
//    object_setIvar(<#id obj#>, <#Ivar ivar#>, <#id value#>)
}

- (void)privateApi{
    NSString *className = NSStringFromClass([UIView class]);
    const char *cClassName = [className UTF8String];
    id theClass = objc_getClass(cClassName);
    unsigned int outCount;
    
    Method *m = class_copyMethodList(theClass, &outCount);
    
    NSLog(@"%d",outCount);
    
    for (int i=0; i<outCount; i++){
        SEL a = method_getName(*(m+i));
        NSString *sn = NSStringFromSelector(a);
        NSLog(@"%@",sn);
    }
}

- (void)queueTest{
    //    //后台
    //    dispatch_async(dispatch_get_global_queue(0, 0), ^{
    //
    //    });
    //
    //    //主线程
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //
    //    });
    //
    //    //一次执行
    //    static dispatch_once_t onceToken;
    //    dispatch_once(&onceToken, ^{
    //
    //    });
    //
    //    //延迟
    //    double delayInSeconds = 2.0f;
    //    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    //    dispatch_after(popTime, dispatch_get_main_queue(), ^{
    //
    //    });
    //
    //
    //    //自定义队列
    //    dispatch_queue_t queue1 = dispatch_queue_create("queue1", NULL);
    //    dispatch_async(queue1, ^{
    //
    //    });
    //
    //    dispatch_group_t group =  dispatch_group_create();
    //    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
    //            //并发执行进程1
    //    });
    //    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
    //            //并发执行进程2
    //    });
    //
    //    dispatch_group_notify(group, dispatch_get_global_queue(0, 0), ^{
    //        //汇总
    //    });
    
    //    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    //
    //        NSURL *url = [NSURL URLWithString:@"http://blog.csdn.net/samuelltk/article/details/9452203"];
    //        NSError *error;
    //
    //        NSString *data = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
    //        if (data != nil) {
    //            dispatch_async(dispatch_get_main_queue(), ^{
    //               NSLog(@"call back, the data is: %@", data);
    //            });
    //        }
    //
    //        else{
    //             NSLog(@"error when download:%@", error);
    //        }
    //
    //    });
    
    //    NSDate *date = [NSDate date];
    //    NSString *str = [date description];
    //    const char *queueName = [str UTF8String];
    //    dispatch_queue_t queue = dispatch_queue_create(queueName, NULL);
    //
    //    dispatch_async(queue, ^{
    //        [NSThread sleepForTimeInterval:6];
    //        NSLog(@"[NSThread sleepForTimeInterval:6];");
    //    });
    //
    //    dispatch_async(queue, ^{
    //        [NSThread sleepForTimeInterval:3];
    //        NSLog(@"[NSThread sleepForTimeInterval:3];");
    //    });
    //
    //    dispatch_async(queue, ^{
    //        [NSThread sleepForTimeInterval:1];
    //        NSLog(@"[NSThread sleepForTimeInterval:1];");
    //    });
    
    //    dispatch_queue_t queue = dispatch_queue_create("myQueue", NULL);
    //    uint64_t interval = 2 * NSEC_PER_SEC;
    //    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    //    dispatch_source_set_timer(self.timer, dispatch_time(DISPATCH_TIME_NOW, 0), interval, 0);
    //    dispatch_source_set_event_handler(self.timer, ^{
    //        NSLog(@"Timer %@",[NSThread currentThread]);
    //    });
    //    
    //    dispatch_resume(self.timer);
}
@end
