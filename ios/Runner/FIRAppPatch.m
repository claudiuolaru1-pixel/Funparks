#import <Foundation/Foundation.h>
#import <objc/runtime.h>

// Patches +[FIRApp addAppToAppDictionary:] to not crash on duplicate.
// Uses object_getClass to get the true metaclass, then class_getInstanceMethod
// on the metaclass (class methods are metaclass instance methods).

static IMP original_addAppToAppDictionary = NULL;

static void patched_addAppToAppDictionary(id self, SEL _cmd, id app) {
    @try {
        ((void (*)(id, SEL, id))original_addAppToAppDictionary)(self, _cmd, app);
    } @catch (NSException *exception) {
        NSLog(@"[Funparks] Firebase duplicate app silently ignored: %@", exception.reason);
    }
}

@interface FIRAppPatch : NSObject
@end

@implementation FIRAppPatch

+ (void)load {
    Class firAppClass = NSClassFromString(@"FIRApp");
    if (!firAppClass) {
        NSLog(@"[Funparks] FIRAppPatch: FIRApp class not found");
        return;
    }
    // Class methods live as instance methods on the metaclass
    Class metaClass = object_getClass(firAppClass);
    SEL sel = NSSelectorFromString(@"addAppToAppDictionary:");
    Method m = class_getInstanceMethod(metaClass, sel);
    if (!m) {
        NSLog(@"[Funparks] FIRAppPatch: method not found");
        return;
    }
    original_addAppToAppDictionary = method_getImplementation(m);
    method_setImplementation(m, (IMP)patched_addAppToAppDictionary);
    NSLog(@"[Funparks] FIRAppPatch: patch installed successfully");
}

@end