//
//  RFRateMe.m
//  RFRateMeDemo
//
//  Created by Ricardo Funk on 1/2/14.
//  Copyright (c) 2014 Ricardo Funk. All rights reserved.
//

#import "RFRateMe.h"
#import "UIAlertView+NSCookbook.h"
#import "CommData.h"

#define kNumberOfDaysUntilShowAgain 5
#define kAppStoreAddress @"itms-apps://itunes.apple.com/app/id1104894238"
#define kAppName @"'密码相册'"

@implementation RFRateMe

+(void)showRateAlert {
    
    //If rate was completed, we just return if True
    BOOL rateCompleted = [[NSUserDefaults standardUserDefaults] boolForKey:@"RateCompleted"];
    if (rateCompleted) return;
    
    //Check if the user asked not to be prompted again for 3 days (remind me later)
    BOOL remindMeLater = [[NSUserDefaults standardUserDefaults] boolForKey:@"RemindMeLater"];
    
    if (remindMeLater) {
        
        NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
        [DateFormatter setDateFormat:@"yyyy-MM-dd"];
        
        NSString *start = [[NSUserDefaults standardUserDefaults] objectForKey:@"StartDate"];
        NSString *end = [DateFormatter stringFromDate:[NSDate date]];
        
        NSDateFormatter *f = [[NSDateFormatter alloc] init];
        [f setDateFormat:@"yyyy-MM-dd"];
        NSDate *startDate = [f dateFromString:start];
        NSDate *endDate = [f dateFromString:end];
        
        NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit
                                                            fromDate:startDate
                                                              toDate:endDate
                                                             options:0];
        
        if ((long)[components day] <= kNumberOfDaysUntilShowAgain) return;
        
    }
    
    //Show rate alert
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(kAppName, @"")
                                                        message:[NSString stringWithFormat:@"去吐槽下吧，让我们改进的更好"]
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:NSLocalizedString(@"好的,现在就去", @""),NSLocalizedString(@"下次再去吧",@""), nil];
    
    [alertView showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
        
        switch (buttonIndex) {
                case 0:
                
                NSLog(@"Rate it now");
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"RateCompleted"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kAppStoreAddress]];
                
                break;
            case 1:
                
                NSLog(@"Remind me later");
                NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                NSDate *now = [NSDate date];
                [[NSUserDefaults standardUserDefaults] setObject:[dateFormatter stringFromDate:now] forKey:@"StartDate"];
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"RemindMeLater"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                break;
        }
    }];
}


+(void)showRateAlertAfterTimesOpened:(int)times {
    //Thanks @kylnew for feedback and idea!
    
    BOOL rateCompleted = [[NSUserDefaults standardUserDefaults] boolForKey:@"RateCompleted"];
    if (rateCompleted) return;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    int timesOpened = [defaults integerForKey:@"timesOpened"];
    [defaults setInteger:timesOpened+1 forKey:@"timesOpened"];
    [defaults synchronize];
    NSLog(@"App has been opened %d times", [defaults integerForKey:@"timesOpened"]);
    if([defaults integerForKey:@"timesOpened"] >= times){
        [RFRateMe showRateAlert];
    }
}

@end
