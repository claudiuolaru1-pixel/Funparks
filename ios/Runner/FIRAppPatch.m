#import <Foundation/Foundation.h>
#import <objc/runtime.h>

// Patches FIRApp to not crash on duplicate app registration
// This is needed because a Flutter plugin auto-configures Firebase
// before our Dart Firebase.initializeApp() call runs.

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
    Class firAppMetaClass = objc_getMetaClass("FIRApp");
    if (!firAppMetaClass) return;
    SEL sel = NSSelectorFromString(@"addAppToAppDictionary:");
    Method m = class_getClassMethod(firAppMetaClass, sel);
    if (!m) return;
    original_addAppToAppDictionary = method_getImplementation(m);
    method_setImplementation(m, (IMP)patched_addAppToAppDictionary);
}

@end