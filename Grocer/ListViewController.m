//
//  ListViewController.m
//  Grocer
//
//  Created by Sherród Faulks on 2/21/11.
//  Copyright 2011 Soft Illuminations, Inc. All rights reserved.
//

#import "ListViewController.h"
#import "GrocerAppDelegate.h"
#import "FMResultSet.h"
#import "CustomNavigationBar.h"
#import "FoodName.h"
#import "FoodViewController.h"

@interface ListViewController ()
    - (void)configureNormalCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
    - (void)configureSearchDisplayCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
    - (UITableViewCell *)createNormalCellWithReuseIdentifier:(NSString*)identifier;
    - (UITableViewCell *)createSearchDisplayCellWithReuseIdentifier:(NSString*)identifier;
@end

@implementation ListViewController

@synthesize family=_family;
@synthesize kingdom=_kingdom;

@synthesize filteredNames=_filteredNames;
/*@synthesize savedSearchTerm=_savedSearchTerm;
@synthesize searchWasActive=_searchWasActive;
@synthesize savedScopeButtonIndex=_savedScopeButtonIndex;*/

#pragma mark -
#pragma mark Object Lifecycle Methods

- (id)initWithFamily:(NSString *)theFamily inKingdom:(NSString *)theKingdom {
    if ((self = [super initWithNibName:@"ListViewController" bundle:nil])) {
        _family = [theFamily retain];
        _kingdom = [theKingdom retain];
        db = ((GrocerAppDelegate *)[[UIApplication sharedApplication] delegate]).db;
        names = [[NSMutableArray alloc] init];
        NSString *conditions = [NSString stringWithFormat:@"kingdom = \"%@\" AND family = \"%@\"", self.kingdom, self.family];
        FMResultSet *results = [db executeQuery:[self sqlSelect:@"id, specific, general"
                                                          where:conditions]];
        while ([results next]) {
            FoodName *food = [[FoodName alloc] initWithId:[results intForColumn:@"id"]
                                                 specific:[results stringForColumn:@"specific"]
                                                  general:[results stringForColumn:@"general"]];
            //NSLog(@"%@", food);
            [names addObject:food];
            [food release];
        }
        [results close];
        self.filteredNames = [NSMutableArray arrayWithCapacity:[names count]];
        
        return self;
    } else {
        return nil;
    }
}

- (void)dealloc {
    [_family release];
    [_kingdom release];
    [names release];
    [_filteredNames release];
    [super dealloc];
}

#pragma mark -
#pragma mark SQL methods

- (NSString *) sqlSelect:(NSString *)select where:(NSString *)conditions {
    return [NSString stringWithFormat:@"SELECT %@ FROM foods WHERE %@ ORDER BY (specific || general) ASC",
            select, conditions];
}
- (NSString *) sqlSearch:(NSString *)select query:(NSString *)query where:(NSString *)conditions {
    return [NSString stringWithFormat:@"SELECT %@ FROM foods WHERE (specific || general) LIKE \"%%%@%%\" AND %@ ORDER BY (specific || general) ASC",
            select, query, conditions];
}

