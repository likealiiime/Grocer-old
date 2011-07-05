//
//  FoodName.m
//  Grocer
//
//  Created by Sherród Faulks on 3/19/11.
//  Copyright 2011 Soft Illuminations, Inc. All rights reserved.
//

#import "FoodName.h"


@implementation FoodName
@synthesize _id;
@synthesize name=_name;
@synthesize generalName=_generalName;
@synthesize specificName=_specificName;

- (id)initWithId:(int)theId specific:(NSString *)rawSpecific general:(NSString *)rawGeneral {
    if ((self = [super init])) {
        _id = theId;
        _generalName = [[NSString alloc] initWithString: rawGeneral];
        _specificName = [[NSString alloc] initWithString: rawSpecific];
        if (rawGeneral.length == 0 && rawSpecific.length > 0) { // No General Name
            _name = [_specificName retain];
        } else if (rawGeneral.length > 0 && rawSpecific.length == 0) { // No Specific Name
            _name = [_generalName retain];
        } else {
            _name = [[NSString alloc] initWithFormat:@"%@ %@", _specificName, _generalName];
        }
        return self;
    } else {
        return nil;
    }
}

- (BOOL)hasGeneralName {
    return _generalName && [_generalName length] > 0;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ (#%d)", self.name, self.sqlId];
}

- (void) dealloc {
    [_name release];
    [_generalName release];
    [_specificName release];
    [super dealloc];
}
@end
