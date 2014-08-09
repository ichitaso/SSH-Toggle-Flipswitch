#import <UIKit/UIKit.h>
#import <SpringBoard/SpringBoard.h>
#import "FSSwitchPanel.h"

#define PREF_PATH @"/var/mobile/Library/Preferences/com.ichitaso.sshflipswitch.plist"
#define kPrefKey @"disableSSH"

static NSString *filePath = @"/var/tmp/sshstate";
static BOOL disableSSH;
static float disableRate;
static BOOL alertEnabled;

%hook SpringBoard
- (void)applicationDidFinishLaunching:(id)application
{
    %orig;

    NSFileManager *manager = [NSFileManager defaultManager];
    
    if (disableSSH && ![manager fileExistsAtPath:filePath]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Disable SSH"
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:nil];
        
        [self performSelector:@selector(disableSSHTImer:) withObject:alert afterDelay:disableRate];
    }
}
%new(v@:)
-(void)disableSSHTImer:(id)alert
{
    [[FSSwitchPanel sharedPanel] applyActionForSwitchIdentifier:@"com.ichitaso.sshflipswitch"];
    if (alertEnabled) {
        [alert show];
        [alert release];
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.5f]];
        [alert dismissWithClickedButtonIndex:0 animated:YES];
    }
}
%end

static void LoadSettings()
{
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:PREF_PATH];
    
    id disableSSHPref = [dict objectForKey:kPrefKey];
    disableSSH = disableSSHPref ? [disableSSHPref boolValue] : NO;
    
    id alertEnabledPref = [dict objectForKey:@"alertEnabled"];
    alertEnabled = alertEnabledPref ? [alertEnabledPref boolValue] : YES;
    
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