#pragma mark -
#pragma mark View Lifecycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.family;
    
    self.navigationItem.titleView = [[UIView alloc] initWithFrame:CGRectMake(0,0, 150,44)];
    self.navigationItem.titleView.backgroundColor = [UIColor clearColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,7, 150,40)];
    label.text = self.title;
    label.textColor = [UIColor colorWithWhite:0.15 alpha:1];
    label.shadowColor = [UIColor colorWithWhite:0.78 alpha:1];
    label.shadowOffset = CGSizeMake(0, 1);
    label.textAlignment = UITextAlignmentCenter;
    label.font = [UIFont fontWithName:@"MoanHand" size:32.0];
    label.opaque = NO;
    label.backgroundColor = [UIColor clearColor];
    label.numberOfLines = 1;
    label.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    [self.navigationItem.titleView addSubview:label];
    [label release];
    
    CustomNavigationBar *customNavigationBar = (CustomNavigationBar *)self.navigationController.navigationBar;
    [customNavigationBar setBackgroundWith:[UIImage imageNamed:@"ListViewUINavigationBar"]];
    customNavigationBar.tintColor = [UIColor brownColor];
    
    self.searchDisplayController.searchBar.scopeButtonTitles = [NSArray arrayWithObjects:self.family, [NSString stringWithFormat:@"%@s", self.kingdom], @"All", nil];
    [self updateSearchBarPlaceholderWithScopeAtIndex:self.searchDisplayController.searchBar.selectedScopeButtonIndex];
    /*
    if (self.savedSearchTerm) {
        // Restore search settings if they were saved in didReceiveMemoryWarning.
        [self.searchDisplayController setActive:self.searchWasActive];
        [self.searchDisplayController.searchBar setSelectedScopeButtonIndex:self.savedScopeButtonIndex];
        [self.searchDisplayController.searchBar setText:self.savedSearchTerm];
        self.savedSearchTerm = nil;
    }*/
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    UITableView *tableView = (UITableView *)[self.view viewWithTag:1];
    [tableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    NSIndexPath *path = [tableView indexPathForSelectedRow];
    [tableView deselectRowAtIndexPath:path animated:NO];
}

/*- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //CGRect frame = self.navigationItem.titleView.frame;
    //self.navigationItem.titleView.frame = CGRectMake(frame.origin.x,4, frame.size.width,frame.size.height);
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}*/

- (void)viewDidDisappear:(BOOL)animated {
    // Save the state of the search UI so that it can be restored if the view is recreated
    /*self.searchWasActive = [self.searchDisplayController isActive];
    self.savedSearchTerm = [self.searchDisplayController.searchBar text];
    self.savedScopeButtonIndex = [self.searchDisplayController.searchBar selectedScopeButtonIndex];*/
}

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations.
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

/*- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Relinquish ownership any cached data, images, etc that aren't in use.
}*/

- (void)viewDidUnload {
    self.filteredNames = nil;
}

#pragma mark -
#pragma mark UITableView Delegate Methods

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return tableView == self.searchDisplayController.searchResultsTableView ? [self.filteredNames count] : [names count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ListViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) cell = [self createNormalCellWithReuseIdentifier:CellIdentifier];
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        [self configureSearchDisplayCell:cell atIndexPath:indexPath];
    } else {
        [self configureNormalCell:cell atIndexPath:indexPath];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *array = tableView == self.searchDisplayController.searchResultsTableView ? self.filteredNames : names;
    FoodViewController *foodViewController = [[FoodViewController alloc] initWithFoodName:[array objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:foodViewController animated:YES];
    [foodViewController release];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)configureNormalCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"%d - %@", indexPath.row, ((FoodName *)[names objectAtIndex:indexPath.row]).name);
    [(UILabel *)[cell viewWithTag:1] setText:((FoodName *)[names objectAtIndex:indexPath.row]).name];
}

- (void)configureSearchDisplayCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"Index %i = %@", indexPath.row, [self.filteredNames objectAtIndex:indexPath.row]);
    [(UILabel *)[cell viewWithTag:1] setText:((FoodName *)[self.filteredNames objectAtIndex:indexPath.row]).name];
}

- (UITableViewCell *)createNormalCellWithReuseIdentifier:(NSString*)identifier {
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
    
    UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ListViewTableCellBackground"]];
    background.opaque = YES;
    cell.backgroundView = background;
    [background release];
    
    UIImageView *highlight = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ListViewTableCellBackgroundHighlight"]];
    highlight.opaque = YES;
    cell.selectedBackgroundView = highlight;
    [highlight release];
    
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(70,10, 250,25)] autorelease];
    label.tag = 1;
    label.font = [UIFont fontWithName:@"Sketchetik" size:20];
    label.textColor = [UIColor colorWithWhite:(4.0/16.0) alpha:1];
    label.backgroundColor = [UIColor clearColor];
    label.opaque = NO;
    label.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    label.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
    [cell.contentView addSubview:label];
    
    return cell;
}

