//
//  STCProxy.h
//  SafariStand
//
//  Created by Ivan Faiustov on 17/10/16.
//
//

#import <Cocoa/Cocoa.h>

@interface STCProxy : NSObject

@property (nonatomic, readonly) id object;

- (NSString *)proxiedClassName;
+ (NSString *)proxiedClassName;
- (instancetype)initWithObject:(id)object;

@end
