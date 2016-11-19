//
//  STCClass.m
//  SafariStand
//
//  Created by Ivan Faiustov on 24/10/2016.
//
//

#import "STCClass.h"

@interface STCClass()

@property (nonatomic) BOOL metaClass;
@property (nonatomic) Class classObject;

@end

@implementation STCClass

+ (instancetype)classWithObjcClassName:(NSString *)className isMetaClass:(BOOL)metaClass {
    NSParameterAssert(className);
    
    STCClass *class = [[self alloc] init];
    class.metaClass = metaClass;
    class.classObject = metaClass ? objc_getMetaClass([className UTF8String]) : NSClassFromString(className);
    
    return class;
}

- (Method)objcMethodForSelector:(SEL)selector {
    Method method = self.metaClass ? class_getClassMethod(self.classObject, selector) : class_getInstanceMethod(self.classObject, selector);
    
    return method;
}

- (Method)addMethodWithSel:(SEL)sel imp:(IMP)imp andSignature:(const char *)types {
    class_addMethod(self.classObject, sel, imp, types);
    
    Method newMethod = self.metaClass ? class_getClassMethod(self.classObject, sel) : class_getInstanceMethod(self.classObject, sel);
    
    return newMethod;
}

@end
