//
//  FoodViewController.h
//  Grocer
//
//  Created by Sherród Faulks on 6/11/11.
//  Copyright 2011 Soft Illuminations, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FoodName.h"
#import "FMDatabase.h"

@interface FoodViewController : UIViewController {
    FMDatabase *db;
    FoodName *food;
    NSString *aka;
    NSString *taste;
}

- (id) initWithFoodName:(FoodName *)newFoodName;

- (NSString *) sqlSelect:(NSString *)select;
- (IBAction) popViewController:(id)sender;

@end
