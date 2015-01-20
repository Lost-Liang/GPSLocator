//
//  PublicFunction.h
//  GPSLocator
//
//  Created by 梁谢超 on 14-10-30.
//  Copyright (c) 2014年 com.szmap. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface PublicFunction : NSObject

+ (void)setStuNum:(NSString*)strNum;
+ (NSString*)getStuNum;
+ (void)setEmailAddress:(NSString *)strEmail;
+ (NSString*)getEmailAddress;
+ (void)setTimeIntervel:(int)num;
+ (int)getTimeIntervel;
+ (NSMutableArray*)getFileOfExtension:(NSString*)extension;
+ (NSString*)currentDate;
+ (void)createFile:(BOOL)bIsTxtFile;
+ (void)writefile:(CLLocation*)newLocation isTxt:(BOOL)bIsTxtFile;
+ (NSString*)getFilePath:(BOOL)bIsTxtFile;
+ (void)onCreateKML;

@end
