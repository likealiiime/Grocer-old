//
//  FoodName.h
//  Grocer
//
//  Created by Sherród Faulks on 3/19/11.
//  Copyright 2011 Soft Illuminations, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FoodName : NSObject {
    int _id;
}

- (id)initWithId:(int)theId specific:(NSString *)rawSpecific general:(NSString *)rawGeneral;
- (BOOL)hasGeneralName;

@property (nonatomic, readonly, getter = sqlId) int _id;
@property (nonatomic, retain, readonly) NSString *generalName;
@property (nonatomic, retain, readonly) NSString *specificName;
@property (nonatomic, retain, readonly) NSString *name;

@end
