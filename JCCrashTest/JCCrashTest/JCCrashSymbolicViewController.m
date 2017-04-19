//
//  JCCrashSymbolicViewController.m
//  JCCrashTest
//
//  Created by xingjian on 2017/4/18.
//  Copyright © 2017年 xingjian. All rights reserved.
//

#import "JCCrashSymbolicViewController.h"
#import "ArchiveInfo.h"
#import "UUIDInfo.h"
#import "JCDD.h"

@interface JCCrashSymbolicViewController ()
/**
 *  archive 文件信息数组
 */
@property (copy) NSMutableArray<ArchiveInfo *> *archiveFilesInfo;

/**
 *  选中的 archive 文件信息
 */
@property (strong) ArchiveInfo *selectedArchiveInfo;

/**
 * 选中的 UUID 信息
 */
@property (strong) UUIDInfo *selectedUUIDInfo;


@property (weak, nonatomic) IBOutlet UITextView *jcLogTextView;
@property (nonatomic,strong)NSString * crashString;

@end

@implementation JCCrashSymbolicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    //读取日志文件
    NSString *jcPath = [[NSBundle mainBundle]pathForResource:@"UncaughtException" ofType:@"log"];
    NSString *jcLog = [NSString stringWithContentsOfFile:jcPath encoding:NSUTF8StringEncoding error:nil];
    self.jcLogTextView.text = jcLog;
    // Do any additional setup after loading the view.
}
- (IBAction)jcSymbolicEvent:(id)sender
{
    
    NSMutableArray *aArray = (NSMutableArray*)[self.jcLogTextView.text componentsSeparatedByString:@"\n"];
    //NSLog(@"拆分之后的数组：%@------拆分之后的数组个数：%ld",aArray,aArray.count);
    //for循环打印
    for (int i = 0; i<aArray.count; i++) {
        NSString * jcStr = [aArray objectAtIndex:i];
        //        NSLog(@"第%d项-----内容:%@",i+1,jcStr);
        if ([jcStr rangeOfString:@"+"].location!=NSNotFound) {
            // NSLog(@"第%d项-----内容:%@",i+1,jcStr);
            NSRange  jcRange = [jcStr rangeOfString:@"0x"];
            NSString * jcAdC = [jcStr substringWithRange:NSMakeRange(jcRange.location, 18)];
            //NSLog(@"第%d项-----内容:%@------出自：--%@",i+1,jcAdC,jcStr);
            //进行替换
            jcStr = [jcStr stringByReplacingOccurrencesOfString:jcAdC withString:@"xingjian666"];
            [aArray replaceObjectAtIndex:i withObject:jcStr];
            
        }
    }
    NSLog(@"数据替换之后：---%@",aArray);
    self.crashString = [aArray componentsJoinedByString:@","];
    self.crashString = [self.crashString stringByReplacingOccurrencesOfString:@"," withString:@"\n"];

    //获取用户电脑桌面路径
    NSString *jcUserDeskPath = [NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES) lastObject];
    NSArray  *userCompent = [jcUserDeskPath pathComponents];
    NSMutableArray * jcUserArr = [NSMutableArray array];
    [jcUserArr addObject:[userCompent objectAtIndex:1]];
    [jcUserArr addObject:[userCompent objectAtIndex:2]];
    [jcUserArr addObject:[userCompent lastObject]];
    NSString * jcDeskPath = [NSString pathWithComponents:jcUserArr];
    NSLog(@"用户路径:%@",userCompent);
    NSLog(@"用户桌面路径:----%@",jcUserDeskPath);
    NSLog(@"用户拼接路径:----%@",jcDeskPath);
    NSString *logDirectory = [jcDeskPath stringByAppendingPathComponent:@"JCCrashLog"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:logDirectory]) {
        NSError *error = nil;
        [fileManager createDirectoryAtPath:logDirectory withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"error = %@",[error localizedDescription]);
        }
    }
    
    NSString *logFilePath = [logDirectory stringByAppendingPathComponent:@"JCCrashSymbolic.log"];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setLocale:[[NSLocale alloc]initWithLocaleIdentifier:@"zh_CN"]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateStr = [formatter stringFromDate:[NSDate date]];
    
    NSString *crashString = [NSString stringWithFormat:@"%@---JC符号化之后:---\n%@",dateStr,self.crashString];
    
    //把错误日志写到文件中
    if (![fileManager fileExistsAtPath:logFilePath]) {
        [crashString writeToFile:logFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }else{
        NSFileHandle *outFile = [NSFileHandle fileHandleForWritingAtPath:logFilePath];
        [outFile seekToEndOfFile];
        [outFile writeData:[crashString dataUsingEncoding:NSUTF8StringEncoding]];
        [outFile closeFile];
    }

}
/**
 * 获取所有 dSYM 文件目录.
 */
- (NSMutableArray *)allDSYMFilePath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *archivesPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Developer/Xcode/Archives/"];
    NSURL *bundleURL = [NSURL fileURLWithPath:archivesPath];
    NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtURL:bundleURL
                                          includingPropertiesForKeys:@[NSURLNameKey, NSURLIsDirectoryKey]
                                                             options:NSDirectoryEnumerationSkipsHiddenFiles
                                                        errorHandler:^BOOL(NSURL *url, NSError *error)
                                         {
                                             if (error) {
                                                 NSLog(@"[Error] %@ (%@)", error, url);
                                                 return NO;
                                             }
                                             
                                             return YES;
                                         }];
    
    NSMutableArray *mutableFileURLs = [NSMutableArray array];
    for (NSURL *fileURL in enumerator) {
        NSString *filename;
        [fileURL getResourceValue:&filename forKey:NSURLNameKey error:nil];
        
        NSNumber *isDirectory;
        [fileURL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:nil];
        
        if ([filename hasPrefix:@"_"] && [isDirectory boolValue]) {
            [enumerator skipDescendants];
            continue;
        }
        
        //TODO:过滤部分没必要遍历的目录
        
        if ([filename hasSuffix:@".xcarchive"] && [isDirectory boolValue]){
            [mutableFileURLs addObject:fileURL.relativePath];
            [enumerator skipDescendants];
        }
    }
    return mutableFileURLs;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
