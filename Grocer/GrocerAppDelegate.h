//
//  GrocerAppDelegate.h
//  Grocer
//
//  Created by Sherród Faulks on 2/21/11.
//  Copyright 2011 Soft Illuminations, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"

@interface GrocerAppDelegate : NSObject <UIApplicationDelegate> {
    FMDatabase *_db;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@property (nonatomic, retain, readonly) FMDatabase *db;

@end
