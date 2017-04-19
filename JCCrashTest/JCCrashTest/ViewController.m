//
//  ViewController.m
//  JCCrashTest
//  计算Slide Address
//  Created by xingjian on 2017/4/17.
//  Copyright © 2017年 xingjian. All rights reserved.
//

#import "ViewController.h"
#import "JCCrashSymbolicViewController.h"
#import "JCDD.h"


@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *jcSourceTF;

@property (weak, nonatomic) IBOutlet UITextField *jcOffsetTF;

@property (weak, nonatomic) IBOutlet UITextField *jcResultTF;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
 
   // JCDD *jd = [[JCDD alloc]init];
    
    // Do any additional setup after loading the view, typically from a nib.
}
//转换
- (IBAction)jcCalculate:(id)sender
{
    if (self.jcSourceTF.text.length == 0) {
        [self jcShowTip:@"请输入异常栈地址"];
        return;
    }
    if (self.jcOffsetTF.text.length == 0) {
        [self jcShowTip:@"请输入地址偏移量"];
        return;
    }
    //拿到异常栈的地址，是十六进制的
    NSString *stackAddress = self.jcSourceTF.text;
    NSLog(@"十六进制的栈地址：---%@",stackAddress);
    //将十六进制转为十进制
    NSString *tenStackAddress = [self jcCalculaterSixteenToTen:stackAddress];
    NSLog(@"十进制的栈地址：---%@",tenStackAddress);

    //用十进制数据减去偏移量获得十进制的Slide Address
    NSInteger tenSlideAddress = tenStackAddress.integerValue - self.jcOffsetTF.text.integerValue;
    NSLog(@"十进制的slide address地址：---%ld",tenSlideAddress);

    //将十进制的slide address转为十六进制
    NSString *slideAddress = [self jcCalculateTenToSixteen:tenSlideAddress];
    NSLog(@"十六进制的slide address地址：---0x%@",slideAddress);
    //赋值到结果的TF
    self.jcResultTF.text = [NSString stringWithFormat:@"0x%@",slideAddress];
    
}
- (void)jcShowTip:(NSString *)msgStr
{
    UIAlertView * jcAlert = [[UIAlertView alloc]initWithTitle:@"JC提示" message:msgStr delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [jcAlert show];
}
//十进制转换为十六进制
- (NSString *)jcCalculateTenToSixteen:(long long int)tmpid
{
    NSString *nLetterValue;
    NSString *str =@"";
    uint16_t ttmpig;
    for (int i = 0; i<9; i++) {
        ttmpig=tmpid%16;
        tmpid=tmpid/16;
        switch (ttmpig)
        {
            case 10:
                nLetterValue =@"A";break;
            case 11:
                nLetterValue =@"B";break;
            case 12:
                nLetterValue =@"C";break;
            case 13:
                nLetterValue =@"D";break;
            case 14:
                nLetterValue =@"E";break;
            case 15:
                nLetterValue =@"F";break;
            default:
                nLetterValue = [NSString stringWithFormat:@"%u",ttmpig];
                
        }
        str = [nLetterValue stringByAppendingString:str];
        if (tmpid == 0) {
            break;
        }
        
    }
    return str;
}
- (IBAction)jcSymbolicCrashLog:(id)sender
{
    
    JCCrashSymbolicViewController * jcCrashVC = [[JCCrashSymbolicViewController alloc]initWithNibName:@"JCCrashSymbolicViewController" bundle:nil];
    jcCrashVC.slideAddress = self.jcResultTF.text;
    jcCrashVC.navigationItem.title = @"崩溃日志符号化";
    [self.navigationController pushViewController:jcCrashVC animated:YES];
    
}

//十六进制转换为十进制
- (NSString *)jcCalculaterSixteenToTen:(NSString *)sourceStr
{
    NSString * temp10 = [NSString stringWithFormat:@"%lu",strtoul([sourceStr UTF8String],0,16)];
    NSLog(@"十进制 10进制 %@",temp10);
  
    return temp10;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
