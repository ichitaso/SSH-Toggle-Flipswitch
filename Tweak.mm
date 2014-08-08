#import <UIKit/UIKit.h>
#import <SpringBoard/SpringBoard.h>
#import "FSSwitchPanel.h"

#define PREF_PATH @"/var/mobile/Library/Preferences/com.ichitaso.sshflipswitch.plist"
#define kPrefKey @"disableSSH"

static NSString *filePath = @"/var/tmp/sshstate";
static NSString *disablePath = @"/var/tmp/sshdisable";
static BOOL disableSSH;
static float disableRate;

%hook SpringBoard
- (void)applicationDidFinishLaunching:(id)application
{
    %orig;

    NSFileManager *manager = [NSFileManager defaultManager];
    
    if (disableSSH && ![manager fileExistsAtPath:filePath]) {
        [manager createFileAtPath:disablePath contents:nil attributes:nil];
    }
}

- (void)frontDisplayDidChange:(SBApplication *)app
{
    %orig;
    
    NSFileManager *manager = [NSFileManager defaultManager];
    
    if (disableSSH && [manager removeItemAtPath:disablePath error:nil]) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:disableRate]];
        [[FSSwitchPanel sharedPanel] applyActionForSwitchIdentifier:@"com.ichitaso.sshflipswitch"];
    }
}
%end

static void LoadSettings()
{
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:PREF_PATH];
    
    id disableSSHPref = [dict objectForKey:kPrefKey];
    disableSSH = disableSSHPref ? [disableSSHPref boolValue] : NO;
    
    id disableRatePref = [dict objectForKey:@"disableRate"];
    disableRate = disableRatePref ? [disableRatePref floatValue] : 15.0;
}

static void ChangeNotification(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    LoadSettings();
}

%ctor
{
	@autoreleasepool {
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, ChangeNotification, CFSTR("com.ichitaso.sshflipswitch.preferencechanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
        LoadSettings();
    }
}
