//
//  CommonData.m
//  ThePlanner
//
//  Created by iOS Developer on 2/18/16.
//  Copyright (c) 2016 . All rights reserved.
//

#import "CommData.h"
#import "DSD_Salesforce-Swift.h"
#import "kchmacros.h"

@implementation CommData

+(void)showAlert:(NSString*)aMsg withTitle:(NSString*)aTitle Action:(void (^)(UIAlertAction *action))handler{
    UIAlertController *_viewAlert = [UIAlertController alertControllerWithTitle:aTitle message:aMsg preferredStyle:UIAlertControllerStyleAlert];
    [_viewAlert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:handler]];
    [AppDelegate(AppDelegate).window.rootViewController presentViewController:_viewAlert animated:YES completion:nil];
}

+(void)showAlert:(UIViewController*)vc withMsg:(NSString*)aMsg withTitle:(NSString*)aTitle Action:(void (^)(UIAlertAction *action))handler{
    UIAlertController *_viewAlert = [UIAlertController alertControllerWithTitle:aTitle message:aMsg preferredStyle:UIAlertControllerStyleAlert];
    [_viewAlert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:handler]];
    [vc presentViewController:_viewAlert animated:true completion:nil];
}

+(void)showAlert:(UIViewController*)vc withMsg:(NSString*)aMsg withTitle:(NSString*)aTitle withButtonTitle:(NSString*)buttonTitle Action:(void (^)(UIAlertAction *action))handler{
    UIAlertController *_viewAlert = [UIAlertController alertControllerWithTitle:aTitle message:aMsg preferredStyle:UIAlertControllerStyleAlert];
    [_viewAlert addAction:[UIAlertAction actionWithTitle:buttonTitle style:UIAlertActionStyleDefault handler:handler]];
    [vc presentViewController:_viewAlert animated:true completion:nil];
}

+ (NSString*)getDateHourString:(NSDate*)aDate{
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"M/d/yy ha"];
    return [formatter stringFromDate:aDate];
}

+ (NSDate*)getDateFromISO8610:(NSString*)aStrDate
{
    if((id)aStrDate == [NSNull null])
        return nil;
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss"];
    NSDate *date = [formatter dateFromString:aStrDate];
    return date;
}

+ (NSString*)getISO8610FromDate:(NSDate*)aDate
{
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy'-'MM'-'dd HH':'mm':'ss"];
    return [formatter stringFromDate:aDate];
}

+ (NSString*)getChartFormDate:(NSDate*)aDate
{
    if (aDate == nil) {
        return @"";
    }
    NSDateFormatter * _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateFormat:@"MM/dd"];

    return [_dateFormatter stringFromDate:aDate];
}

+ (NSDate*)getDateFromOnlyDate:(NSString*)aStrDate
{
    if((id)aStrDate == [NSNull null])
        return nil;
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    NSDate *date = [formatter dateFromString:aStrDate];
    return date;
}

+ (NSString*)getOnlyDateString:(NSDate*)aDate
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setTimeStyle:NSDateFormatterNoStyle];
    //[df setDateStyle:kCFDateFormatterMediumStyle];
    [df setDateFormat:@"MM/dd/YYYY"];
    return [df stringFromDate:aDate];
}

+ (NSString*)getOnlyTimeString:(NSDate*)aDate
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"HH:mm"];
    //[df setTimeStyle:NSDateFormatterShortStyle];
    //[df setDateStyle:NSDateFormatterNoStyle];
    return [df stringFromDate:aDate];
}

+ (NSString*)getOverlayUrl:(NSString*)astrUrl
{
    if ([astrUrl rangeOfString:@"http"].length > 0) {
        return astrUrl;
    }
    return [@"http://" stringByAppendingString:astrUrl];
}

+ (NSString*)getHttpUrl:(NSString*)aBaseString{
    if ([aBaseString hasPrefix:@"http"]) {
        return aBaseString;
    }
    return [NSString stringWithFormat:@"http://%@",aBaseString];
}

+ (NSString*)getCallPhoneNumString:(NSString*)aOriginal{
    return [aOriginal stringByReplacingOccurrencesOfString:@" " withString:@""];
}

+ (CLLocationDistance)calcDistance:(CLLocation*)aLoc1 Sec:(CLLocation*)aLoc2{
    CLLocationDistance distance = [aLoc1 distanceFromLocation:aLoc2];
    return distance;
}

+ (BOOL)checkEmailType:(NSString*)aStrEmail
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailPredicate =[NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    BOOL myStringMatchesRegEx=[emailPredicate evaluateWithObject:aStrEmail];
    return myStringMatchesRegEx;
}

+ (BOOL)checkSpecialString:(NSString*)aStrEmail
{
    NSString *emailRegex = @"^[0-9a-zA-ZäöüÄÖÜ?\\s]*$";
    NSPredicate *emailPredicate =[NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    BOOL myStringMatchesRegEx = [emailPredicate evaluateWithObject:aStrEmail];
    return myStringMatchesRegEx;
}

+ (BOOL)checkPasswdType:(NSString*)aStrPasswd
{
    if(aStrPasswd.length < 6)
    {
        return false;
    }
    return true;
}

+ (BOOL)checkValidType:(NSString*)aStrValue{
    if (aStrValue.length == 0) {
        return NO;
    }
    return YES;
}

+ (NSString*)getDeviceUDID{
    
    return [UIDevice currentDevice].identifierForVendor.UUIDString;
}

+ (NSString*)convertDeviceTokenToString:(NSData *)deviceTokenData {
    
    const unsigned *tokenBytes = [deviceTokenData bytes];
    NSString *hexToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                          ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                          ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                          ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
    
    return hexToken;
}

+ (NSString*)getFilePathAppendedByDocumentDir:(NSString *)filePath {
    
    NSString *documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *localFilePath = [documentsDirectoryPath stringByAppendingPathComponent:filePath];
    return localFilePath;
}

+ (NSString*)getFilePathAppendedByCacheDir:(NSString *)filePath {
    
    NSString *cacheDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *localFilePath = [cacheDirectoryPath stringByAppendingPathComponent:filePath];
    return localFilePath;
}

+ (long long)getFileSize:(NSString *)filePath {

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:filePath error:&error];
    if (fileAttributes == nil) {
        return 0;
    }

    NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
    long long fileSize = [fileSizeNumber unsignedLongLongValue];
    return fileSize;
}


