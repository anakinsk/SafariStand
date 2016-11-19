//
//  STCModule.m
//  SafariStand

#if !__has_feature(objc_arc)
#error This file must be compiled with ARC
#endif


#import "SafariStand.h"

@implementation STCModule

static char modulePrefContext;


+ (BOOL)canRegisterModule
{
    return YES;
}

-(id)initWithStand:(id)core
{
    self = [super init];
    if (!self) return nil;
    //LOG(@"module init %@", NSStringFromClass([self class]));

    
    return self;
}


- (void)prefValue:(NSString*)key changed:(id)value
{
}

- (void)observePrefValue:(NSString*)key
{
    [[STCSafariStandCore ud]
     addObserver:self
     forKeyPath:key
     options:NSKeyValueObservingOptionNew
     context:&modulePrefContext];
}


- (void)observeSafariPrefValue:(NSString*)key
{
    [[NSUserDefaults standardUserDefaults]
     addObserver:self
     forKeyPath:key
     options:NSKeyValueObservingOptionNew
     context:&modulePrefContext];
}


- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if(context == &modulePrefContext){
    
        [self prefValue:keyPath changed:[change objectForKey:NSKeyValueChangeNewKey]];
    }else{
        [super observeValueForKeyPath:keyPath
                         ofObject:object 
                           change:change 
                          context:context];
    }
}

- (void)modulesDidFinishLoading:(id)core
{
    
}

@end
