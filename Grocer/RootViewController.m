//
//  RootViewController.m
//  Grocer
//
//  Created by Sherród Faulks on 2/21/11.
//  Copyright 2011 Soft Illuminations, Inc. All rights reserved.
//

#import "RootViewController.h"
#import "ListViewController.h"
#import "GrocerAppDelegate.h"
#import "FMResultSet.h"
#import "FoodName.h"
#import "FoodViewController.h"

@implementation RootViewController

@synthesize filteredNames=_filteredNames;
@synthesize savedSearchTerm=_savedSearchTerm;
@synthesize searchWasActive=_searchWasActive;
@synthesize savedScopeButtonIndex=_savedScopeButtonIndex;

- (IBAction)showSelectionImage:(id)sender {
    UIButton *button = (UIButton *)sender;
    selectionImage.center = button.center;
    selectionImage.alpha  = 1;
    selectionImage.hidden = NO;
}

- (IBAction)fadeOutSelectionImage:(id)sender {
    if (!selectionImage.hidden) {
        [UIView animateWithDuration:0.25 animations:^{
            selectionImage.alpha = 0; 
        } completion:^(BOOL completed) {
            selectionImage.hidden = YES;
        }];
    }
}

- (IBAction)selectFamily:(id)sender {
    UIButton *button = (UIButton *)sender;
    ListViewController *listViewController = [[ListViewController alloc] initWithFamily:button.titleLabel.text inKingdom:self.kingdom];
    [self.navigationController pushViewController:listViewController animated:YES];
    [listViewController release];
}

- (NSString *)kingdom {
    CGFloat offset = [(UIScrollView *)[self.view viewWithTag:1] contentOffset].x;
    if (offset < 320) {
        return nil;
    } else if (offset < 640) {
        return @"Vegetable";
    } else {
        return @"Fruit";
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!db) db = ((GrocerAppDelegate *)[[UIApplication sharedApplication] delegate]).db;
    UIScrollView *scrollView = (UIScrollView *)[self.view viewWithTag:1];
    scrollView.contentSize = CGSizeMake(320 * 3, 460);
    scrollView.contentOffset = CGPointMake(320, 0);
    self.title = @"Back";
    
    self.filteredNames = [NSMutableArray array];
    if (self.savedSearchTerm) {
        // Restore search settings if they were saved in didReceiveMemoryWarning.
        [self.searchDisplayController setActive:self.searchWasActive];
        [self.searchDisplayController.searchBar setSelectedScopeButtonIndex:self.savedScopeButtonIndex];
        [self.searchDisplayController.searchBar setText:self.savedSearchTerm];
        self.savedSearchTerm = nil;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [self fadeOutSelectionImage:nil];
    [super viewDidAppear:animated];
}

/*- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/

- (void)viewDidDisappear:(BOOL)animated {
    // Save the state of the search UI so that it can be restored if the view is recreated
    self.searchWasActive = [self.searchDisplayController isActive];
    self.savedSearchTerm = [self.searchDisplayController.searchBar text];
    self.savedScopeButtonIndex = [self.searchDisplayController.searchBar selectedScopeButtonIndex];
	[super viewDidDisappear:animated];
}

/*
 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 */

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [selectionImage release];
    selectionImage = nil;
    [super viewDidUnload];

    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

- (void)dealloc
{
    [_filteredNames release];
    [selectionImage release];
    [super dealloc];
}

#pragma mark -
#pragma mark Searching

- (NSString *) sqlSearch:(NSString *)select query:(NSString *)query {
    return [NSString stringWithFormat:@"SELECT %@ FROM foods WHERE available = 1 AND (alternateNames || specific || general) LIKE \"%%%@%%\" ORDER BY (specific || general) ASC",
            select, query];
}

- (void)filterNamesForQuery:(NSString *)query atIndex:(NSInteger)scopeIndex {
	// Update the filtered array based on the search text and scope.
	[self.filteredNames removeAllObjects]; // First clear the filtered array.
    NSString *sql = [self sqlSearch:@"id, specific, general" query:query];
    FMResultSet *results = [db executeQuery:sql];
    /*NSLog(@"\n---");
    NSLog(@"DB: %@", db);
    NSLog(@"SQL: %@", sql);
    NSLog(@"Error: %@", [db lastErrorMessage]);*/
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

- (void)searchDisplayController:(UISearchDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView {
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.separatorColor = [UIColor clearColor];
    tableView.backgroundColor = [UIColor clearColor];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self filterNamesForQuery:searchString atIndex:self.searchDisplayController.searchBar.selectedScopeButtonIndex];
    //NSLog(@"Reloading for query: %@", searchString);
    return YES;
}

#pragma mark -
#pragma mark UITableView Delegate Methods

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.filteredNames count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ListViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) cell = [self createCellWithReuseIdentifier:CellIdentifier];
    FoodName *food = (FoodName *)[self.filteredNames objectAtIndex:indexPath.row];
    [(UILabel *)[cell viewWithTag:1] setText:food.name];
    return cell;
}

- (UITableViewCell *)createCellWithReuseIdentifier:(NSString*)identifier {
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
    label.font = [UIFont fontWithName:@"Helvetica Neue" size:20];
    label.textColor = [UIColor colorWithWhite:(6.0/16.0) alpha:1];
    label.backgroundColor = [UIColor clearColor];
    label.opaque = NO;
    label.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    label.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
    [cell.contentView addSubview:label];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FoodViewController *foodViewController = [[FoodViewController alloc] initWithFoodName:(FoodName *)[self.filteredNames objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:foodViewController animated:YES];
    [foodViewController release];
}

@end
