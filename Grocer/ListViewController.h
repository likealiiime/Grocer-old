//
//  ListViewController.h
//  Grocer
//
//  Created by Sherród Faulks on 2/21/11.
//  Copyright 2011 Soft Illuminations, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMDatabase.h"

@interface ListViewController : UIViewController<UISearchDisplayDelegate> {
    FMDatabase *db;
    NSMutableArray *names;
}

- (id)initWithFamily:(NSString *)theFamily inKingdom:(NSString *)theKingdom;

- (NSString *) sqlSelect:(NSString *)select where:(NSString *)conditions;
- (NSString *) sqlSearch:(NSString *)select query:(NSString *)query where:(NSString *)conditions;
- (void) filterNamesForQuery:(NSString *)query inScopeNamed:(NSString *)scope atIndex:(NSInteger)index;

@property (nonatomic, retain, readonly) NSString *family;
@property (nonatomic, retain, readonly) NSString *kingdom;

@property (nonatomic, retain) NSMutableArray *filteredNames;
/*@property (nonatomic) NSInteger savedScopeButtonIndex;
@property (nonatomic, copy) NSString *savedSearchTerm;
@property (nonatomic) BOOL searchWasActive;*/

@end
