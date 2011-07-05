//
//  RootViewController.h
//  Grocer
//
//  Created by Sherród Faulks on 2/21/11.
//  Copyright 2011 Soft Illuminations, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMDatabase.h"

@interface RootViewController : UIViewController<UISearchDisplayDelegate> {
    FMDatabase *db;
    IBOutlet UIImageView *selectionImage;
}

- (IBAction)fadeOutSelectionImage:(id)sender;
- (IBAction)showSelectionImage:(id)sender;
- (IBAction)selectFamily:(id)sender;

- (NSString *) sqlSearch:(NSString *)select query:(NSString *)query;
- (void) filterNamesForQuery:(NSString *)query atIndex:(NSInteger)index;
- (UITableViewCell *)createCellWithReuseIdentifier:(NSString*)identifier;
    
@property (nonatomic, readonly) NSString *kingdom;

@property (nonatomic, retain) NSMutableArray *filteredNames;
@property (nonatomic) NSInteger savedScopeButtonIndex;
@property (nonatomic, copy) NSString *savedSearchTerm;
@property (nonatomic) BOOL searchWasActive;

@end
