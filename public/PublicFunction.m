//
//  PublicFunction.m
//  GPSLocator
//
//  Created by 梁谢超 on 14-10-30.
//  Copyright (c) 2014年 com.szmap. All rights reserved.
//

#import "PublicFunction.h"

@implementation PublicFunction

#pragma mark 记录学生学号
+ (void)setStuNum:(NSString*)strNum
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (strNum) {
        [defaults setObject:strNum forKey:@"STU_NUM"];
    }
}
#pragma mark 获取学生学号
+ (NSString*)getStuNum
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *strNum = [defaults objectForKey:@"STU_NUM"];
    return strNum;
}

+ (void)setEmailAddress:(NSString *)strEmail
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (strEmail) {
        [defaults setObject:strEmail forKey:@"STU_EMAIL"];
    }
    
}
+ (NSString*)getEmailAddress
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *strEmail = [defaults objectForKey:@"STU_EMAIL"];
    return strEmail;
}

+ (void)setTimeIntervel:(int)num
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:num forKey:@"TIMEINGERVEL"];
}
+ (int)getTimeIntervel
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    int num = [[defaults objectForKey:@"TIMEINGERVEL"] integerValue];
    return num;
}

+ (NSMutableArray*)getFileOfExtension:(NSString*)extension
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];//document path
    NSArray *tmplist = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:nil];
    NSMutableArray *filePaths = [[NSMutableArray alloc] init];
    for (NSString *filename in tmplist)
    {
        NSString *fileExtention = [filename pathExtension];
        if ([fileExtention isEqualToString:extension])
        {
            NSString *kmlFilePath = [documentsDirectory stringByAppendingPathComponent:filename];
            [filePaths addObject:kmlFilePath];
        }
    }
    return filePaths;
}

+ (NSString*)currentDate
{
    NSDate * senddate=[NSDate date];
    NSDateFormatter *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"yyyy-MM-dd"];
    NSString * locationString=[dateformatter stringFromDate:senddate];
    return locationString;
}
+ (void)createFile:(BOOL)bIsTxtFile
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *txtDirectory = [PublicFunction getFilePath:bIsTxtFile];
    BOOL res=[fileManager createFileAtPath:txtDirectory contents:nil attributes:nil];
    if (!res)//create file success
    {
        NSLog(@"创建文件失败");
    }
}
+ (void)writefile:(CLLocation*)newLocation isTxt:(BOOL)bIsTxtFile
{
    if (newLocation.coordinate.longitude == 0 && newLocation.coordinate.latitude == 0)//无效数据，不记录
    {
        return;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [self getFilePath:bIsTxtFile];
    if(![fileManager fileExistsAtPath:[self getFilePath:bIsTxtFile]])//文件不存在
    {
        [PublicFunction createFile:bIsTxtFile];
    }
    NSDate * date = [NSDate date];
    NSTimeInterval sec = [date timeIntervalSinceNow];
    NSDate * currentDate = [[NSDate alloc] initWithTimeIntervalSinceNow:sec];
    NSDateFormatter * df = [[NSDateFormatter alloc] init ];
    [df setDateFormat:@"MM/dd HH:mm:ss"];
    NSString * na = [df stringFromDate:currentDate];
    
    NSString *content = nil;
    if (bIsTxtFile)//TXT文件中存储时间信息
    {
        content = [NSString stringWithFormat:@"%f,%f,%@\n",newLocation.coordinate.longitude,newLocation.coordinate.latitude,na];
    }
    else//kml中存储高程信息，默认为0
    {
        content = [NSString stringWithFormat:@"%f,%f,0\n",newLocation.coordinate.longitude,newLocation.coordinate.latitude];
    }
    NSLog(content,nil);
    NSFileHandle  *outFile;
    NSData *buffer;
    
    outFile = [NSFileHandle fileHandleForWritingAtPath:filePath];
    
    if(outFile == nil)
    {
        NSLog(@"Open of file for writing failed");
    }
    
    //找到并定位到outFile的末尾位置(在此后追加文件)
    [outFile seekToEndOfFile];
    
    //读取inFile并且将其内容写到outFile中
    NSString *bs = [NSString stringWithFormat:@"%@",content];
    buffer = [bs dataUsingEncoding:NSUTF8StringEncoding];
    
    [outFile writeData:buffer];
    
    //关闭读写文件
    [outFile closeFile];
    
}
+ (NSString*)getFilePath:(BOOL)bIsTxtFile
{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];//document path
    NSString *fileName = nil;
    if (bIsTxtFile)
    {
        fileName = [NSString stringWithFormat:@"%@-%@.txt",[PublicFunction getStuNum], [PublicFunction currentDate]];//文件名形如 学号-2014/10/11.txt
    }else
    {
        fileName = [NSString stringWithFormat:@"%@-%@.prekml",[PublicFunction getStuNum], [PublicFunction currentDate]];//文件名形如 学号-2014/10/11.prekml
    }
    
    NSString *txtDirectory = [documentsDirectory stringByAppendingPathComponent:fileName];
    return txtDirectory;
}

+ (void)onCreateKML
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];//document path
    NSArray *tmplist = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:nil];
    int kmlFileNum = 0;
    for (NSString *filename in tmplist)
    {
        NSString *fileNameWithoutExtention = [filename stringByDeletingPathExtension];
        NSString *fileExtention = [filename pathExtension];
        NSString *kmlFilePath = [NSString stringWithFormat:@"%@/%@.kml",documentsDirectory,fileNameWithoutExtention];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileExtention isEqualToString:@"prekml"])//对于某个prekml源文件，且没有生成kml文件的，需要生成kml文件
        {
            NSString *txtFilePath = [documentsDirectory stringByAppendingPathComponent:filename];//txt文件路径
            NSString *txtContent = [NSString stringWithContentsOfFile:txtFilePath encoding:NSUTF8StringEncoding error:nil];//读取出txt文本内容
            NSString *kmlContent = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?><kml xmlns=\"http://www.opengis.net/kml/2.2\" xmlns:gx=\"http://www.google.com/kml/ext/2.2\" xmlns:kml=\"http://www.opengis.net/kml/2.2\" xmlns:atom=\"http://www.w3.org/2005/Atom\">                                    <Placemark><name>%@</name><LineString><tessellate>1</tessellate> <coordinates>%@</coordinates>                                    </LineString></Placemark></kml>",fileNameWithoutExtention,txtContent];//组装kml文本
            BOOL res=[fileManager createFileAtPath:kmlFilePath contents:nil attributes:nil];//创建mkl文件
            if(res)
            {
                BOOL res1 = [kmlContent writeToFile:kmlFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];//写入文本到kml文件
                if (!res1) {
                    NSLog(@"生成kml失败");
                }else
                {
                    kmlFileNum++;
                }
            }
        }
    }
}
@end
