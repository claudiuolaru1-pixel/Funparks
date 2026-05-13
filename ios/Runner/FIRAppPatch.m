#import <Foundation/Foundation.h>
#import <objc/runtime.h>

static IMP original_addAppToAppDictionary = NULL;

static void patched_addAppToAppDictionary(id self, SEL _cmd, id app) {
    @try {
        ((void (*)(id, SEL, id))original_addAppToAppDictionary)(self, _cmd, app);
    } @catch (NSException *exception) {
        NSLog(@"[Funparks] Firebase duplicate app ignored: %@", exception.reason);
    }
}

@interface FIRAppPatch : NSObject
@end

@implementation FIRAppPatch

+ (void)load {
    // Must use NSClassFromString (the CLASS itself), not objc_getMetaClass
    Class firAppClass = NSClassFromString(@"FIRApp");
    if (!firAppClass) return;
    SEL sel = NSSelectorFromString(@"addAppToAppDictionary:");
    Method m = class_getClassMethod(firAppClass, sel);
    if (!m) return;
    original_addAppToAppDictionary = method_getImplementation(m);
    method_setImplementation(m, (IMP)patched_addAppToAppDictionary);
    NSLog(@"[Funparks] Firebase addAppToAppDictionary patched successfully");
}

@end