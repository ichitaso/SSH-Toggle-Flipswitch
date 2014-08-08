#import <Foundation/Foundation.h>
#import <Foundation/NSTask.h>

#define PREF_PATH @"/var/mobile/Library/Preferences/com.ichitaso.sshflipswitch.plist"
#define kPrefKey @"disableSSH"

static NSString *filePath = @"/var/tmp/sshstate";
static BOOL sshEnabled;

int main(int argc, char **argv, char **envp) {
    @autoreleasepool {
        NSFileManager *manager = [NSFileManager defaultManager];
        
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:filePath];
        NSData *data = [fileHandle readDataToEndOfFile];
        NSString *str = [[NSString alloc]initWithData:data
                                             encoding:NSUTF8StringEncoding];
        if ([str hasPrefix:@"1"]) {
            sshEnabled = YES;
        } else if (![manager fileExistsAtPath:filePath]) {
            sshEnabled = YES;
        } else {
            sshEnabled = NO;
        }
        [fileHandle closeFile];
        
        NSTask *task = [[NSTask alloc] init];
        [task setLaunchPath: @"/bin/launchctl"];
        NSArray *unload = [NSArray arrayWithObjects: @"unload", @"/Library/LaunchDaemons/com.openssh.sshd.plist", nil];
        NSArray *load = [NSArray arrayWithObjects: @"load", @"/Library/LaunchDaemons/com.openssh.sshd.plist", nil];
        
        NSString *str1 = @"0\n";
        NSString *str2 = @"1\n";
        
        if (sshEnabled) {
            [manager removeItemAtPath:filePath error:nil];
            [manager createFileAtPath:filePath contents:nil attributes:nil];
            [str1 writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
            
            [task setArguments:unload];
            [task launch];
        } else {
            [manager removeItemAtPath:filePath error:nil];
            [manager createFileAtPath:filePath contents:nil attributes:nil];
            [str2 writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
            
            [task setArguments:load];
            [task launch];
        }
    }
    return 0;
}