+ (BOOL)IsExistingFileAtPath:(NSString*)filePath {
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    return fileExists;
}

+ (BOOL)deleteFileIfExist:(NSString *)filePath {
    
    NSLog(@"%@", filePath);
    NSString *documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    if ([documentsDirectoryPath isEqualToString:filePath]) {
        return true;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    if ([fileManager fileExistsAtPath:filePath] == true) {
        return [fileManager removeItemAtPath:filePath error:&error];
    }
    return NO;
}

+ (void)createDirectory:(NSString *)filePath {

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:&error];
}

void SKScanHexColor(NSString * hexString, float * red, float * green, float * blue, float * alpha) {
    NSString *cleanString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    if([cleanString length] == 3) {
        cleanString = [NSString stringWithFormat:@"%@%@%@%@%@%@",
                       [cleanString substringWithRange:NSMakeRange(0, 1)],[cleanString substringWithRange:NSMakeRange(0, 1)],
                       [cleanString substringWithRange:NSMakeRange(1, 1)],[cleanString substringWithRange:NSMakeRange(1, 1)],
                       [cleanString substringWithRange:NSMakeRange(2, 1)],[cleanString substringWithRange:NSMakeRange(2, 1)]];
    }
    if([cleanString length] == 6) {
        cleanString = [cleanString stringByAppendingString:@"ff"];
    }
    
    unsigned int baseValue;
    [[NSScanner scannerWithString:cleanString] scanHexInt:&baseValue];
    
    if (red) { *red = ((baseValue >> 24) & 0xFF)/255.0f; }
    if (green) { *green = ((baseValue >> 16) & 0xFF)/255.0f; }
    if (blue) { *blue = ((baseValue >> 8) & 0xFF)/255.0f; }
    if (alpha) { *alpha = ((baseValue >> 0) & 0xFF)/255.0f; }
}

UIColor* SKColorFromHexString(NSString * hexString) {
    float red, green, blue, alpha;
    SKScanHexColor(hexString, &red, &green, &blue, &alpha);
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (UIColor*) colorFromHexString:(NSString *)hexString {
    NSString *cleanString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    if([cleanString length] == 3) {
        cleanString = [NSString stringWithFormat:@"%@%@%@%@%@%@",
                       [cleanString substringWithRange:NSMakeRange(0, 1)],[cleanString substringWithRange:NSMakeRange(0, 1)],
                       [cleanString substringWithRange:NSMakeRange(1, 1)],[cleanString substringWithRange:NSMakeRange(1, 1)],
                       [cleanString substringWithRange:NSMakeRange(2, 1)],[cleanString substringWithRange:NSMakeRange(2, 1)]];
    }
    if([cleanString length] == 6) {
        cleanString = [NSString stringWithFormat:@"ff%@", cleanString];
    }
    
    unsigned int baseValue;
    [[NSScanner scannerWithString:cleanString] scanHexInt:&baseValue];
    
    float alpha = ((baseValue >> 24) & 0xFF)/255.0f;
    float red = ((baseValue >> 16) & 0xFF)/255.0f;
    float green = ((baseValue >> 8) & 0xFF)/255.0f;
    float blue = ((baseValue >> 0) & 0xFF)/255.0f;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (UIImage*) getRotatedImage:(UIImage*)srcImage by:(CGFloat)degrees {

    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,srcImage.size.width, srcImage.size.height)];

    CGAffineTransform t = CGAffineTransformMakeRotation(degrees * M_PI / 180);
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;

    //Create the bitmap context
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();

    //Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);

    //Rotate the image context
    CGContextRotateCTM(bitmap, (degrees * M_PI / 180));

    //Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-srcImage.size.width / 2, -srcImage.size.height / 2, srcImage.size.width, srcImage.size.height), [srcImage CGImage]);

    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage*) getRotatedImage:(UIImage*)srcImage {

    UIImage *imageToDisplay = [UIImage imageWithCGImage:[srcImage CGImage]
                                                 scale:[srcImage scale]
                                           orientation: UIImageOrientationUp];

    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,imageToDisplay.size.width, imageToDisplay.size.height)];

    //UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    UIImageOrientation orientation = srcImage.imageOrientation;
    double degrees = 0;
    if (orientation == UIImageOrientationDown) {
        degrees = 180;
    }
    else if (orientation == UIImageOrientationUp) {
        degrees = 0;
    }
    else if (orientation == UIImageOrientationLeft) {
        degrees = -90;
    }
    else if (orientation == UIImageOrientationRight) {
        degrees = 90;
    }

    CGAffineTransform t = CGAffineTransformMakeRotation(degrees * M_PI / 180);
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;

    //Create the bitmap context
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();

    //Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);

    //Rotate the image context
    CGContextRotateCTM(bitmap, (degrees * M_PI / 180));

    //Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-imageToDisplay.size.width / 2, -imageToDisplay.size.height / 2, imageToDisplay.size.width, imageToDisplay.size.height), [imageToDisplay CGImage]);

    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
