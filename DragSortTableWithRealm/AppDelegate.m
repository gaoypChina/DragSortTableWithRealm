
#import "AppDelegate.h"

#import "ViewController.h"

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
   
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    //主要是从有导航栏到无导航栏界面切换时，导航栏位置是黑的，非常刺眼。
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    

    ViewController *vc = [ViewController new];
    self.window.rootViewController = vc;

    return YES;
}


@end
