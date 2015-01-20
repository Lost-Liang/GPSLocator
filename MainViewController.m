//
//  MainViewController.m
//  GPSLocator
//
//  Created by 梁谢超 on 14-10-14.
//  Copyright (c) 2014年 com.szmap. All rights reserved.
//

#import "MainViewController.h"
#import "PublicFunction.h"


@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    timeIntervel = [PublicFunction getTimeIntervel] == 0 ? 1:[PublicFunction getTimeIntervel];
    if (timeIntervel == 1)
    {
        [_m_btnTimeIntervel setTitle:@"1分钟" forState:UIControlStateNormal];
    }else
    {
        [_m_btnTimeIntervel setTitle:@"5分钟" forState:UIControlStateNormal];
    }
    [PublicFunction setTimeIntervel:timeIntervel];
    _m_stuNum.text = [PublicFunction getStuNum];
    _m_emailAddress.text = [PublicFunction getEmailAddress];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark 修改时间间隔
- (IBAction)onChangeIntervelTime:(id)sender
{
    if (timeIntervel == 1)
    {
        [_m_btnTimeIntervel setTitle:@"5分钟" forState:UIControlStateNormal];
        timeIntervel = 5;
    }else
    {
        [_m_btnTimeIntervel setTitle:@"1分钟" forState:UIControlStateNormal];
        timeIntervel = 1;
    }
    [PublicFunction setTimeIntervel:timeIntervel];
}
#pragma mark 开始记录
- (IBAction)onStart:(id)sender
{
    if (_m_stuNum.text.length == 0)
    {
        UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"参数错误" message:@"请先填写您的学号" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertview show];
        return;
    }
    [PublicFunction setStuNum:_m_stuNum.text];
    if([_m_btnStartRec.titleLabel.text isEqualToString:@"开始记录"])
    {
        UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"开始记录" message:@"记录已经开始" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertview show];
        
        [_m_btnStartRec setTitle:@"记录中" forState:UIControlStateNormal];
    }
    
    self.locationTracker = [[LocationTracker alloc] init];
    [self.locationTracker startLocationTracking];
}

#pragma mark 完成编辑
- (IBAction)onEndOfEdit:(id)sender
{
    [sender resignFirstResponder];

    [PublicFunction setStuNum:_m_stuNum.text];
    [PublicFunction setEmailAddress:_m_emailAddress.text];
    
}
#pragma mark 发送邮件
- (IBAction)onSendEMail:(id)sender
{
    [PublicFunction onCreateKML];
    
    if(_m_emailAddress.text.length == 0)
    {
        UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"参数错误" message:@"请先填写Email地址" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertview show];
        return;
    }
    [self sendMailInApp];
}

- (void)sendMailInApp
{
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (!mailClass) {
        NSLog(@"当前系统版本不支持应用内发送邮件功能，您可以使用mailto方法代替");
        UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"参数错误" message:@"当前系统版本不支持应用内发送邮件功能，您可以使用mailto方法代替" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertview show];
        return;
    }
    if (![mailClass canSendMail])
    {
        NSLog(@"用户没有设置邮件账户");
        UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"参数错误" message:@"用户没有设置邮件账户" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertview show];
        return;
    }
    [self displayMailPicker];
}

//调出邮件发送窗口
- (void)displayMailPicker
{
    MFMailComposeViewController *mailPicker = [[MFMailComposeViewController alloc] init];
    mailPicker.mailComposeDelegate = self;
    
    //设置主题
    [mailPicker setSubject: @"轨迹记录文件"];
    //添加收件人
    NSArray *toRecipients = [NSArray arrayWithObject: _m_emailAddress.text];
    [mailPicker setToRecipients: toRecipients];
    
    NSMutableArray *filePaths = [PublicFunction getFileOfExtension:@"txt"];
    [filePaths addObjectsFromArray:[PublicFunction getFileOfExtension:@"kml"]];
    for (NSString *filePath in filePaths)
    {
        NSString *txtName = [filePath lastPathComponent];
        NSData *txtData = [NSData dataWithContentsOfFile:filePath];
        [mailPicker addAttachmentData: txtData mimeType: @"" fileName: txtName];
    }
    
    NSString *emailBody = @"老师，您好！这是我的轨迹记录文件。";
    [mailPicker setMessageBody:emailBody isHTML:YES];
    [self presentViewController:mailPicker animated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    //关闭邮件发送窗口
    [self dismissViewControllerAnimated:YES completion:nil];
    NSString *msg = nil;
    switch (result) {
        case MFMailComposeResultCancelled:
            msg = @"用户取消编辑邮件";
            break;
        case MFMailComposeResultSaved:
            msg = @"用户成功保存邮件";
            break;
        case MFMailComposeResultSent:
            msg = @"用户点击发送，将邮件放到队列中，还没发送";
            break;
        case MFMailComposeResultFailed:
            msg = @"用户试图保存或者发送邮件失败";
            break;
        default:
            msg = @"";
            break;
    }
    NSLog(msg,nil);
}



@end
