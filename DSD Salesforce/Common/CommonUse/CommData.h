//
//  CommonData.h
//  TiimTalk
//
//  Created by kim chance on 12. 6. 20..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface CommData : NSObject

+(void)showAlert:(NSString*)aMsg withTitle:(NSString*)aTitle Action:(void (^)(UIAlertAction *action))handler;
+(void)showAlert:(UIViewController*)vc withMsg:(NSString*)aMsg withTitle:(NSString*)aTitle Action:(void (^)(UIAlertAction *action))handler;
+(void)showAlert:(UIViewController*)vc withMsg:(NSString*)aMsg withTitle:(NSString*)aTitle withButtonTitle:(NSString*)buttonTitle Action:(void (^)(UIAlertAction *action))handler;

+ (NSString*)getISO8610FromDate:(NSDate*)aDate;
+ (NSDate*)getDateFromISO8610:(NSString*)aStrDate;
+ (NSString*)getChartFormDate:(NSDate*)aDate;
+ (NSString*)getOnlyDateString:(NSDate*)aDate;
+ (NSString*)getOnlyTimeString:(NSDate*)aDate;
+ (NSDate*)getDateFromOnlyDate:(NSString*)aStrDate;
+ (NSString*)getHttpUrl:(NSString*)aBaseString;
+ (NSString*)getCallPhoneNumString:(NSString*)aOriginal;
+ (CLLocationDistance)calcDistance:(CLLocation*)aLoc1 Sec:(CLLocation*)aLoc2;
+ (NSString*)getDateHourString:(NSDate*)aDate;

+ (BOOL)checkValidType:(NSString*)aStrValue;
+ (BOOL)checkEmailType:(NSString*)aStrEmail;
+ (BOOL)checkSpecialString:(NSString*)aStrEmail;
+ (BOOL)checkPasswdType:(NSString*)aStrPasswd;

+ (NSString*)getDeviceUDID;
+ (NSString*)convertDeviceTokenToString:(NSData *)deviceTokenData;

+ (NSString*)getFilePathAppendedByDocumentDir:(NSString *)filePath;
+ (NSString*)getFilePathAppendedByCacheDir:(NSString *)filePath;
+ (long long)getFileSize:(NSString *)filePath;
+ (void)createDirectory:(NSString *)filePath;
+ (BOOL)IsExistingFileAtPath:(NSString*)filePath;
+ (BOOL)deleteFileIfExist:(NSString *)filePath;

+ (UIColor*)colorFromHexString:(NSString *)hexString;
+ (UIImage*) getRotatedImage:(UIImage*)srcImage by:(CGFloat)degrees;
+ (UIImage*) getRotatedImage:(UIImage*)srcImage;

@end
 
