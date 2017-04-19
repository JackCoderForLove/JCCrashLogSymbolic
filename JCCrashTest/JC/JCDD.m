//
//  JCDD.m
//  JCCrashTest
//
//  Created by xingjian on 2017/4/18.
//  Copyright © 2017年 xingjian. All rights reserved.
//

#import "JCDD.h"

@implementation JCDD
- (NSString *)runCommand:(NSString *)commandToRun
{
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/sh"];
    
    NSArray *arguments = @[@"-c",
                           [NSString stringWithFormat:@"%@", commandToRun]];
    //    NSLog(@"run command:%@", commandToRun);
    [task setArguments:arguments];
    
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    
    NSFileHandle *file = [pipe fileHandleForReading];
    
    [task launch];
    
    NSData *data = [file readDataToEndOfFile];
    
    NSString *output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return output;
}
- (NSString *)runAbc:(NSString *)jd
{
    jd = [jd stringByAppendingString:@"你妈啦个"];
}
@end