- (UITableViewCell *)createSearchDisplayCellWithReuseIdentifier:(NSString *)identifier {
    return [self createNormalCellWithReuseIdentifier:identifier];
}

#pragma mark -
#pragma mark Searching

- (void)filterNamesForQuery:(NSString *)query inScopeNamed:(NSString *)scope atIndex:(NSInteger)scopeIndex {
	// Update the filtered array based on the search text and scope.
	[self.filteredNames removeAllObjects]; // First clear the filtered array.
    /*FoodName *food = [[FoodName alloc] initWithId:0 specific:@"Hello" general:@"World"];
    [self.filteredNames addObject:food];
    [food release];*/
	
    NSString *conditions;
    if (scopeIndex == 2) { // All
        conditions = @"1"; // Short-circuit the WHERE clause
    } else if (scopeIndex == 1) { // Kingdom
        conditions = [NSString stringWithFormat:@"kingdom = \"%@\"", _kingdom];
    } else { // Family
        conditions = [NSString stringWithFormat:@"family = \"%@\"", _family];
    }
    NSString *sql = [self sqlSearch:@"id, specific, general, family, kingdom"
                                query:query
                                where:conditions];
    FMResultSet *results = [db executeQuery:sql];
    //NSLog(@"\n---");
    while ([results next]) {
        FoodName *food = [[FoodName alloc] initWithId:[results intForColumn:@"id"]
                                             specific:[results stringForColumn:@"specific"]
                                              general:[results stringForColumn:@"general"]];
        //NSLog(@"Found: %@", food.name);
        [self.filteredNames addObject:food];
        [food release];
    }
    [results close];
}

#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    [UIView beginAnimations:nil context:NULL];
    [self.view viewWithTag:2].alpha = 0;
    [UIView commitAnimations];
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    [UIView beginAnimations:nil context:NULL];
    [self.view viewWithTag:2].alpha = 1;
    [UIView commitAnimations];
    
    // Don't put this in searchDisplayController:willUnloadTableView: because it will probably
    // not get called unless there's a memory issue, and the background mask will remain after
    // search ends.
    UIImageView *background = (UIImageView *)[self.view viewWithTag:99];
    //NSLog(@"background = %@", background);
    [background removeFromSuperview];
    //NSLog(@"willEndSearch: background retainCount = %i", [background retainCount]);
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView {
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.separatorColor = [UIColor clearColor];
    tableView.backgroundColor = [UIColor clearColor];
    UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ListViewBackground"]];
    background.tag = 99;
    background.frame = CGRectMake(0,88, 320,460);
    background.opaque = YES;
    [self.view insertSubview:background belowSubview:tableView];
    [background release];
    //NSLog(@"didShowSearchResultsTableView: background retainCount = %i", [background retainCount]);
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    NSString *scope = [self.searchDisplayController.searchBar.scopeButtonTitles objectAtIndex:self.searchDisplayController.searchBar.selectedScopeButtonIndex];
    [self filterNamesForQuery:searchString inScopeNamed:scope atIndex:self.searchDisplayController.searchBar.selectedScopeButtonIndex];
    //NSLog(@"Reloading for query: %@", searchString);
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    NSString *scope = [self updateSearchBarPlaceholderWithScopeAtIndex:searchOption];
    [self filterNamesForQuery:self.searchDisplayController.searchBar.text inScopeNamed:scope atIndex:searchOption];
    //NSLog(@"Reloading for scope: %@", scope);
    return YES;
}

- (NSString *)updateSearchBarPlaceholderWithScopeAtIndex:(NSInteger)index {
    NSString *scope = [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:index];
    self.searchDisplayController.searchBar.placeholder = [NSString stringWithFormat:@"Search %@", scope];
    return scope;
}
@end