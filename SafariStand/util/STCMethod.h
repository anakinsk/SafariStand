//
//  STCMethod.h
//  SafariStand
//
//  Created by Ivan Faiustov on 18/10/16.
//
//

#import <Foundation/Foundation.h>

@interface STCMethod : NSObject

@property (nonatomic) SEL selector;
@property BOOL classMethod;
@property IMP implementation;

- (instancetype)initWithSEL:(SEL)sel classMethod:(BOOL)classMethod;

@end
