//
//  MainViewController.h
//  GPSLocator
//
//  Created by 梁谢超 on 14-10-14.
//  Copyright (c) 2014年 com.szmap. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "LocationTracker.h"

@interface MainViewController : UIViewController<CLLocationManagerDelegate,MFMailComposeViewControllerDelegate>
{
    int timeIntervel;
}
@property (weak, nonatomic) IBOutlet UITextField *m_stuNum;
@property (weak, nonatomic) IBOutlet UIButton *m_btnTimeIntervel;
@property (weak, nonatomic) IBOutlet UITextField *m_emailAddress;
@property (weak, nonatomic) IBOutlet UIButton *m_btnStartRec;

@property LocationTracker * locationTracker;
@end
