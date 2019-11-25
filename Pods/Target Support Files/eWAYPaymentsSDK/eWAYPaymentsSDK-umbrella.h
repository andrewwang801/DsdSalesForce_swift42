#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "Address.h"
#import "CardDetails.h"
#import "Customer.h"
#import "EncryptValuesResponse.h"
#import "Enumerated.h"
#import "eWAYSDK.h"
#import "LineItem.h"
#import "NVpair.h"
#import "Payment.h"
#import "RapidAPI+ApplePay.h"
#import "RapidAPI.h"
#import "Reachability.h"
#import "ShippingDetails.h"
#import "SubmitPaymentResponse.h"
#import "Transaction.h"
#import "UserMessageResponse.h"

FOUNDATION_EXPORT double eWAYPaymentsSDKVersionNumber;
FOUNDATION_EXPORT const unsigned char eWAYPaymentsSDKVersionString[];

