// App Information
#define AppName                 [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"]
#define AppVersion              [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]
#define AppDelegate(type)       ((type *)[[UIApplication sharedApplication] delegate])
#define NSAppDelegate(type)     ((type *)[[NSApplication sharedApplication] delegate])
#define SharedApp               [UIApplication sharedApplication]
#define NSSharedApp             [NSApplication sharedApplication]
#define Bundle                  [NSBundle mainBundle]
#define MainScreen              [UIScreen mainScreen]


#define DEVICE_IS_IPAD ( UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())

#define ONLY_IF_AT_LEAST_IOS_8(action) if ([[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] != NSOrderedAscending) { action; }

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

// Directories
static inline NSString *CachesDirectory() {
	return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}
static inline NSString *LibraryDirectory() {
	return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}
static inline NSString *DocumentsDirectory() {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

#define FloatTOString(x) [NSString stringWithFormat:@"%f",x]
#define TOString(x) [NSString stringWithFormat:@"%d",x]
#define LonglongTOString(x) [NSString stringWithFormat:@"%lld",x]
#define TONumber(x) [x intValue]
#define RemoveKey(x,y) [x removeObjectForKey:y]
#define ObjForKey(x,y) [x objectForKey:y]
#define IntObjForKey(x,y) [[x objectForKey:y] intValue]
#define SetObjKey(x,y,z) [x setObject:y forKey:z]

// Actions
#define OpenURL(urlString) [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:urlString]]

// Preferences
#define UDRemoveValue(x)        [[NSUserDefaults standardUserDefaults] removeObjectForKey:x]
#define UDValue(x)              [[NSUserDefaults standardUserDefaults] valueForKey:(x)]
#define UDBool(x)               [[NSUserDefaults standardUserDefaults] boolForKey:(x)]
#define UDInteger(x)            [[NSUserDefaults standardUserDefaults] integerForKey:(x)]
#define UDSetValue(x, y)        [[NSUserDefaults standardUserDefaults] setValue:(y) forKey:(x)]
#define UDSetBool(x, y)         [[NSUserDefaults standardUserDefaults] setBool:(y) forKey:(x)]
#define UDSetInteger(x, y)      [[NSUserDefaults standardUserDefaults] setInteger:(y) forKey:(x)]
#define UDObserveValue(x, y)    [[NSUserDefaults standardUserDefaults] addObserver:y forKeyPath:x options:NSKeyValueObservingOptionOld context:nil];
#define UDSync(ignored)         [[NSUserDefaults standardUserDefaults] synchronize]


// Debugging
#define StartTimer(ignored)     NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];
#define EndTimer(msg)           NSTimeInterval stop = [NSDate timeIntervalSinceReferenceDate]; NSLog(@"%@", [NSString stringWithFormat:@"%@ Time = %f", msg, stop-start]);


/* key, observer, object */
#define ObserveValue(x, y, z) [(z) addObserver:y forKeyPath:x options:NSKeyValueObservingOptionOld context:nil];

#define BARBUTTONSYSTEM(TYPE, SELECTOR) [[UIBarButtonItem alloc] initWithBarButtonSystemItem:TYPE target:self action:SELECTOR]

// User Interface Related
#define HexColor(c)                         [UIColor colorWithRed:((c>>24)&0xFF)/255.0 green:((c>>16)&0xFF)/255.0 blue:((c>>8)&0xFF)/255.0 alpha:((c)&0xFF)/255.0]
#define RGB(r, g, b)                        [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]
#define RGBA(r, g, b, a)                    [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define NSHexColor(c)                       [NSColor colorWithRed:((c>>24)&0xFF)/255.0 green:((c>>16)&0xFF)/255.0 blue:((c>>8)&0xFF)/255.0 alpha:((c)&0xFF)/255.0]
#define NSRGB(r, g, b)                      [NSColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]
#define NSRGBA(r, g, b, a)                  [NSColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define ShowNetworkActivityIndicator()      [UIApplication sharedApplication].networkActivityIndicatorVisible = YES
#define HideNetworkActivityIndicator()      [UIApplication sharedApplication].networkActivityIndicatorVisible = NO
#define SetNetworkActivityIndicator(x)      [UIApplication sharedApplication].networkActivityIndicatorVisible = x
#define NavBar                              self.navigationController.navigationBar
#define TabBar                              self.tabBarController.tabBar
#define NavBarHeight                        self.navigationController.navigationBar.bounds.size.height
#define TabBarHeight                        self.tabBarController.tabBar.bounds.size.height
#define ScreenWidth                         [[UIScreen mainScreen] bounds].size.width
#define ScreenHeight                        [[UIScreen mainScreen] bounds].size.height
#define TouchHeightDefault                  44
#define TouchHeightSmall                    32
#define ViewWidth(v)                        v.frame.size.width
#define ViewHeight(v)                       v.frame.size.height
#define ViewX(v)                            v.frame.origin.x
#define ViewY(v)                            v.frame.origin.y

#define LocalString(x) NSLocalizedString(x,x)
#define LocalUpperString(x) [NSLocalizedString(x,x) uppercaseString]

// Rect stuff
#define CGWidth(rect)                   rect.size.width
#define CGHeight(rect)                  rect.size.height
#define CGOriginX(rect)                 rect.origin.x
#define CGOriginY(rect)                 rect.origin.y
#define CGRectCenter(rect)              CGPointMake(NSOriginX(rect) + NSWidth(rect) / 2, NSOriginY(rect) + NSHeight(rect) / 2)
#define CGRectModify(rect,dx,dy,dw,dh)  CGRectMake(rect.origin.x + dx, rect.origin.y + dy, rect.size.width + dw, rect.size.height + dh)
#define NSLogRect(rect)                 NSLog(@"%@", NSStringFromCGRect(rect))
#define NSLogSize(size)                 NSLog(@"%@", NSStringFromCGSize(size))
#define NSLogPoint(point)               NSLog(@"%@", NSStringFromCGPoint(point))
